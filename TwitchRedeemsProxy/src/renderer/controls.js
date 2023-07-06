const { ipcRenderer } = require('electron');

function popRedeem() {
  ipcRenderer.send('popRedeem');
}

function resetRedeemQueue() {
  ipcRenderer.send('resetRedeemQueue');
}

function refundChannelPoints() {
  ipcRenderer.send('refundChannelPoints');
}

function getTwitchRedeems() {
  ipcRenderer.send('getTwitchRedeems');
}

function deleteRedeems() {
  ipcRenderer.send('deleteRedeems');
}

function pauseRedeems() {
  ipcRenderer.send('pauseRedeems');
}

function unpauseRedeems() {
  ipcRenderer.send('unpauseRedeems');
}

module.exports = {
  popRedeem,
  resetRedeemQueue,
  refundChannelPoints,
  getTwitchRedeems,
  deleteRedeems,
  pauseRedeems,
  unpauseRedeems,
};
