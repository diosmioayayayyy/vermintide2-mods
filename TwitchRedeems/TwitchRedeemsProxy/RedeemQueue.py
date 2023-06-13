import queue

class RedeemQueue():
    def __init__(self):
        self.q = queue.Queue()

    def size(self):
        return self.q.qsize()

    def push(self, obj):
         self.q.put(obj)

    def pop(self):
        obj = None
        try:
            obj = self.q.get(block=False)
        except queue.Empty:
            pass
        return obj