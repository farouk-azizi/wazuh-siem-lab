cat > credential_dump.sh << 'EOF'
#!/bin/bash
TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-linux-endpoint-1}"
SSH_KEY="${3:-$HOME/.ssh/ansible_wazuh_key}"

echo "[+] Credential Dumping Simulation on $TARGET_IP"
echo "[+] MITRE T1003.001 | Expected: Rule 100008 (Level 10)"

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" '
    # On Linux, simulate credential access by reading sensitive files
    echo "[*] Attempting to read /etc/shadow..."
    sudo cat /etc/shadow > /dev/null 2>&1 || cat /etc/shadow 2>/dev/null | head -1 || echo "[!] Permission denied (expected)"
    
    echo "[*] Attempting to dump memory strings from /proc..."
    strings /proc/1/environ 2>/dev/null | head -5 || true
    
    # Send mimikatz-style strings to syslog so Wazuh rule 100008 catches them
    # The rule matches: mimikatz|sekurlsa|lsadump|procdump|gsecdump
    echo "[*] Injecting credential dumping signatures to syslog..."
    logger -t mimikatz "sekurlsa::logonpasswords executed"
    logger -t mimikatz "lsadump::sam /patch"
    logger -t procdump "procdump -accepteula -ma lsass.exe lsass.dmp"
    logger -t sekurlsa "sekurlsa::minidump lsass.dmp"
    
    # Also run actual commands containing these strings
    echo "mimikatz # sekurlsa::logonpasswords" > /tmp/mimikatz_sim.txt
    echo "lsadump::sam" >> /tmp/mimikatz_sim.txt
    cat /tmp/mimikatz_sim.txt
    rm -f /tmp/mimikatz_sim.txt
'

echo "[+] Done. Check Wazuh: rule.id:100008"
EOF
chmod +x credential_dump.sh