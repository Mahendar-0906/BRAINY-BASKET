"""Firebase-backed collection access with a durable local development fallback."""
from __future__ import annotations

import json
import os
from copy import deepcopy
from pathlib import Path
from threading import Lock
from typing import Any

COLLECTIONS = (
    "users", "inventory", "sensor_readings", "iot_devices", "shopping_lists",
    "recipes", "ai_recommendations", "activity_logs", "alerts",
    "household_members", "food_items", "meal_logs", "nutrition_records", "nutrition_targets",
)


class CollectionStore:
    def __init__(self) -> None:
        self._lock = Lock()
        self._path = Path(os.getenv("BRAINY_BASKET_STORE", ".brainy_basket_data.json"))
        self._firestore = None
        self._use_firestore = False
        self._connect_firestore()
        if not self._use_firestore:
            self._data = self._load()

    def _connect_firestore(self) -> None:
        try:
            import firebase_admin
            from firebase_admin import credentials, firestore
            if not firebase_admin._apps:
                service_json = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON")
                if service_json:
                    firebase_admin.initialize_app(credentials.Certificate(json.loads(service_json)))
                elif os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
                    firebase_admin.initialize_app()
                else:
                    return
            self._firestore = firestore.client()
            self._use_firestore = True
        except (ImportError, ValueError, OSError):
            self._use_firestore = False

    def _load(self) -> dict[str, list[dict[str, Any]]]:
        if self._path.exists():
            try:
                return json.loads(self._path.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError):
                pass
        return {collection: [] for collection in COLLECTIONS}

    def _save(self) -> None:
        self._path.write_text(json.dumps(self._data, indent=2), encoding="utf-8")

    @property
    def backend(self) -> str:
        return "firebase" if self._use_firestore else "local-development"

    def list(self, collection: str) -> list[dict[str, Any]]:
        if self._use_firestore:
            return [{"id": doc.id, **doc.to_dict()} for doc in self._firestore.collection(collection).stream()]
        with self._lock:
            return deepcopy(self._data.setdefault(collection, []))

    def get(self, collection: str, document_id: str) -> dict[str, Any] | None:
        if self._use_firestore:
            doc = self._firestore.collection(collection).document(document_id).get()
            return {"id": doc.id, **doc.to_dict()} if doc.exists else None
        with self._lock:
            return next((deepcopy(item) for item in self._data.setdefault(collection, []) if item.get("id") == document_id), None)

    def upsert(self, collection: str, document_id: str, value: dict[str, Any]) -> dict[str, Any]:
        record = {"id": document_id, **value}
        if self._use_firestore:
            self._firestore.collection(collection).document(document_id).set(value, merge=True)
            return record
        with self._lock:
            records = self._data.setdefault(collection, [])
            existing = next((index for index, item in enumerate(records) if item.get("id") == document_id), None)
            if existing is None:
                records.append(record)
            else:
                records[existing] = {**records[existing], **record}
            self._save()
        return deepcopy(record)

    def add(self, collection: str, value: dict[str, Any]) -> dict[str, Any]:
        document_id = value.get("id") or value.get("readingId")
        if not document_id:
            import uuid
            document_id = uuid.uuid4().hex
        return self.upsert(collection, document_id, value)

    def update_where(self, collection: str, field: str, value: Any, changes: dict[str, Any]) -> dict[str, Any] | None:
        records = self.list(collection)
        record = next((item for item in records if item.get(field) == value), None)
        if not record:
            return None
        return self.upsert(collection, record["id"], {**record, **changes})


store = CollectionStore()
