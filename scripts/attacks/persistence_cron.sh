cat > scripts/attacks/persistence_cron.sh << 'EOF'
#!/bin/bash
# Attack: Persistence via Crontab
# MITRE: T1053.003
# Wazuh Rule: 100003
# Run from: Host PC (connects to target via SSH)

TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-ubuntu}"
SSH_KEY="${3:-$HOME/.ssh/ansible_wazuh_key}"

echo "[+] Simulating crontab persistence on $TARGET_IP"
echo "[+] MITRE T1053.003 | Expected Wazuh Rule: 100003 (Level 7)"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" '
    echo "[+] Adding test cron entry..."
    (crontab -l 2>/dev/null; echo "*/5 * * * * /bin/echo persistence-test > /dev/null") | crontab -
    echo "[+] Current crontab:"
    crontab -l
    sleep 2
    echo "[+] Cleaning up..."
    crontab -l 2>/dev/null | grep -v "persistence-test" | crontab -
    echo "[+] Crontab cleaned."
'

echo "[+] Done. Check Wazuh dashboard: rule.id:100003"
EOF
chmod +x scripts/attacks/persistence_cron.sh