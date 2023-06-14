import json
import queue
import threading

class RedeemQueue():
    def __init__(self, filename="redeems.json"):
        self.filename = filename
        self.q = queue.Queue(maxsize=0)

    def __iter__(self):
            return iter(self.q.queue)

    def __next__(self):
        if self.q.empty():
            raise StopIteration
        return self.q.get()

    def size(self):
        return self.q.qsize()

    def push(self, obj):
         self.q.put(obj)

    def pop(self):
        if self.q.qsize() > 0:
            return self.q.get(block=False)
        else:
            return None

    def clear(self):
        self.q.clear()

    def load(self):
        # Load JSON data from file
        with open(self.filename, "r") as file:
            json_data = file.read()

        # Deserialize the JSON data to a list
        queue_list = json.loads(json_data)

        # Create a new queue and enqueue items from the list
        new_queue = queue.Queue()
        for item in queue_list:
            new_queue.put(item)

    def save(self):
        # Convert the queue to a list.
        queue_list = list(self.q)

        # Serialize the list to JSON.
        json_data = json.dumps(queue_list)

        # Store the JSON data in a file.
        with open(self.filename, "w") as file:
            file.write(json_data)
