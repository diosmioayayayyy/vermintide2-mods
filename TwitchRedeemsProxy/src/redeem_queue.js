require('./utils/logging.js');
const FifoQueue = require('./utils/fifo_queue.js');
const TwitchRedeemsHTTPProxy = require('./api/twitch_redeems_http_proxy.js');
const TwitchHelixAPI = require('./api/twitch_helix_api.js');
const { ipcMain } = require('electron');

class RedeemQueue {
  constructor() {
    // Queue settings.
    this.time_between_redeems = 5;

    this.init();
  }

  init() {
    this.queue = new FifoQueue();
    this.next_redeem_id = 0;
    this.last_redeemed_id = null;
    this.user_colors = {};
    this.queue_timer = 0;
    this.reset_browser_overlay = true;
  }

  send_settings() {
    global.main_window.webContents.send('send_setting', "setting_time_between_redeems", String(this.time_between_redeems));
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
    console.log(`Added redeem '${redeem.reward.title}' to queue with uid ${redeem.twitch_redeems_uid}`);
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

  request_redeem() {
    if (this.queue_timer == 0) {
      return this.pop();
    }
    return null;
  }

  pop() {
    const redeem = this.queue.pop();
    if (redeem != null) {
      this.last_redeemed_id = redeem.twitch_redeems_uid;
      console.info(`Redeem '${redeem.reward.title}' got popped`)
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

// Settings from IPC.
ipcMain.on("setting_time_between_redeems", (event, value) => {
  redeemQueueInstance.time_between_redeems = Number(value);
});

ipcMain.on("resetRedeemQueue", (event, value) => {
  redeemQueueInstance.init();
});

module.exports = {
  redeem_queue: redeemQueueInstance
};
