cat > privilege_escalation.sh << 'EOF'
#!/bin/bash
TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-linux-endpoint-1}"
SSH_KEY="${3:-$HOME/.ssh/ansible_wazuh_key}"

echo "[+] Privilege Escalation Simulation on $TARGET_IP"
echo "[+] MITRE T1548.003 | Expected: Rule 100002 (Level 8)"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" '
    # Real sudo commands that are logged in /var/log/auth.log
    echo "[*] Executing: sudo -i (spawning root shell...)"
    sudo -i -c "whoami; echo privesc-test-sudo-i" 2>/dev/null || echo "[!] sudo -i failed or password required"
    
    echo "[*] Executing: sudo su (switching to root...)"
    sudo su -c "whoami; echo privesc-test-sudo-su" 2>/dev/null || echo "[!] sudo su failed"
    
    echo "[*] Executing: sudo bash (spawning bash as root...)"
    sudo bash -c "whoami; echo privesc-test-sudo-bash" 2>/dev/null || echo "[!] sudo bash failed"
    
    echo "[*] Executing: sudo sh (spawning sh as root...)"
    sudo sh -c "whoami; echo privesc-test-sudo-sh" 2>/dev/null || echo "[!] sudo sh failed"
    
    # Backup: send to syslog directly so Wazuh always sees it
    logger -p authpriv.warning -t sudo "linux-endpoint-1 : TTY=pts/0 ; PWD=/home/linux-endpoint-1 ; USER=root ; COMMAND=/bin/bash -i"
    logger -p authpriv.warning -t sudo "linux-endpoint-1 : TTY=pts/0 ; PWD=/home/linux-endpoint-1 ; USER=root ; COMMAND=/bin/su"
'

echo "[+] Done. Check Wazuh: rule.id:100002"
EOF
chmod +x privilege_escalation.sh