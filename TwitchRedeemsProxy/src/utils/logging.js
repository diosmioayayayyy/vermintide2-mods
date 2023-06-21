
// Store the original console.log method
const originalConsoleLog = console.log;
const originalConsoleWarning = console.warn;
const originalConsoleError = console.error;
const originalConsoleInfo = console.info;

// Override console loggin functions to send them to renderer.
console.log = function(...args) {
  // Send to rendere.js
  const log_string = args.map((arg) => String(arg)).join(' ');
  global.main_window.webContents.send('logToConsole', "log", log_string);

  // Call the original console.log method with the same arguments
  originalConsoleLog.apply(console, args);
};

console.warn = function(...args) {
  // Send to rendere.js
  const log_string = args.map((arg) => String(arg)).join(' ');
  global.main_window.webContents.send('logToConsole', "warning", log_string);

  // Call the original console.log method with the same arguments
  originalConsoleWarning.apply(console, args);
};

console.error = function(...args) {
  // Send to rendere.js
  if (global.main_window) {
    const log_string = args.map((arg) => String(arg)).join(' ');
    global.main_window.webContents.send('logToConsole', "error", log_string);
  }

  // Call the original console.log method with the same arguments
  originalConsoleError.apply(console, args);
};

console.info = function(...args) {
  // Send to rendere.js
  const log_string = args.map((arg) => String(arg)).join(' ');
  global.main_window.webContents.send('logToConsole', "info", log_string);

  // Call the original console.log method with the same arguments
  originalConsoleInfo.apply(console, args);
};
