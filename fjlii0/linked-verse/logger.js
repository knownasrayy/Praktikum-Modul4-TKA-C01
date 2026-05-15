const fs = require("fs");
const path = require("path");

const logFile = process.env.LOG_FILE || path.join(__dirname, "logs", "linked-verse.log");

fs.mkdirSync(path.dirname(logFile), { recursive: true });

function writeLog(entry) {
  const logEntry = {
    timestamp: new Date().toISOString(),
    ...entry,
  };

  const line = JSON.stringify(logEntry);
  fs.appendFileSync(logFile, `${line}\n`);
  console.log(line);
}

function writeMalformedLog() {
  const line = "{\"level\":\"ERROR\",\"service\":\"linked-verse-api\",\"message\":\"malformed linked verse log\",\"event_type\":";
  fs.appendFileSync(logFile, `${line}\n`);
  console.log(line);
}

module.exports = {
  writeLog,
  writeMalformedLog,
};
