# Use Your Raspberry Pi as an Internet Gateway for a Cluster

## Motivation

> If the nodes on your subnet have Internet access through WiFi or any other means, this guide isn't necessary.

When setting up a cluster of Raspberry Pis on a subnet, I needed the head node to act as the gateway to to Internet for the worker nodes that didn't have a direct connection to the home network's gateway.

## `iptables` Rules

We'll use `iptables` to set up a forwarding rule on the head node that will give our worker nodes Internet access.

1. Uncomment the `net.ipv4.ip_forward=1` line in `/etc/sysctl.conf` and reboot
    > This also updates /proc/sys/net/ipv4/ip_forward on reboot
    ```
    me@one:~$ sudo vi /etc/sysctl.conf
    # uncomment net.ipv4.ip_forward=1
    me@one:~$ sudo reboot
    ```
2. Run the following command to forward traffic from our subnet (`10.4.4.0/24`) to the interface that gives us Internet (`wlan0`).
    ```
    me@one:~$ sudo iptables -t nat -A POSTROUTING -s 10.4.4.0/24 -o wlan0 -j MASQUERADE
    ```
    Your tables should now look like this
    > Other chains may or may not be empty, but we updated the POSTROUTING chain
    ```
    me@one:~$ sudo iptables -t nat -L -n -v
    ...
    Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
    pkts bytes target     prot opt in     out     source               destination
       0     0 MASQUERADE  0    --  *      wlan0   10.4.4.0/24          0.0.0.0/0
    ```
3. In order to persist these rules across reboots, we need to install a package that takes care of that for us. Answer `Yes` to the prompts.
    ```
    me@one:~$ sudo apt install iptables-persistent
    ```
4. Now we can SSH into a client on our `10.4.4.0/24` subnet (connected to our head node's `eth0` interface) and ping IP addresses.
    ```
    me@one:~$ ssh me@10.4.4.2
    ...
    me@two:~$ ping -c 1 104.18.32.7 # the IP adddress for stackoverflow.com
    PING 104.18.32.7 (104.18.32.7) 56(84) bytes of data.
    64 bytes from 104.18.32.7: icmp_seq=1 ttl=249 time=56.0 ms

    --- 104.18.32.7 ping statistics ---
    1 packets transmitted, 1 received, 0% packet loss, time 0ms
    rtt min/avg/max/mdev = 55.977/55.977/55.977/0.000 ms
    ```
    Note that if we try to ping `stackoverflow.com`, it can't resolve:
    ```
    me@two:~$ ping -c 1 stackoverflow.com
    ping: stackoverflow.com: Temporary failure in name resolution
    ```
    This is because we don't have a DNS server set up. Let's change that.

## DNS on the Worker Node

Much like the instructions for [assigning a static IP](./static-ip-address.md), we'll use `netplan` to assign name servers to our worker node.

1. Create a `netplan` file that will assign the `eth0` interface some nameservers to query
    ```
    me@two:~$ sudo vi /etc/netplan/80-dns-servers.yaml
    network:
      version: 2
      renderer: networkd
      ethernets:
        eth0:
          nameservers:
            addresses:
              - 8.8.8.8
              - 8.8.4.4
    ```
2. Change file permissions to suppress warnings, generate, and apply the `netplan` configuration
    > This will likely break your connection with the Pi but the configuration should still apply. Note that the IP address will also change if no static IP was assigned. If you followed the [DHCP server setup](./dhcp-server.md), check `/var/lib/kea/kea-leases4.csv` for the new IP address.
    ```
    me@two:~$ sudo chmod 600 /etc/netplan/80-dns-servers.yaml
    me@two:~$ sudo netplan generate
    me@two:~$ sudo netplan apply
    ```
3. Now, when you SSH back into the worker node, you'll be able to ping a web address instead of an IP address
    ```
    me@one:~$ ssh me@10.4.4.3 # the IP address changed
    ...
    me@two:~$ ping -c 1 stackoverflow.com
    PING stackoverflow.com (172.64.155.249) 56(84) bytes of data.
    64 bytes from 172.64.155.249 (172.64.155.249): icmp_seq=1 ttl=249 time=56.8 ms

    --- stackoverflow.com ping statistics ---
    1 packets transmitted, 1 received, 0% packet loss, time 0ms
    rtt min/avg/max/mdev = 56.800/56.800/56.800/0.000 ms
    ```
