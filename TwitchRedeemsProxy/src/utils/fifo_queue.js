
class FifoQueue {
  constructor() {
    this.items = [];
  }

  push(element) {
    this.items.push(element);
  }

  push_to_front(element) {
    this.items.unshift(element);
  }

  pop() {
    return this.isEmpty() ? null : this.items.shift();
  }

  front() {
    return this.isEmpty() ? null : this.items[0];
  }

  back() {
    return this.isEmpty() ? null : this.items[this.items.length - 1];
  }

  isEmpty() {
    return this.items.length === 0;
  }

  size() {
    return this.items.length;
  }
}

module.exports = FifoQueue;
