const crypto = require("crypto");
const express = require("express");
const { writeLog, writeMalformedLog } = require("./logger");

const app = express();
const port = Number(process.env.PORT || 3000);

const linkedGates = new Set([
  "CHUNITHM",
  "CHUNITHM PLUS",
  "AIR",
  "STAR",
  "AMAZON",
  "CRYSTAL",
  "CRYSTAL PLUS",
  "PARADISE",
  "NEW",
  "SUN",
  "SUN PLUS",
  "LUMINOUS",
  "LUMINOUS PLUS",
  "VERSE",
  "X-VERSE",
  "RE:VERSE",
  "UNIVERSE",
]);

app.set("trust proxy", true);
app.use((req, _res, next) => {
  req.requestId = req.header("x-request-id") || crypto.randomUUID();
  next();
});
app.use(express.json());

function sourceIp(req) {
  const forwarded = req.header("x-forwarded-for");
  if (forwarded) {
    return forwarded.split(",")[0].trim();
  }

  return req.ip || req.socket.remoteAddress || "unknown";
}

function baseLog(req, body = {}) {
  return {
    service: "linked-verse-api",
    request_id: req.requestId,
    method: req.method,
    route: req.route ? req.route.path : req.path,
    player_id: body.player_id || "UNKNOWN_PLAYER",
    player_name: body.player_name || "Unknown Player",
    linked_gate: body.linked_gate || "UNKNOWN_GATE",
  };
}

function invalidGateLog(req, body, reason) {
  return {
    ...baseLog(req, body),
    level: "ERROR",
    event_type: "Invalid Gate Request",
    status: "rejected",
    message: "Linked gate request was rejected.",
    source_ip: sourceIp(req),
    reason,
  };
}

function missingFields(body, fields) {
  return fields.filter((field) => !body[field]);
}

app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "linked-verse-api" });
});

app.post("/gate/access", (req, res) => {
  const body = req.body || {};
  const missing = missingFields(body, ["player_id", "player_name", "linked_gate"]);

  if (missing.length > 0) {
    const log = invalidGateLog(req, body, `Missing request fields: ${missing.join(", ")}`);
    writeLog(log);
    return res.status(400).json({ status: "rejected", request_id: req.requestId, reason: log.reason });
  }

  if (!linkedGates.has(body.linked_gate)) {
    const log = invalidGateLog(req, body, "Gate identifier is not registered in the Linked VERSE catalog.");
    writeLog(log);
    return res.status(404).json({ status: "rejected", request_id: req.requestId, reason: log.reason });
  }

  const log = {
    ...baseLog(req, body),
    level: "INFO",
    event_type: "Gate Access Success",
    status: "success",
    message: `Player accessed ${body.linked_gate} linked gate.`,
  };

  writeLog(log);
  res.json({ status: "success", request_id: req.requestId });
});

app.post("/gate/unlock", (req, res) => {
  const body = req.body || {};
  const missing = missingFields(body, ["player_id", "player_name", "linked_gate"]);

  if (missing.length > 0) {
    const log = invalidGateLog(req, body, `Missing request fields: ${missing.join(", ")}`);
    writeLog(log);
    return res.status(400).json({ status: "rejected", request_id: req.requestId, reason: log.reason });
  }

  if (!linkedGates.has(body.linked_gate)) {
    const log = invalidGateLog(req, body, "Unlock request targeted an unknown linked gate.");
    writeLog(log);
    return res.status(404).json({ status: "rejected", request_id: req.requestId, reason: log.reason });
  }

  if (!body.condition_met) {
    const log = {
      ...baseLog(req, body),
      level: "WARN",
      event_type: "Gate Unlock Failed",
      status: "failed",
      message: "Linked gate unlock condition was not met.",
    };

    writeLog(log);
    return res.status(409).json({ status: "failed", request_id: req.requestId });
  }

  const log = {
    ...baseLog(req, body),
    level: "INFO",
    event_type: "Gate Unlock Success",
    status: "success",
    message: "Linked gate unlock condition was met.",
  };

  writeLog(log);
  res.json({ status: "success", request_id: req.requestId });
});

app.post("/challenge/start", (req, res) => {
  const body = req.body || {};
  const missing = missingFields(body, ["player_id", "player_name", "linked_gate"]);

  if (missing.length > 0) {
    const log = invalidGateLog(req, body, `Missing request fields: ${missing.join(", ")}`);
    writeLog(log);
    return res.status(400).json({ status: "rejected", request_id: req.requestId, reason: log.reason });
  }

  if (!linkedGates.has(body.linked_gate)) {
    const log = invalidGateLog(req, body, "Challenge start request targeted an unknown linked gate.");
    writeLog(log);
    return res.status(404).json({ status: "rejected", request_id: req.requestId, reason: log.reason });
  }

  const log = {
    ...baseLog(req, body),
    level: "INFO",
    event_type: "Challenge Start",
    status: "started",
    message: "Linked VERSE challenge session started.",
  };

  writeLog(log);
  res.json({ status: "started", request_id: req.requestId });
});

app.post("/challenge/result", (req, res) => {
  const body = req.body || {};
  const missing = missingFields(body, ["player_id", "player_name", "linked_gate"]);

  if (missing.length > 0) {
    const log = invalidGateLog(req, body, `Missing request fields: ${missing.join(", ")}`);
    writeLog(log);
    return res.status(400).json({ status: "rejected", request_id: req.requestId, reason: log.reason });
  }

  if (!linkedGates.has(body.linked_gate)) {
    const log = invalidGateLog(req, body, "Challenge result request targeted an unknown linked gate.");
    writeLog(log);
    return res.status(404).json({ status: "rejected", request_id: req.requestId, reason: log.reason });
  }

  const cleared = body.cleared === true;
  const log = {
    ...baseLog(req, body),
    level: cleared ? "INFO" : "WARN",
    event_type: cleared ? "Challenge Clear" : "Challenge Failed",
    status: cleared ? "cleared" : "failed",
    message: cleared
      ? "Linked VERSE challenge clear condition was achieved."
      : "Linked VERSE challenge clear condition was not achieved.",
  };

  writeLog(log);
  res.status(cleared ? 200 : 422).json({ status: log.status, request_id: req.requestId });
});

app.post("/debug/malformed-log", (req, res) => {
  writeMalformedLog();
  res.status(202).json({ status: "written", type: "malformed_log", request_id: req.requestId });
});

app.post("/debug/missing-field-log", (req, res) => {
  writeLog({
    level: "ERROR",
    service: "linked-verse-api",
    event_type: "Invalid Gate Request",
    linked_gate: "UNKNOWN_GATE",
    status: "rejected",
    message: "Debug log intentionally missing player identity fields.",
    source_ip: sourceIp(req),
    reason: "Lab test for Logstash missing_required_fields routing.",
  });

  res.status(202).json({ status: "written", type: "missing_field_log", request_id: req.requestId });
});

app.use((err, req, res, _next) => {
  const log = {
    ...baseLog(req),
    level: "ERROR",
    event_type: "Invalid Gate Request",
    status: "rejected",
    message: "Request body could not be processed.",
    source_ip: sourceIp(req),
    reason: err instanceof SyntaxError ? "Malformed JSON request body." : "Unhandled application error.",
  };

  writeLog(log);
  res.status(400).json({ status: "rejected", request_id: req.requestId, reason: log.reason });
});

app.listen(port, () => {
  console.log(`Linked VERSE app listening on port ${port}`);
});
