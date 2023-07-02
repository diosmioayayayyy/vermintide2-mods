require('./utils/logging.js');
const FifoQueue = require('./utils/fifo_queue.js');
const ipc = require('./utils/ipc.js');
const TwitchRedeemsHTTPProxy = require('./api/twitch_redeems_http_proxy.js');
const TwitchHelixAPI = require('./api/twitch_helix_api.js');

class RedeemQueue {
  constructor() {
    this.queue = new FifoQueue();
    this.next_redeem_id = 0;
    this.last_redeemed_id = null;
    this.user_colors = {};

    // Queue settings.
    this.time_between_redeems = 5;
    this.queue_timer = 0;
  }

  queue_timer_tick = () => {
    if (this.queue_timer >= 0) {
      if (this.queue_timer === 0) {
        // Nothing to do here I guess.
      } else {
        this.queue_timer--;
        setTimeout(this.queue_timer_tick, 1000);
      }
    }
  }

  start_queue_timer() {
    this.queue_timer = this.time_between_redeems;
    this.queue_timer_tick();
  }

  async push(redeem) {
    // Query user color if we don't have it yet.
    if (!(redeem.user_id in this.user_colors)) {
      await this.get_user_chat_color(redeem.user_id);
    }

    if (this.queue.size() == 0) {
      this.start_queue_timer();
    }

    redeem.user_chat_color = this.user_colors[redeem.user_id];
    redeem.twitch_redeems_uid = this.next_redeem_id++;
    console.log(`Added redeem to queue with uid ${redeem.twitch_redeems_uid}`);
    this.queue.push(redeem);
  }
  
  find_by_uid(uid) {
    for (const [index, redeem] of this.queue.items.entries()) {
      if (redeem.twitch_redeems_uid == uid) {
        return index;
      }
    }
    return null;
  }

  pop() {
    const redeem = this.queue.pop();
    if (redeem != null) {
      this.last_redeemed_id = redeem.twitch_redeems_uid;
    }
    if (this.size() > 0) {
      this.start_queue_timer();
    }
    return redeem;
  }

  clear() {
    return this.queue.clear();
  }

  size() {
    return this.queue.size();
  }

  async get_user_chat_color(user_id) {
    const raw_body = await TwitchHelixAPI.get_user_chat_color(user_id);
    const body = JSON.parse(raw_body.data);

    // Add colors to table.
    for (const element of body.data) {
      this.user_colors[element.user_id] = element.color;
    }
  }
}

const redeemQueueInstance = new RedeemQueue();

module.exports = {
  redeem_queue: redeemQueueInstance
};
