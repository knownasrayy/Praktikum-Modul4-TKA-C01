#!/bin/bash

BASE_URL="http://localhost:3000"
SUSPICIOUS_IP="192.168.66.6"

echo "========================================"
echo "  Linked VERSE Test Event Generator"
echo "========================================"
echo ""

# --- Gate Access Success (5 events) ---
echo "[1/35] Gate Access Success - P0001 Sakura - CHUNITHM"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -d '{"player_id":"P0001","player_name":"Sakura","linked_gate":"CHUNITHM"}' && echo ""

echo "[2/35] Gate Access Success - P0002 Haruka - AIR"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -d '{"player_id":"P0002","player_name":"Haruka","linked_gate":"AIR"}' && echo ""

echo "[3/35] Gate Access Success - P0003 Miku - STAR"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -d '{"player_id":"P0003","player_name":"Miku","linked_gate":"STAR"}' && echo ""

echo "[4/35] Gate Access Success - P0001 Sakura - PARADISE"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -d '{"player_id":"P0001","player_name":"Sakura","linked_gate":"PARADISE"}' && echo ""

echo "[5/35] Gate Access Success - P0004 Rin - LUMINOUS"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -d '{"player_id":"P0004","player_name":"Rin","linked_gate":"LUMINOUS"}' && echo ""

# --- Gate Unlock Failed (3 events) ---
echo "[6/35] Gate Unlock Failed - P0001 Sakura - VERSE"
curl -s -X POST "$BASE_URL/gate/unlock" -H "Content-Type: application/json" \
  -d '{"player_id":"P0001","player_name":"Sakura","linked_gate":"VERSE","condition_met":false}' && echo ""

echo "[7/35] Gate Unlock Failed - P0002 Haruka - X-VERSE"
curl -s -X POST "$BASE_URL/gate/unlock" -H "Content-Type: application/json" \
  -d '{"player_id":"P0002","player_name":"Haruka","linked_gate":"X-VERSE","condition_met":false}' && echo ""

echo "[8/35] Gate Unlock Failed - P0003 Miku - UNIVERSE"
curl -s -X POST "$BASE_URL/gate/unlock" -H "Content-Type: application/json" \
  -d '{"player_id":"P0003","player_name":"Miku","linked_gate":"UNIVERSE","condition_met":false}' && echo ""

# --- Gate Unlock Success (2 events) ---
echo "[9/35] Gate Unlock Success - P0001 Sakura - CHUNITHM"
curl -s -X POST "$BASE_URL/gate/unlock" -H "Content-Type: application/json" \
  -d '{"player_id":"P0001","player_name":"Sakura","linked_gate":"CHUNITHM","condition_met":true}' && echo ""

echo "[10/35] Gate Unlock Success - P0004 Rin - SUN"
curl -s -X POST "$BASE_URL/gate/unlock" -H "Content-Type: application/json" \
  -d '{"player_id":"P0004","player_name":"Rin","linked_gate":"SUN","condition_met":true}' && echo ""

# --- Challenge Start (5 events) ---
echo "[11/35] Challenge Start - P0001 Sakura - CHUNITHM"
curl -s -X POST "$BASE_URL/challenge/start" -H "Content-Type: application/json" \
  -d '{"player_id":"P0001","player_name":"Sakura","linked_gate":"CHUNITHM"}' && echo ""

echo "[12/35] Challenge Start - P0002 Haruka - AIR"
curl -s -X POST "$BASE_URL/challenge/start" -H "Content-Type: application/json" \
  -d '{"player_id":"P0002","player_name":"Haruka","linked_gate":"AIR"}' && echo ""

echo "[13/35] Challenge Start - P0003 Miku - STAR"
curl -s -X POST "$BASE_URL/challenge/start" -H "Content-Type: application/json" \
  -d '{"player_id":"P0003","player_name":"Miku","linked_gate":"STAR"}' && echo ""

echo "[14/35] Challenge Start - P0004 Rin - LUMINOUS"
curl -s -X POST "$BASE_URL/challenge/start" -H "Content-Type: application/json" \
  -d '{"player_id":"P0004","player_name":"Rin","linked_gate":"LUMINOUS"}' && echo ""

echo "[15/35] Challenge Start - P0001 Sakura - VERSE"
curl -s -X POST "$BASE_URL/challenge/start" -H "Content-Type: application/json" \
  -d '{"player_id":"P0001","player_name":"Sakura","linked_gate":"VERSE"}' && echo ""

# --- Challenge Clear (4 events) ---
echo "[16/35] Challenge Clear - P0001 Sakura - CHUNITHM"
curl -s -X POST "$BASE_URL/challenge/result" -H "Content-Type: application/json" \
  -d '{"player_id":"P0001","player_name":"Sakura","linked_gate":"CHUNITHM","cleared":true}' && echo ""

echo "[17/35] Challenge Clear - P0002 Haruka - AIR"
curl -s -X POST "$BASE_URL/challenge/result" -H "Content-Type: application/json" \
  -d '{"player_id":"P0002","player_name":"Haruka","linked_gate":"AIR","cleared":true}' && echo ""

echo "[18/35] Challenge Clear - P0003 Miku - STAR"
curl -s -X POST "$BASE_URL/challenge/result" -H "Content-Type: application/json" \
  -d '{"player_id":"P0003","player_name":"Miku","linked_gate":"STAR","cleared":true}' && echo ""

