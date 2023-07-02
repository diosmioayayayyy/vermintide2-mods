
const console_messages = [["", ""]];
let console_messages_index = 0;

function push_console_message(severity, message) {
  const consoleElement = document.getElementById('console');
  if (consoleElement) {
    const logEntry = document.createElement('div');

    switch (severity) {
      case "info": logEntry.className = "console-message info"; break;
      case "warning": logEntry.className = "console-message warning"; break;
      case "error": logEntry.className = "console-message error"; break;
      case "log": logEntry.className = "console-message log"; break;
      default: console.error("Unknown severity: ", severity);
    }

    // TODO: stack messages if they are the same

    logEntry.textContent = message;
    consoleElement.appendChild(logEntry);
    consoleElement.scrollTop = consoleElement.scrollHeight; // Auto-scroll to the bottom
  }
}

function add_console_message(severity, text) {
  console_messages.push([severity, text]);
  print_console_messages();
}

function print_console_messages() {
  for (let index = console_messages_index; index < console_messages.length; index++) {
    if (console_messages_index < index) {
      const [severity, text] = console_messages[index];
      push_console_message(severity, text);
      console_messages_index = index;
    }
  }
}

ipcRenderer.on('logToConsole', (event, severity, text) => {
  add_console_message(severity, text);
});

function reset_console_message_index() {
  console_messages_index = 0;
}

module.exports = {
  reset_console_message_index,
  print_console_messages,
};
