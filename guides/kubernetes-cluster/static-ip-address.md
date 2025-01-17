# Give Your Raspberry Pi a Static IP Address

## Motivation

Assigning a static IP address to your Raspberry Pi has many advantages, but it all boils down to being able to find it at the same IP address regardless of switching ISPs, getting a new router, moving homes, or any other situation that would typically result in resetting your network.

## Determine the Network Interface to Use

Unless you've attached additional network interfaces to your Pi, you'll see three interfaces available when you run [`ip addr`](https://manpages.ubuntu.com/manpages/mantic/en/man8/ip.8.html): `lo` (loopback), `eth0` (on-board ethernet port), and, if wi-fi is set up, `wlan0` (wireless). If you have something like a [USB to ethernet adapter](https://www.amazon.com/USB-Ethernet-Adapter-Gigabit-Switch/dp/B09GRL3VCN) plugged in, you may see an another interface such as `enx7cc2c6497350`.
```
me@kubernetes-primary:~$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether d8:3a:dd:3c:74:5b brd ff:ff:ff:ff:ff:ff
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether d8:3a:dd:3c:74:5d brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.234/24 metric 600 brd 192.168.0.255 scope global dynamic wlan0
       valid_lft 85842sec preferred_lft 85842sec
    inet6 2600:1004:a031:386d:da3a:ddff:fe3c:745d/64 scope global dynamic mngtmpaddr noprefixroute
       valid_lft 86380sec preferred_lft 14380sec
    inet6 fe80::da3a:ddff:fe3c:745d/64 scope link
       valid_lft forever preferred_lft forever
```
This guide will use the `wlan0` interface, but the same process applies to other interfaces (with some caveats).

## Assign a Static IP Address with Netplan

We'll be using [Netplan](https://netplan.io/) to assign a static IP to our Pi -- it comes pre-installed on Ubuntu and lets us manage our network configuration using YAML. If you run `ls /etc/netplan` you'll see a file like `01-network-manage-all.yaml` or `50-cloud-init.yaml` that contains the default configuration, depending on the version of Ubuntu running. Note that Netplan processes configuration files in lexical order, so if the same interface is affected by a subsequently named configuration, Netplan will override the preceding configuration for that interface.

1. Double-check Netplan configurations in `/run/netplan`, `/etc/netplan`, and `/lib/netplan` to ensure there are no existing configurations conflicting with the interface you're planning on using.
    ```
    me@kubernetes-primary:~$ sudo su -
    root@kubernetes-primary:~# cat /run/netplan/* /etc/netplan/* /lib/netplan/*
    ```
2. Create a superceding Netplan file
    > Using `80-static-ip.yaml` here simply as a subsequently processed configuration to the `50-cloud-init.yaml` that already existed on my system.
    ```
    me@kubernetes-primary:~$ sudo vi /etc/netplan/80-static-ip.yaml
    ```
    and add the following configuration, replacing the interface with your chosen interface name (`eth0`, `wlan0`, etc.) and making any other updates directed by the comments
    ```
    network:
      version: 2
      renderer: networkd
      wifis: # this should be 'ethernets' if using the eth0 interface
        wlan0: # replace with your interface's id
          dhcp4: false # disables dynamic IP assignment on this interface
          addresses:
            - 192.168.0.2/24 # an IP address on your home network
          routes:
            - to: default
              via: 192.168.0.1 # the IP address of your gateway/router
          nameservers: # use google's nameservers
            addresses:
              - 8.8.8.8
              - 8.8.4.4
    ```
3. Apply the configuration by running
    ```
    me@kubernetes-primary:~$ sudo chmod 600 /etc/netplan/80-static-ip.yaml
    me@kubernetes-primary:~$ sudo netplan generate
    me@kubernetes-primary:~$ sudo netplan apply
    ```
    > This may break your connection with the Pi but the configuration will still apply

    Now, when running `ip addr`, you should see the static IP address reflected on the interface with the interface renamed to the `set-name` from the configuration. If not, run `sudo reboot`.
    ```
    me@kubernetes-primary:~$ ip addr
    ...
    3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
      link/ether d8:3a:dd:3c:74:5d brd ff:ff:ff:ff:ff:ff
      inet 192.168.0.2/24 brd 192.168.0.255 scope global wlan0
         valid_lft forever preferred_lft forever
      inet6 fd57:742d:5eb8:1:da3a:ddff:fe3c:745d/64 scope global dynamic mngtmpaddr noprefixroute
         valid_lft 7135sec preferred_lft 7135sec
      inet6 2600:1004:a031:386d:da3a:ddff:fe3c:745d/64 scope global dynamic mngtmpaddr noprefixroute
         valid_lft 86390sec preferred_lft 14390sec
      inet6 fe80::da3a:ddff:fe3c:745d/64 scope link
         valid_lft forever preferred_lft forever
    ...
    ```
5. We can now SSH into our Pi with it's new IP address from our home network
    ```
    brianwalborn $ ssh me@192.168.0.2
    me@192.168.0.2's password:
    Welcome to Ubuntu 23.10 (GNU/Linux 6.5.0-1005-raspi aarch64)
    ...
    ```

## Net Step

- [Turn your control-plane node into a DHCP server for your cluster](./dhcp-server.md)