echo "[19/35] Challenge Clear - P0004 Rin - LUMINOUS"
curl -s -X POST "$BASE_URL/challenge/result" -H "Content-Type: application/json" \
  -d '{"player_id":"P0004","player_name":"Rin","linked_gate":"LUMINOUS","cleared":true}' && echo ""

# --- Challenge Failed (4 events) ---
echo "[20/35] Challenge Failed - P0001 Sakura - VERSE"
curl -s -X POST "$BASE_URL/challenge/result" -H "Content-Type: application/json" \
  -d '{"player_id":"P0001","player_name":"Sakura","linked_gate":"VERSE","cleared":false}' && echo ""

echo "[21/35] Challenge Failed - P0002 Haruka - X-VERSE"
curl -s -X POST "$BASE_URL/challenge/result" -H "Content-Type: application/json" \
  -d '{"player_id":"P0002","player_name":"Haruka","linked_gate":"X-VERSE","cleared":false}' && echo ""

echo "[22/35] Challenge Failed - P0003 Miku - UNIVERSE"
curl -s -X POST "$BASE_URL/challenge/result" -H "Content-Type: application/json" \
  -d '{"player_id":"P0003","player_name":"Miku","linked_gate":"UNIVERSE","cleared":false}' && echo ""

echo "[23/35] Challenge Failed - P0001 Sakura - PARADISE"
curl -s -X POST "$BASE_URL/challenge/result" -H "Content-Type: application/json" \
  -d '{"player_id":"P0001","player_name":"Sakura","linked_gate":"PARADISE","cleared":false}' && echo ""

# --- Invalid Gate Request - SUSPICIOUS ACTIVITY (4 events, same IP) ---
echo "[24/35] Invalid Gate Request (Suspicious) - P9999 SuspectX - INVALID_GATE_1"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -H "X-Forwarded-For: $SUSPICIOUS_IP" \
  -d '{"player_id":"P9999","player_name":"SuspectX","linked_gate":"INVALID_GATE_1"}' && echo ""

echo "[25/35] Invalid Gate Request (Suspicious) - P9999 SuspectX - INVALID_GATE_2"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -H "X-Forwarded-For: $SUSPICIOUS_IP" \
  -d '{"player_id":"P9999","player_name":"SuspectX","linked_gate":"INVALID_GATE_2"}' && echo ""

echo "[26/35] Invalid Gate Request (Suspicious) - P9999 SuspectX - HACKED_GATE"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -H "X-Forwarded-For: $SUSPICIOUS_IP" \
  -d '{"player_id":"P9999","player_name":"SuspectX","linked_gate":"HACKED_GATE"}' && echo ""

echo "[27/35] Invalid Gate Request (Suspicious) - P9999 SuspectX - EXPLOIT_GATE"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -H "X-Forwarded-For: $SUSPICIOUS_IP" \
  -d '{"player_id":"P9999","player_name":"SuspectX","linked_gate":"EXPLOIT_GATE"}' && echo ""

# --- Invalid Gate Request - Missing fields (2 events) ---
echo "[28/35] Invalid Gate Request - Missing fields (player_name, linked_gate)"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -d '{"player_id":"P0005"}' && echo ""

echo "[29/35] Invalid Gate Request - Empty body"
curl -s -X POST "$BASE_URL/challenge/start" -H "Content-Type: application/json" \
  -d '{}' && echo ""

# --- Debug: Malformed Log (1 event) ---
echo "[30/35] Debug: Malformed Log"
curl -s -X POST "$BASE_URL/debug/malformed-log" && echo ""

# --- Debug: Missing Field Log (1 event) ---
echo "[31/35] Debug: Missing Field Log"
curl -s -X POST "$BASE_URL/debug/missing-field-log" && echo ""

# --- Additional events for diversity ---
echo "[32/35] Gate Access Success - P0005 Luka - CRYSTAL"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -d '{"player_id":"P0005","player_name":"Luka","linked_gate":"CRYSTAL"}' && echo ""

echo "[33/35] Gate Access Success - P0005 Luka - NEW"
curl -s -X POST "$BASE_URL/gate/access" -H "Content-Type: application/json" \
  -d '{"player_id":"P0005","player_name":"Luka","linked_gate":"NEW"}' && echo ""

echo "[34/35] Challenge Start - P0005 Luka - SUN PLUS"
curl -s -X POST "$BASE_URL/challenge/start" -H "Content-Type: application/json" \
  -d '{"player_id":"P0005","player_name":"Luka","linked_gate":"SUN PLUS"}' && echo ""

echo "[35/35] Challenge Clear - P0005 Luka - SUN PLUS"
curl -s -X POST "$BASE_URL/challenge/result" -H "Content-Type: application/json" \
  -d '{"player_id":"P0005","player_name":"Luka","linked_gate":"SUN PLUS","cleared":true}' && echo ""

echo ""
echo "========================================"
echo "  Generation Complete! (35 events)"
echo "========================================"
echo ""
echo "Event summary:"
echo "  - Gate Access Success:    7"
echo "  - Gate Unlock Failed:     3"
echo "  - Gate Unlock Success:    2"
echo "  - Challenge Start:        6"
echo "  - Challenge Clear:        5"
echo "  - Challenge Failed:       4"
echo "  - Invalid Gate Request:   6 (4 suspicious from same IP)"
echo "  - Malformed Log:          1"
echo "  - Missing Field Log:      1"
echo "========================================"
