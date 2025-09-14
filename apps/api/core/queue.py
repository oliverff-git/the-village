from rq import Queue
from redis import Redis
from .config import settings

redis_conn = Redis.from_url(settings.REDIS_URL)
queue = Queue(connection=redis_conn)

def enqueue_job(func, *args, **kwargs):
    """Enqueue a job to be processed by workers"""
    return queue.enqueue(func, *args, **kwargs)
