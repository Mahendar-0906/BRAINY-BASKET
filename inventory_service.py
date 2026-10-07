"""Authoritative inventory update workflow for Firebase or local development storage."""
from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from .firebase_service import store


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def status_for(quantity: float, minimum: float) -> str:
    if quantity == 0:
        return "OUT_OF_STOCK"
    if quantity <= minimum:
        return "LOW_STOCK"
    return "AVAILABLE"


def inventory_snapshot() -> list[dict[str, Any]]:
    """Return all manually registered commodities with their current live state."""
    return store.list("inventory")


def process_sensor_reading(device_id: str, item_id: str, sensor_type: str, value: float, unit: str, timestamp: str | None = None) -> dict[str, Any]:
    """
    Process a sensor reading from a registered device.
    
    CRITICAL: The device must be pre-registered and mapped to this commodity.
    Unknown devices are rejected.
    """
    if sensor_type != "weight":
        raise ValueError("sensorType must be weight")
    if value < 0 or value > 10000:
        raise ValueError("sensor value must be between 0 and 10000")

    # Fetch the commodity
    item = store.get("inventory", item_id)
    if not item:
        raise ValueError(f"Unknown commodity itemId: {item_id}. Commodity must be manually registered first.")

    # CRITICAL VALIDATION: Device must be mapped to this commodity
    if item.get("deviceId") and item["deviceId"] != device_id:
        raise ValueError(f"Device {device_id} is not registered for commodity {item.get('name', item_id)}. Please register and map the device first.")

    # If commodity has no device yet, we still reject (strict requirement)
    if not item.get("deviceId"):
        raise ValueError(f"Commodity {item.get('name', item_id)} has no device mapped. Please map a device before sending sensor data.")

    if unit not in ("kg", "g"):
        raise ValueError("weight unit must be kg or g")

    # Convert to kg
    quantity = value / 1000 if unit == "g" else value

    event_time = timestamp or now()

    # Get previous reading for this item
    previous_readings = store.list("sensor_readings")
    previous_for_item = [reading for reading in previous_readings if reading.get("itemId") == item_id]
    previous_value = previous_for_item[-1].get("valueKg") if previous_for_item else item.get("currentQuantity", 0)

    # Calculate change
    change = round(quantity - float(previous_value), 4)

    # Store the sensor reading
    reading = {
        "readingId": f"{device_id}_{event_time}",
        "deviceId": device_id,
        "itemId": item_id,
        "sensorType": sensor_type,
        "value": value,
        "valueKg": quantity,
        "unit": unit,
        "timestamp": event_time,
        "changeKg": change,
    }
    store.add("sensor_readings", reading)

    # Update commodity live state
    new_status = status_for(quantity, float(item["minimumQuantity"]))
    updated = store.upsert("inventory", item_id, {
        **item,
        "currentQuantity": quantity,
        "unit": "kg",
        "status": new_status,
        "deviceId": device_id,
        "lastUpdated": event_time,
    })

    # Update device record
    device = store.get("iot_devices", device_id) or {}
    store.upsert("iot_devices", device_id, {
        **device,
        "deviceId": device_id,
        "itemId": item_id,
        "commodityId": item_id,
        "assignedCommodity": item["name"],
        "status": "ONLINE",
        "latestValue": quantity,
        "latestUnit": "kg",
        "lastSignal": event_time,
        "lastSynchronization": now(),
    })

    # Log consumption if detected
    if change < 0 and abs(change) <= max(float(previous_value) * 0.75, 0.01):
        store.add("activity_logs", {
            "event": "consumption",
            "message": f"{item['name']} consumption detected: {abs(change):.2f} kg",
            "itemId": item_id,
            "timestamp": event_time,
        })

    # Log sensor update
    store.add("activity_logs", {
        "event": "sensor_update",
        "message": f"{item['name']} updated to {quantity:.2f} kg",
        "itemId": item_id,
        "deviceId": device_id,
        "timestamp": event_time,
    })

    # Generate alerts for low stock / out of stock
    if new_status in ("LOW_STOCK", "OUT_OF_STOCK"):
        store.add("alerts", {
            "alertId": f"{item_id}_{new_status}_{event_time}",
            "itemId": item_id,
            "type": new_status,
            "message": f"{item['name']} is {'out of stock' if new_status == 'OUT_OF_STOCK' else 'running low'}.",
            "timestamp": event_time,
            "acknowledged": False,
        })

    return {
        "success": True,
        "itemId": item_id,
        "quantity": quantity,
        "status": new_status,
        "previousQuantity": float(previous_value),
        "changeKg": change,
    }

