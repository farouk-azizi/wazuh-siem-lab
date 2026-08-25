cat > scripts/attacks/credential_dump.sh << 'EOF'
#!/bin/bash
# Attack: Credential Dumping Simulation
# MITRE: T1003.001
# Wazuh Rule: 100008
# Run from: Host PC (connects to target via SSH)

TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-ubuntu}"
SSH_KEY="${3:-$HOME/.ssh/ansible_wazuh_key}"

echo "[+] Simulating credential dumping strings on $TARGET_IP"
echo "[+] MITRE T1003.001 | Expected Wazuh Rule: 100008 (Level 10)"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" '
    echo "mimikatz # sekurlsa::logonpasswords" > /dev/null 2>&1 || true
    echo "sekurlsa::minidump lsass.dmp" > /dev/null 2>&1 || true
    echo "lsadump::sam" > /dev/null 2>&1 || true
    echo "procdump -accepteula -ma lsass.exe lsass.dmp" > /dev/null 2>&1 || true
'

echo "[+] Done. Check Wazuh dashboard: rule.id:100008"
EOF
chmod +x scripts/attacks/credential_dump.sh