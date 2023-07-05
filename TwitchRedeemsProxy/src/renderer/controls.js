
function popRedeem() {
  ipcRenderer.send('popRedeem');
}

function resetRedeemQueue() {
  ipcRenderer.send('resetRedeemQueue');
}

function refundChannelPoints() {
  ipcRenderer.send('refundChannelPoints');
}

module.exports = {
  popRedeem,
  resetRedeemQueue,
  refundChannelPoints,
};
