require('./utils/logging.js');
const FifoQueue = require('./utils/fifo_queue.js');
const TwitchRedeemsHTTPProxy = require('./api/twitch_redeems_http_proxy.js');
const TwitchHelixAPI = require('./api/twitch_helix_api.js');
const { ipcMain } = require('electron');


function pick_random_redeem() {
  var p = Math.random();
  for (const [_, redeem] of Object.entries(global.twitch_redeems)) {
    if (!redeem.auto_queue) {
      continue;
    }
    if (p > redeem.cdf) {
      continue;
    }
    else{
      return {
        broadcaster_user_id: "",
        broadcaster_user_login: "",
        broadcaster_user_name: "",
        id: "",
        //user_id: "",
        user_login: "",
        user_name: "IdleQueue",
        user_input: "",
        status: "",
        redeemed_at: "",
        reward: {
          //id: "",
          title: redeem["title"],
          prompt: "",
          cost: redeem["cost"]
        }
      };
    }
  }
  return null;
}


class RedeemQueue {
  constructor() {
    // Queue settings.
    this.time_between_redeems = 5;

    this.init();
  }

  init() {
    this.queue = new FifoQueue();
    this.skip_queue = new FifoQueue();
    this.next_redeem_id = 0;
    this.last_redeemed_id = null;
    this.user_colors = {};
    this.queue_timer = 0;
    this.queue_timer_is_running = false;
    this.reset_browser_overlay = true;

    this.idle_timer_id = null;
  }

  send_settings() {
    global.main_window.webContents.send('send_setting', "setting_time_between_redeems", String(this.time_between_redeems));
  }

  queue_timer_tick = () => {
    if (this.queue_timer >= 0) {
      if (this.queue_timer === 0) {
        this.queue_timer_is_running = false;
      }
      else {
        this.queue_timer--;
        setTimeout(this.queue_timer_tick, 1000);
      }
    }
  }

  start_queue_timer() {
    if (!this.queue_timer_is_running) {
      this.queue_timer_is_running = true;

      const redeem = this.queue.front();
      const redeem_settings = global.twitch_redeems_settings[redeem.reward.title];

      if (redeem_settings && redeem_settings.override_queue_timer) {
        this.queue_timer = redeem_settings.queue_timer_duration;
      }
      else {
        this.queue_timer = this.time_between_redeems;
      }

      this.queue_timer_tick();
    }
  }

  on_idle_timer_end(redeem_queue) {
    // Replace the following line with the function you want to execute on timer end
    var redeem = pick_random_redeem();
    console.log("Timer ended. Execute your function here.");
    if (redeem) {
      redeem_queue.push(redeem, true);
    }
  }

  start_idle_timer(duration) {
    // Cancel idle timer.
    if (this.idle_timer_id) {
      clearInterval(this.idle_timer_id);
      this.idle_timer_id = null;
    }

    // Start idle timer.
    this.idle_timer_id = setInterval(this.on_idle_timer_end, duration, this);
    console.log("Started idle timer")
  }

  stop_idle_timer() {
    console.log("Stopping idle timer")
    clearInterval(this.idle_timer_id);
    this.idle_timer_id = null;
  }

  async push(redeem, idle_redeem=false) {
    // Query user color if we don't have it yet.
    if (!(redeem.user_id in this.user_colors)) {
      await this.get_user_chat_color(redeem.user_id);
    }
    const redeem_settings = global.twitch_redeems_settings[redeem.reward.title];

    redeem.user_chat_color = this.user_colors[redeem.user_id];

    if (!idle_redeem) {
      this.stop_idle_timer();
    }

    var redeem_skips_queue = idle_redeem || (redeem_settings && redeem_settings.skip_queue_timer);

    if (!redeem_skips_queue) {
      redeem.twitch_redeems_uid = this.next_redeem_id++;
    }

    if (redeem_skips_queue) {
      // Redeems landing here will skip the redeem queue.
      this.skip_queue.push(redeem);
    }
    else {
      this.queue.push(redeem);
      if (this.queue.size() == 1 && !this.queue_timer_is_running) {
        this.start_queue_timer();
      }
    }

    console.log(`Added redeem '${redeem.reward.title}' to queue with uid ${redeem.twitch_redeems_uid}`);
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
    if (!this.skip_queue.isEmpty()) {
      const redeem = this.skip_queue.pop()
      if (redeem != null) {
        this.set_redeem_fulfilled(redeem);
        return redeem;
      }
    }

    //Start idle timer if not running.
    if (global.settings.queue_redeem_after_idle_time && !this.idle_timer_id) {
      this.start_idle_timer(global.settings.redeem_idle_time * 1000)
    }

    if (!this.queue_timer_is_running) {
      return this.pop();
    }
    return null;
  }

  pop() {
    const redeem = this.queue.pop();
    if (redeem != null) {
      this.last_redeemed_id = redeem.twitch_redeems_uid;
      this.set_redeem_fulfilled(redeem);
    }
    if (this.size() > 0) {
      this.start_queue_timer();
    }
    return redeem;
  }

  async set_redeem_fulfilled(redeem) {
    if (!redeem.reward.id) {
      return;
    }

    try {
      const response = await TwitchHelixAPI.update_redemption_status_fulfilled(redeem);
      if (response.statusCode == 200) {
        console.info(`Redeem '${redeem.reward.title}' got fulfilled (${redeem.id})`);
      }
      else {
        console.error(`Error fulfilling redeem '${redeem.reward.title}' with status code '${response.statusCode}'`);
      }
    }
    catch (error) {
      console.error(`Error request setting redeem fulfilled: '${error.message}'`);
    }
  }

  async set_redeem_canceled(redeem) {
    try {
      const response = await TwitchHelixAPI.update_redemption_status_canceled(redeem);
      if (response.statusCode == 200) {
        console.info(`Redeem '${redeem.reward.title}' got canceled (${redeem.id})`);
      }
      else {
        console.error(`Error canceling redeem '${redeem.reward.title}' with status code '${response.statusCode}'`);
      }
    }
    catch (error) {
      console.error(`Error request setting redeem canceled: '${error.message}'`);
    }
  }

  size() {
    return this.queue.size();
  }

  async get_user_chat_color(user_id) {
    if (user_id) {
      const raw_body = await TwitchHelixAPI.get_user_chat_color(user_id);
      const body = JSON.parse(raw_body.data);
  
      // Add colors to table.
      for (const element of body.data) {
        this.user_colors[element.user_id] = element.color;
      }
    }
  }
}

const redeemQueueInstance = new RedeemQueue();

// Settings from IPC.
ipcMain.on("setting_time_between_redeems", (event, value) => {
  redeemQueueInstance.time_between_redeems = Number(value);
});

module.exports = {
  redeem_queue: redeemQueueInstance
};
