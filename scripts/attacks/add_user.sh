cat > scripts/attacks/add_user.sh << 'EOF'
#!/bin/bash
# Attack: Create Local Account
# MITRE: T1136.001
# Wazuh Rule: 100005
# Run from: Host PC (connects to target via SSH)

TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-ubuntu}"
SSH_KEY="${3:-$HOME/.ssh/ansible_wazuh_key}"
TEST_USER="testbackdoor"

echo "[+] Simulating local user creation on $TARGET_IP"
echo "[+] MITRE T1136.001 | Expected Wazuh Rule: 100005 (Level 6)"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" "
    if id $TEST_USER &>/dev/null; then
        echo '[+] User exists, removing first...'
        sudo userdel -r $TEST_USER 2>/dev/null || true
    fi
    echo '[+] Creating user: $TEST_USER'
    sudo useradd -m $TEST_USER 2>/dev/null || true
    id $TEST_USER 2>/dev/null || true
    sleep 2
    echo '[+] Cleaning up...'
    sudo userdel -r $TEST_USER 2>/dev/null || true
"

echo "[+] Done. Check Wazuh dashboard: rule.id:100005"
EOF
chmod +x scripts/attacks/add_user.sh