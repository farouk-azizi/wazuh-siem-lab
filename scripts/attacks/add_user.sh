cat > add_user.sh << 'EOF'
#!/bin/bash
TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-linux-endpoint-1}"
SSH_KEY="${3:-$HOME/.ssh/ansible_wazuh_key}"
TEST_USER="backdoor_user"

echo "[+] Local Account Creation on $TARGET_IP"
echo "[+] MITRE T1136.001 | Expected: Rule 100005 (Level 6)"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" "
    if id $TEST_USER &>/dev/null; then
        echo '[*] User $TEST_USER exists, removing...'
        sudo userdel -r $TEST_USER 2>/dev/null || true
    fi
    
    echo '[*] Creating user: $TEST_USER'
    sudo useradd -m -s /bin/bash $TEST_USER 2>/dev/null || true
    echo '$TEST_USER:Backdoor123!' | sudo chpasswd 2>/dev/null || true
    sudo usermod -aG sudo $TEST_USER 2>/dev/null || true
    
    echo '[*] Verifying user:'
    id $TEST_USER 2>/dev/null || echo '[!] User creation may have failed'
    
    # Also add to /etc/passwd manually to trigger FIM on critical files
    echo '[*] Touching /etc/passwd and /etc/shadow...'
    sudo touch /etc/passwd
    sudo touch /etc/shadow
    
    sleep 3
    
    echo '[*] Cleaning up...'
    sudo userdel -r $TEST_USER 2>/dev/null || true
    echo '[*] Cleanup done.'
"

echo "[+] Done. Check Wazuh: rule.id:100005"
EOF
chmod +x add_user.sh