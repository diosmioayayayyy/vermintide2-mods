function create_event_listeners() {
  function setup_event_listener(setting_name) {
    var setting = document.getElementById(setting_name);
    setting.addEventListener("input", setting_has_changed);
  }

  setup_event_listener("setting_time_between_redeems");
  setup_event_listener("setting_example_text");

  // TODO apply only x seconds.
}

function setting_has_changed(event) {
  const value = document.getElementById(event.srcElement.id).value;
  update_setting(event.srcElement.id, value)
}

function update_setting(name, value) {
  console.log(`Setting has changed: ${name} to ${value}`)
  ipcRenderer.send('setting_time_between_redeems', value);
}

function apply_setting(setting_name, value) {
  console.log(`Applying setting: ${setting_name} to ${value}`)
  var setting = document.getElementById(setting_name);
  setting.value = value;
}

function request_settings() {
  ipcRenderer.send('request_settings');
}

ipcRenderer.on('send_setting', (event, setting_name, value) => {
  apply_setting(setting_name, value);
});

module.exports = {
  create_event_listeners,
  request_settings,
};
