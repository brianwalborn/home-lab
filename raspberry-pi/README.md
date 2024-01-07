# Home Lab - Raspberry Pi

## Recommended Path

You should generally be able to follow any of these guides to accomplish their intended outcome, but some loosely depend on each other. Below is the recommended path to follow if you're starting from scratch.

> Keep in mind these guides are written with the assumption that you're working with a cluster consisting of a head node and one or more worker nodes.

1. [Initial setup](./initial-setup.md)
2. [Assign a static IP address to your Pi](./static-ip-address.md)
3. [Turn your Pi into a DHCP server](./dhcp-server.md)
4. [Turn your Pi into an Internet gateway](./internet-gateway.md)
5. [Turn your Pi into a DNS server for your local network](./dns-server.md)

Any guides not included in this list are completely independent and can be followed on any Ubuntu device.

## System Information

### Installed (Non-Default) `apt` Packages

1. Head node (`one`):
    ```
    me@one:~$ sudo apt install kea
    me@one:~$ sudo apt install neofetch
    me@one:~$ sudo apt install net-tools
    me@one:~$ sudo apt install postgresql
    ```

### System Information with `neofetch`

Below is the `neofetch` information for each Raspberry Pi in the cluster

1. Head node (`one`):
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
