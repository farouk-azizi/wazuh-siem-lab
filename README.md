# 🔒 Wazuh SIEM Lab as Code

Lab SIEM/XDR entièrement reproductible (Vagrant + Ansible) avec 15+ règles Sigma 
mappées MITRE ATT&CK, validées par Atomic Red Team.

## 🎯 Objectif du projet

Déploiement automatisé d'un lab de détection sur 3 VMs (Manager Wazuh, agent Windows 
+ Sysmon, agent Linux) pour simuler et détecter des attaques réelles.

## 📐 Architecture

![Architecture du lab](screenshots/architecture.png)

| Rôle | OS | IP | Fonction |
|------|-----|-----|----------|
| Wazuh Manager | Ubuntu 22.04 | 192.168.56.10 | SIEM/XDR central |
| Agent Windows | Windows 10 | 192.168.56.11 | Endpoint surveillé + Sysmon |
| Agent Linux | Ubuntu 22.04 | 192.168.56.12 | Endpoint surveillé |

## 🚀 Déploiement en 3 commandes

```bash
git clone https://github.com/TON_USER/wazuh-siem-lab.git
cd wazuh-siem-lab
vagrant up