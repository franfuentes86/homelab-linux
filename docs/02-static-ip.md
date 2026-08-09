# Static IP Configuration

## Objective

Assign a permanent IP address to the server.

## Configuration File

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Example

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```

Apply

```bash
sudo netplan apply
```
