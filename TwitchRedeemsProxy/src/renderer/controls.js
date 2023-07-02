
function popRedeem() {
  ipcRenderer.send('popRedeem');
}

function resetRedeemQueue() {
  ipcRenderer.send('resetRedeemQueue');
}

module.exports = {
  popRedeem,
  resetRedeemQueue,
};
