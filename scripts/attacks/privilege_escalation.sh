cat > scripts/attacks/privilege_escalation.sh << 'EOF'
#!/bin/bash
# Attack: Privilege Escalation via sudo
# MITRE: T1548.003
# Wazuh Rule: 100002
# Run from: Host PC (connects to target via SSH)

TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-ubuntu}"
SSH_KEY="${3:-$HOME/.ssh/ansible_wazuh_key}"

echo "[+] Simulating privilege escalation on $TARGET_IP"
echo "[+] MITRE T1548.003 | Expected Wazuh Rule: 100002 (Level 8)"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" '
    echo "[+] Running: sudo -i"
    sudo -i -c "echo privesc-test; exit" 2>/dev/null || true
    echo "[+] Running: sudo su"
    sudo su -c "echo privesc-test; exit" 2>/dev/null || true
    echo "[+] Running: sudo bash"
    sudo bash -c "echo privesc-test; exit" 2>/dev/null || true
'

echo "[+] Done. Check Wazuh dashboard: rule.id:100002"
EOF
chmod +x scripts/attacks/privilege_escalation.sh