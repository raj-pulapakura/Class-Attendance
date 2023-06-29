import time
import uuid

def gen_primary_key():
    timestamp = time.time()
    unique_id = uuid.uuid4()
    return f"{timestamp}-{unique_id}"