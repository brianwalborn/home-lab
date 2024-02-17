# Home Lab - Raspberry Pi

## Recommended Path

You should generally be able to follow any of these guides to accomplish their intended outcome, but some loosely depend on each other. Below is the recommended path to follow if you're starting from scratch.

> Keep in mind these guides are written with the assumption that you're working with a cluster consisting of a primary node and one or more worker nodes.

### Cluster Setup

1. [Initial setup of the **primary** node](./initial-setup.md)
2. [Assign a static IP address to your primary node](./static-ip-address.md)
3. [Turn your primary node into a DHCP server for your cluster](./dhcp-server.md)
4. [Turn your primary node into an Internet gateway for your cluster](./internet-gateway.md)
5. [Turn your primary node into a DNS server for your cluster](./dns-server.md)
6. [Initial setup of the **worker** nodes](./initial-setup.md)
7. [Use public key authentication on your worker nodes](./ssh-public-key-authentication.md)
8. [Enable parallel SSH](./parallel-ssh.md)
9. [Turn your Pi cluster into a Kubernetes cluster](./kubernetes-cluster.md)

### Supplementary Guides

> These guides are completely independent and can be followed in any order on any Ubuntu machine.

- [Postgres setup](./postgres.md)
- [SSH public key authentication](./ssh-public-key-authentication.md)

## System Information

### Lab Hardware

- 3x [Raspberry Pi 4 Model B, 4 GB RAM](https://www.adafruit.com/product/4296)
- 1x [Raspberry Pi 2 Model B, 1 GB RAM](https://www.adafruit.com/product/2358)
- 3x [Waveshare PoE Hat E](https://www.amazon.com/Raspberry-Ethernet-Standard-Compatible-Connecting/dp/B0974TK3KD)
- 1x [TP-Link TL SG1005P 5 Port Gigabit PoE Switch](https://www.amazon.com/TP-Link-Compliant-Shielded-Optimization-TL-SG1005P/dp/B07PPJTR15)
- 4x [SanDisk 32GB Ultra MicroSDHC Card](https://www.amazon.com/SanDisk-2-Pack-microSDXC-2x128GB-Adapter/dp/B08GY9NYRM)
- 1x [Samsung 870 EVO SATA III SSD, 1 TB](https://www.amazon.com/SAMSUNG-Inch-Internal-MZ-77E1T0B-AM/dp/B08QBJ2YMG)
- 4x [Monoprice Cat6 Ethernet Patch Cable, 0.5'](https://www.amazon.com/Monoprice-Cat6-Ethernet-Patch-Cable/dp/B01C68CVDC)
- 1x [Utronics Raspberry Pi Cluster Case](https://www.amazon.com/UCTRONICS-Upgraded-Enclosure-Raspberry-Compatible/dp/B09S11Q684)

### System Information with `neofetch`

Below is the `neofetch` command output for each Raspberry Pi in the cluster

- Primary node (`zero`):
    ```
    me@zero
    -----------
    OS: Ubuntu 23.10 aarch64
    Host: Raspberry Pi 4 Model B Rev 1.5
    Kernel: 6.5.0-1010-raspi
    Uptime: 1 day, 10 hours, 42 mins
    Packages: 750 (dpkg), 4 (snap)
    Shell: bash 5.2.15
    Terminal: /dev/pts/0
    CPU: BCM2835 (4) @ 1.800GHz
    Memory: 841MiB / 3790MiB
    ```
- Worker node (`one`):
    ```
    me@one
    ------
    OS: Ubuntu 23.10 aarch64
    Host: Raspberry Pi 4 Model B Rev 1.5
    Kernel: 6.5.0-1010-raspi
    Uptime: 1 day, 10 hours, 43 mins
    Packages: 732 (dpkg), 4 (snap)
    Shell: bash 5.2.15
    Terminal: /dev/pts/0
    CPU: BCM2835 (4) @ 1.800GHz
    Memory: 431MiB / 3790MiB
    ```
- Worker node (`two`):
    ```
    me@two
    ------
    OS: Ubuntu 23.10 aarch64
    Host: Raspberry Pi 4 Model B Rev 1.5
    Kernel: 6.5.0-1010-raspi
    Uptime: 1 day, 10 hours, 43 mins
    Packages: 732 (dpkg), 4 (snap)
    Shell: bash 5.2.15
    Terminal: /dev/pts/0
    CPU: BCM2835 (4) @ 1.800GHz
    Memory: 356MiB / 3790MiB
    ```
- Worker node (`three`):
    ```
    me@three
    --------
    OS: Ubuntu 23.10 armv7l
    Host: Raspberry Pi 2 Model B Rev 1.1
    Kernel: 6.5.0-1010-raspi
    Uptime: 1 day, 10 hours, 45 mins
    Packages: 722 (dpkg), 4 (snap)
    Shell: bash 5.2.15
    Terminal: /dev/pts/0
    CPU: BCM2835 (4) @ 900MHz
    Memory: 216MiB / 918MiB
    ```
