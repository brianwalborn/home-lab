# Home Lab - Raspberry Pi

## Recommended Path

You should generally be able to follow any of these guides to accomplish their intended outcome, but some loosely depend on each other. Below is the recommended path to follow if you're starting from scratch.

> Keep in mind these guides are written with the assumption that you're working with a cluster consisting of a primary node and one or more worker nodes.

### Cluster Setup

1. [Initial setup](./initial-setup.md)
2. [Assign a static IP address to your Pi](./static-ip-address.md)
3. [Turn your primary node into a DHCP server](./dhcp-server.md)
4. [Turn your primary node into an Internet gateway](./internet-gateway.md)
5. [Turn your primary node into a DNS server for your subnet](./dns-server.md)
6. [Use public key authentication on your worker nodes](./ssh-public-key-authentication.md)
6. [Turn your Pi cluster into a Kubernetes cluster](./kubernetes-cluster.md)

### Supplementary Guides

> These guides are completely independent and can be followed in any order on any Ubuntu machine.

- [Postgres setup](./postgres.md)
- [SSH public key authentication](./ssh-public-key-authentication.md)

## System Information

### Installed (Third-Party) `apt` Packages

1. Primary node (`one`):
    ```
    me@one:~$ sudo apt install kea
    me@one:~$ sudo apt install neofetch
    me@one:~$ sudo apt install net-tools
    me@one:~$ sudo apt install postgresql
    ```

### System Information with `neofetch`

Below is the `neofetch` information for each Raspberry Pi in the cluster

1. Primary node (`one`):
    ```
    me@one
    -----------
    OS: Ubuntu 23.10 aarch64
    Host: Raspberry Pi 4 Model B Rev 1.5
    Kernel: 6.5.0-1005-raspi
    Uptime: 1 hour, 22 mins
    Packages: 744 (dpkg), 4 (snap)
    Shell: bash 5.2.15
    Terminal: /dev/pts/0
    CPU: BCM2835 (4) @ 1.800GHz
    Memory: 260MiB / 3790MiB
    ```
