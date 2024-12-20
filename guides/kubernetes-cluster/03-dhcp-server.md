# Use Your Raspberry Pi as a DHCP Server

## Motivation

Since my home lab has a cluster of Raspberry Pis that live on a separate subnet from my home network, I need the primary node of the cluster to act as a DHCP server so it can assign IP addresses to the worker nodes. For this guide to be worthwhile, you'll want to have a [LAN switch](https://www.amazon.com/TP-Link-Compliant-Shielded-Optimization-TL-SG1005P/dp/B076HZFY3F) handy that you'll connect your primary node (DHCP server) to in order to assign IP addresses to worker nodes (clients).

## Install ISC Kea

There are many different options when it comes to DHCP software that can run on Ubuntu: [dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html), [ISC DHCP](https://www.isc.org/dhcp/), [ISC Kea](https://www.isc.org/kea/), and many others. One of my main goals with my home lab is to get experience with technologies that I may run across in the wild, so dnsmasq -- a service geared toward smaller networks -- didn't seem to fit. ISC DHCP is also widely used, but was announced end-of-life in October of 2022. This left me with ISC Kea -- a more modern and full-featured iteration of ISC DHCP.

1. Running the below command will install a few packages: `kea-dhcp4-server` (what we'll primarily be working with), `kea-dhcp6-server`, `kea-ctrl-agent` (a REST API service for Kea), and `kea-dhcp-ddns-server`. We'll also want to install Postgres for DHCP lease storage.
    ```
    me@zero:~$ sudo apt install kea
    ```
2. Select OK then `configured_random_password` at the prompt which will be used to authenticate with the `kea-ctrl-agent` API service. The password is stored in `/etc/kea/kea-api-password` -- to change it, run `dpkg-reconfigure kea-ctrl-agent` or simply edit the file manually.

## Give the On-Board Ethernet Port a Static IP Address

If you went through the [Static IP Address](static-ip-address.md) guide, this section may look familiar. If you haven't, take a look, because we'll be updating the `/etc/netplan/80-static-ip.yaml` we created. Optionally, you can create this file and add only the `eth0` interface configuration that we'll be working with here.

For the same reason that we gave the Pi's connection to our home network a static IP, we want to give our Pi's connection to the cluster a static IP: so the address doesn't change and it's always referenceable at the same address from the worker nodes.

1. Either create or edit the existing `/etc/netplan/80-static-ip.yaml` file to add the `eth0` interface
    ```
    me@zero:~$ sudo vi /etc/netplan/80-static-ip.yaml
    network:
      version: 2
      renderer: networkd
      wifis:
        wlan0:
          dhcp4: false
          addresses:
            - 192.168.0.2/24
          routes:
            - to: default
              via: 192.168.0.1 # the IP address of your gateway/router
          nameservers: # use google's nameservers
            addresses:
              - 8.8.8.8
              - 8.8.4.4
      ethernets:
        eth0:
          dhcp4: false # disables dynamic IP assignment on this interface
          addresses:
            - 10.4.4.1/24 # a private IP address of your choice
    ```
2. Apply the configuration by running
    ```
    me@zero:~$ sudo netplan generate
    me@zero:~$ sudo netplan apply
    ```
    Now, when running `ip addr`, you should see the static IP address reflected on the `eth0` interface.
    ```
    me@zero:~$ ip addr
    ...
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
      link/ether d8:3a:dd:3c:74:5b brd ff:ff:ff:ff:ff:ff
      inet 10.4.4.1/24 brd 10.4.4.255 scope global eth0
        valid_lft forever preferred_lft forever
      inet6 fe80::da3a:ddff:fe3c:745b/64 scope link
        valid_lft forever preferred_lft forever
    ...
    ```
    > If the changes don't take effect run a reboot: `sudo reboot`

## Configure DHCP with Kea

The first thing to be aware of is to not add a second DHCP server to your home network if there's one running already (if you're not sure, there's definitely one running already). We only want the Pi providing IP addresses to devices on its subnet.

1. Before creating our configuration file, we first want to back up the default DHCP4 configuration file provided by Kea so we have something to rollback to in the event things go south.
    ```
    me@zero:~$ sudo mv /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.backup
    ```
2. In a new `/etc/kea/kea-dhcp4.conf` file we'll add the following
    ```
    me@zero:~$ sudo vi /etc/kea/kea-dhcp4.conf
    {
      "Dhcp4": {
        "interfaces-config": {
          "interfaces": [ "eth0" ],
          "dhcp-socket-type": "raw"
        },
        "match-client-id": false,
        "valid-lifetime": 86400,
        "max-valid-lifetime": 86400,
        "subnet4": [{
          "pools": [ { "pool": "10.4.4.2-10.4.4.50" } ],
          "option-data": [{
            "name": "routers",
            "data": "10.4.4.1"
          }],
          "subnet": "10.4.4.0/24",
          "id": 1
        }],
        "loggers": [{
            "name": "*",
            "severity": "DEBUG"
        }]
      }
    }
    ```
    The above configuration results in the DHCP server listening for new clients on `eth0`, the Pi's on-board ethernet port. Each new client that gets connected will receive an IP address from the range `10.4.4.2` to `10.4.4.50`. If the client doesn't ask for a specific timeframe on its lease, the lease time will be `86400` seconds (24 hours) since I won't have a lot of different devices coming and going from the network. The server will also advise clients to use `10.4.4.1` as the default gateway.
    > I'm also setting `match-client-id` to `false` because I had two nodes with the same `client_id` which was causing them to be assigned the same IP address. This is defaulted to `true` and likely won't need to be changed. You can read more about it [here](https://kea.readthedocs.io/en/kea-1.6.1/arm/dhcp4-srv.html#using-client-identifier-and-hardware-address).
3. To update the configuration, run `sudo systemctl restart kea-dhcp4-server`.
4. If the Pi that this instruction set was ran on is plugged into an unmanaged switch, any additional nodes connected to the switch will receive an IP address within the specified `10.4.4.2` to `10.4.4.50` range and will show up in the `kea-leases4.csv` file
    ```
    me@zero:~$ cat /var/lib/kea/kea-leases4.csv
    address,hwaddr,client_id,valid_lifetime,expire,subnet_id,fqdn_fwd,fqdn_rev,hostname,state,user_context
    10.4.4.2,d8:3a:dd:3c:7a:16,ff:f8:ce:1b:a1:00:02:00:00:ab:11:75:ea:8f:29:16:c2:aa:53,600,1702165203,1,0,0,two,0,
    ```
