#!/bin/bash

echo "Hostname:"
hostname

echo

echo "IP Address:"
hostname -I

echo

echo "Memory:"
free -h

echo

echo "Disk:"
df -h

echo

echo "Uptime:"
uptime
