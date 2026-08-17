#!/bin/bash

# ============================================================
# Linux Security Audit
# Author: Fran Fuentes
# Purpose: Read-only Linux security assessment
# ============================================================

REPORT_DIR="$(dirname "$0")/../reports"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT="$REPORT_DIR/security_audit_$TIMESTAMP.txt"

mkdir -p "$REPORT_DIR"

exec > >(tee -a "$REPORT") 2>&1

echo "============================================================"
echo "              LINUX SECURITY AUDIT"
echo "============================================================"
echo "Hostname : $(hostname)"
echo "User     : $(whoami)"
echo "Date     : $(date)"
echo "Kernel   : $(uname -r)"
echo "OS       : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2-)"
echo "============================================================"
echo

echo "[1] SYSTEM INFORMATION"
echo "------------------------------------------------------------"
uptime
echo

echo "[2] USER INFORMATION"
echo "------------------------------------------------------------"
echo "Current user:"
whoami
echo

echo "Logged-in users:"
who
echo

echo "Users with login shells:"
awk -F: '$7 ~ /(bash|sh|zsh)$/ {print $1 ":" $7}' /etc/passwd
echo

echo "[3] ROOT PRIVILEGES"
echo "------------------------------------------------------------"
echo "Users with UID 0:"
awk -F: '$3 == 0 {print $1}' /etc/passwd
echo

echo "Sudo configuration:"
if command -v sudo >/dev/null 2>&1; then
    sudo -n -l 2>/dev/null || echo "Sudo privileges require authentication."
else
    echo "sudo not installed."
fi
echo

echo "[4] SSH SECURITY"
echo "------------------------------------------------------------"

if command -v sshd >/dev/null 2>&1; then

    echo "SSH service:"
    systemctl is-enabled ssh 2>/dev/null || \
    systemctl is-enabled sshd 2>/dev/null || \
    echo "Unable to determine SSH service status."

    echo
    echo "SSH configuration:"
    
    grep -Ei \
    '^(PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|Port)' \
    /etc/ssh/sshd_config 2>/dev/null || \
    echo "SSH configuration not accessible."

else
    echo "OpenSSH server does not appear to be installed."
fi

echo

echo "[5] FIREWALL"
echo "------------------------------------------------------------"

if command -v ufw >/dev/null 2>&1; then
    echo "UFW status:"
    sudo ufw status 2>/dev/null || echo "Unable to read UFW status."
else
    echo "UFW not installed."
fi

if command -v firewall-cmd >/dev/null 2>&1; then
    echo
    echo "Firewalld status:"
    sudo firewall-cmd --state 2>/dev/null
fi

echo

echo "[6] LISTENING NETWORK SERVICES"
echo "------------------------------------------------------------"

if command -v ss >/dev/null 2>&1; then
    ss -tuln
else
    echo "ss command not available."
fi

echo

echo "[7] RUNNING SERVICES"
echo "------------------------------------------------------------"

systemctl list-units --type=service --state=running \
2>/dev/null | head -30

echo

echo "[8] DISK USAGE"
echo "------------------------------------------------------------"

df -h

echo

echo "[9] WORLD-WRITABLE FILES"
echo "------------------------------------------------------------"

find /etc /var/tmp /tmp \
-type f -perm -0002 \
2>/dev/null | head -50

echo

echo "[10] FAILED LOGIN ATTEMPTS"
echo "------------------------------------------------------------"

if command -v journalctl >/dev/null 2>&1; then
    journalctl --no-pager -q \
    | grep -Ei "failed password|authentication failure" \
    | tail -20
else
    echo "journalctl unavailable."
fi

echo

echo "============================================================"
echo "AUDIT COMPLETE"
echo "Report saved to:"
echo "$REPORT"
echo "============================================================"
