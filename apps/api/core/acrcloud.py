from typing import Optional, Dict
from .config import settings

class ACRCloudClient:
def init(self):
self.host = settings.ACRCLOUD_HOST
self.access_key = settings.ACRCLOUD_ACCESS_KEY
self.access_secret = settings.ACRCLOUD_ACCESS_SECRET
self.enabled = bool(self.host and self.access_key and self.access_secret)

def scan_audio(self, audio_data: bytes) -> Optional[Dict]:
    """
    Stubbed: returns None unless enabled. MVP uses mock/no-op.
    """
    if not self.enabled:
        return None
    # TODO: real integration
    return {"status": "ok", "confidence": 0.0}
acrcloud = ACRCloudClient()
