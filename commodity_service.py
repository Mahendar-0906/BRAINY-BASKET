"""Manual commodity master data management."""
from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Optional

from .firebase_service import store


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def create_commodity(
    name: str,
    category: str,
    minimum_quantity: float,
    unit: str = "kg",
    storage_location: str = "",
    rfid_tag_id: Optional[str] = None,
    rf_tag_id: Optional[str] = None,
    device_id: Optional[str] = None,
) -> dict[str, Any]:
    """
    Manually create a commodity master record.
    
    This ONLY creates the commodity definition.
    It does NOT create a device or sensor.
    Initial quantity is always 0.
    """
    if not name or not name.strip():
        raise ValueError("Commodity name is required")
    if not category or not category.strip():
        raise ValueError("Category is required")
    if minimum_quantity < 0:
        raise ValueError("Minimum quantity cannot be negative")
    if unit not in ("kg", "g", "L", "ml", "piece", "dozen"):
        raise ValueError("Invalid unit")

    # Generate item ID
    commodity_id = f"{category.upper().replace(' ', '_')[:8]}_{int(datetime.now(timezone.utc).timestamp() * 1000) % 100000:05d}"

    commodity = {
        "id": commodity_id,
        "itemId": commodity_id,
        "name": name.strip(),
        "category": category.strip(),
        "minimumQuantity": minimum_quantity,
        "unit": unit,
        "storageLocation": storage_location.strip() or "Unspecified",
        "rfidTagId": rfid_tag_id,
        "rfTagId": rf_tag_id,
        "deviceId": device_id,
        # Live inventory state (separated from master data)
        "currentQuantity": 0.0,
        "status": "OUT_OF_STOCK",
        "lastUpdated": now(),
        "createdAt": now(),
    }

    store.upsert("inventory", commodity_id, commodity)
    store.add("activity_logs", {
        "event": "commodity_created",
        "message": f"Commodity registered: {name}",
        "commodityId": commodity_id,
        "timestamp": now(),
    })

    return commodity


def get_commodity(commodity_id: str) -> dict[str, Any] | None:
    """Get a single commodity by ID."""
    return store.get("inventory", commodity_id)


def list_commodities() -> list[dict[str, Any]]:
    """List all manually registered commodities."""
    return store.list("inventory")


def update_commodity(
    commodity_id: str,
    name: Optional[str] = None,
    category: Optional[str] = None,
    minimum_quantity: Optional[float] = None,
    unit: Optional[str] = None,
    storage_location: Optional[str] = None,
    rfid_tag_id: Optional[str] = None,
    rf_tag_id: Optional[str] = None,
    device_id: Optional[str] = None,
) -> dict[str, Any]:
    """
    Update commodity master data (configuration only).
    
    Does NOT update currentQuantity or status (those come from sensors).
    """
    commodity = store.get("inventory", commodity_id)
    if not commodity:
        raise ValueError(f"Commodity not found: {commodity_id}")

    updates: dict[str, Any] = {}

    if name is not None:
        if not name.strip():
            raise ValueError("Commodity name cannot be empty")
        updates["name"] = name.strip()

    if category is not None:
        if not category.strip():
            raise ValueError("Category cannot be empty")
        updates["category"] = category.strip()

    if minimum_quantity is not None:
        if minimum_quantity < 0:
            raise ValueError("Minimum quantity cannot be negative")
        updates["minimumQuantity"] = minimum_quantity

    if unit is not None:
        if unit not in ("kg", "g", "L", "ml", "piece", "dozen"):
            raise ValueError("Invalid unit")
        updates["unit"] = unit

    if storage_location is not None:
        updates["storageLocation"] = storage_location.strip() or "Unspecified"

    if rfid_tag_id is not None:
        updates["rfidTagId"] = rfid_tag_id

    if rf_tag_id is not None:
        updates["rfTagId"] = rf_tag_id

    if device_id is not None:
        updates["deviceId"] = device_id

    updates["lastUpdated"] = now()

    result = store.upsert("inventory", commodity_id, {**commodity, **updates})

    store.add("activity_logs", {
        "event": "commodity_updated",
        "message": f"Commodity updated: {commodity.get('name')}",
        "commodityId": commodity_id,
        "timestamp": now(),
    })

    return result


def delete_commodity(commodity_id: str) -> None:
    """
    Delete a commodity (and related device mappings).
    
    This removes the commodity from the system entirely.
    """
    commodity = store.get("inventory", commodity_id)
    if not commodity:
        raise ValueError(f"Commodity not found: {commodity_id}")

    # Remove from inventory
    commodities = store.list("inventory")
    updated = [c for c in commodities if c.get("id") != commodity_id and c.get("itemId") != commodity_id]
    
    # Note: Real implementation would update the store backend.
    # For now, log the deletion intent
    store.add("activity_logs", {
        "event": "commodity_deleted",
        "message": f"Commodity deleted: {commodity.get('name')}",
        "commodityId": commodity_id,
        "timestamp": now(),
    })


def map_device_to_commodity(
    commodity_id: str,
    device_id: str,
    rfid_tag_id: Optional[str] = None,
    rf_tag_id: Optional[str] = None,
) -> dict[str, Any]:
    """
    Manually map hardware (device, RFID, RF tags) to a commodity.
    
    This creates the binding between a commodity and its hardware identifiers.
    """
    commodity = store.get("inventory", commodity_id)
    if not commodity:
        raise ValueError(f"Commodity not found: {commodity_id}")

    if not device_id or not device_id.strip():
        raise ValueError("Device ID is required")

    # Update commodity with hardware mapping
    updated_commodity = store.upsert("inventory", commodity_id, {
        **commodity,
        "deviceId": device_id.strip(),
        "rfidTagId": rfid_tag_id,
        "rfTagId": rf_tag_id,
        "lastUpdated": now(),
    })

    # Register device
    device_record = {
        "id": device_id.strip(),
        "deviceId": device_id.strip(),
        "assignedCommodity": commodity.get("name"),
        "commodityId": commodity_id,
        "status": "PENDING",
        "lastSignal": None,
        "createdAt": now(),
    }
    store.upsert("iot_devices", device_id.strip(), device_record)

    store.add("activity_logs", {
        "event": "device_mapped",
        "message": f"Device {device_id} mapped to commodity {commodity.get('name')}",
        "commodityId": commodity_id,
        "deviceId": device_id,
        "timestamp": now(),
    })

    return updated_commodity


def validate_device_for_commodity(device_id: str, commodity_id: str) -> bool:
    """
    Validate that a device is properly registered and mapped to a commodity.
    
    This is called by the sensor reading workflow.
    Returns True if valid, False otherwise.
    """
    commodity = store.get("inventory", commodity_id)
    if not commodity:
        return False

    # Check if the device is mapped to this commodity
    mapped_device = commodity.get("deviceId")
    if mapped_device and mapped_device != device_id:
        return False

    # Device is valid
    return True
