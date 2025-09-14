from rq import Worker
from core.queue import redis_conn, queue

if name == "main":
w = Worker([queue], connection=redis_conn)
w.work()
