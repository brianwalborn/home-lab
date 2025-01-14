# Set up NFS

## Motivation

To allow nodes in a network to have access to a shared pool of storage, I want to set up a node to be a network file system (NFS) server using an external hard drive.

## Attach and Format the Drive

We first need to connect and set up the drive. Any external hard drive should do, but I went with [this](https://www.amazon.com/SAMSUNG-250GB-Internal-MZ-77E250B-AM/dp/B08QBJ2YMG?th=1) 1TB Samsung SSD because I had it laying around.

1. Connect the drive to a USB port on the host node
2. To find out the name of the drive we just attached, we can run `lsblk`. Generally, the first attached drive will be `/dev/sda`, the second will be `/dev/sdb`, third `/dev/sdc`, and so on.
    ```
    me@host:~$ lsblk
    sda           8:0    0 931.5G  0 disk
    └─sda1        8:1    0 931.5G  0 part
    mmcblk0     179:0    0  29.7G  0 disk
    ├─mmcblk0p1 179:1    0   512M  0 part /boot/firmware
    └─mmcblk0p2 179:2    0  29.2G  0 part /
    ```
    In my case, it's the first drive I've attached so it's named `/dev/sda`. I've also previously created the `ext4` partition that we need which is why we see `sda1`.

    > If you're working with a new SSD and don't have an existing partition, run these commands. Be sure to replace `sda` with the name of your drive if it's different.
    > ```
    > $ sudo parted -s /dev/sda mklabel gpt
    > $ sudo parted --a optimal /dev/sda mkpart primary ext4 0% 100%
    > $ sudo mkfs -t ext4 /dev/sda1
    > ```
3. To actually be able to use the drive, we need to first create a mount point, then mount the drive.
    ```
    me@host:~$ sudo mkdir -p /nfs/default
    me@host:~$ sudo mount /dev/sda1 /nfs/default
    ```

## Install and Configure nfs-kernel-server and Clients

1. To install the `nfs-kernel-server` software, run the below command
    ```
    me@host:~$ sudo apt install nfs-kernel-server
    ```
    and add our mountpoint to the `/etc/exports` file and apply the config
    ```
    me@host:~$ sudo vi /etc/exports
    ...
    /nfs/default *(rw,async,no_subtree_check,no_root_squash)
    me@host:~$ sudo exportfs -a
    ```
2. On the client node(s), install `nfs-common` to be able to access the shared drive and mount the shared drive to the system
    ```
    me@client:~$ sudo apt install nfs-common
    me@client:~$ sudo mkdir -p /nfs/default
    me@client:~$ sudo mount <HOST_IP>:/nfs/default /nfs/default/
    ```
