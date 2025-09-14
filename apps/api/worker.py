from rq import Worker
from core.queue import redis_conn, queue

if __name__ == "__main__":
    w = Worker([queue], connection=redis_conn)
    w.work()
