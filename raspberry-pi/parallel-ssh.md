# Set Up Parallel SSH to Run a Single Command on Multiple Servers at Once

## Motivation

When doing admin work across multiple machines, you'll often notice yourself running the same command on many different servers. Luckily there's software that lets us run a command, entered from a node on a LAN, across multiple servers at once.

## Install and Configure `pssh`

`pssh` is a command line utility tool that lets us run a single command across multiple servers at once.

1. Install `pssh`. I'm working with a cluster of a few servers with a primary node that controls them all, so I'm going to install it on my primary node.
    ```
    me@one:~$ sudo apt install pssh
    ```
2. Create a PSSH `host_file` to determine which servers the given command will run on:
    ```
    me@one.local~$ vi ~/.pssh_host_file
    ```
    and enter the hosts on which to duplicate the command:
    ```
    # ~/.pssh_host_file
    localhost # if you want to include the server that's running the `pssh` command
    me@two.local
    me@three.local
    ```
    > For this to work, you'll want to have [SSH public key authentication](./ssh-public-key-authentication.md) set up to avoid the need to enter passwords for each server (including `localhost` by running `cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys`)
3. If you run the command `pssh`, you'll notice it's not found even though we installed it:
    ```
    me@one:~$ pssh
    Command 'pssh' not found, did you mean:
      command 'bssh' from deb avahi-ui-utils (0.8-10ubuntu1)
      command 'mssh' from deb mssh (2.2-5.1)
      command 'pdsh' from deb pdsh (2.34-0.2)
      command 'ppsh' from deb ppsh (1.10-2build2)
      command 'cssh' from deb clusterssh (4.16-4)
      command 'zssh' from deb zssh (1.5c.debian.1-9)
      command 'posh' from deb posh (0.14.1)
      command 'sssh' from deb guile-ssh (0.16.3-1)
      command 'ssh' from deb openssh-client (1:9.3p1-1ubuntu3)
    Try: sudo apt install <deb name>
    ```
    This is because, according to the docs:
    ```
    To avoid any conflicts with the putty package, all of the programs have been
    renamed.

    parallel-ssh is pssh
    parallel-scp is pscp
    parallel-rsync is prsync
    parallel-nuke is pnuke
    parallel-slurp is pslurp
    ```
    So, we're going to create a symlink to make `pssh` the command since `parallel-ssh` is a bit long-winded.
    ```
    me@one:~$ sudo ln -s /usr/bin/parallel-ssh /usr/bin/pssh
    ```
4. Test the command:
    ```
    me@one:~$ pssh -i -h ~/.pssh_host_file uptime
    [1] 03:33:18 [SUCCESS] localhost
    03:33:18 up  1:12,  1 user,  load average: 0.00, 0.02, 0.00
    [2] 03:33:19 [SUCCESS] me@two.local
    03:33:19 up  1:12,  0 user,  load average: 0.08, 0.02, 0.01
    [3] 03:33:25 [SUCCESS] me@three.local
    03:33:25 up  1:11,  0 user,  load average: 0.08, 0.05, 0.01
    ```
    Optionally, we can alias `pssh` to always include the `-h ~/.pssh_host_file` flag to save us some more keystrokes.
    ```
    me@one:~$ echo "alias pssh=\"pssh -h ~/.pssh_host_file\"" >> ~/.bashrc && . ~/.bashrc
    me@one:~$ pssh -i hostname
    [1] 04:43:55 [SUCCESS] localhost
    one
    [2] 04:43:56 [SUCCESS] me@two.local
    two
    [3] 04:44:01 [SUCCESS] me@three.local
    three
    ```
5. If you try running an elevated command with `sudo`, you'll get an error along the lines of `sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper`. To circumvent this we can create a wrapper around our `pssh` command that takes a password. We're going to call it `spssh`.
    ```
    me@one:~$ sudo vi /usr/local/bin/spssh
    #!/bin/bash
    if [ "$*" == "" ]; then
        echo "Please enter a command:"
        echo "  > usage: spssh COMMAND"
        exit 1;
    fi

    read -s -p "Password: " pass

    echo "$pass" | pssh -h ~/.pssh_host_file -i -x '-tt' -t 1800 -I "$*"
    ```
    - The `-x` argument lets us pass in the `-tt` `ssh` argument, which forces tty allocation
    - The `-t` argument increases the default `pssh` timeout of 30 seconds to 1800 seconds

    Now we can make our new command executable and run `sudo` commands on multiple nodes at once:
    ```
    me@one:~$ sudo chmod +x /usr/local/bin/spssh
    me@one:~$ spssh sudo apt -y update
    Password: [1] 04:35:08 [SUCCESS] localhost
    [sudo] password for me:
    Hit:1 http://ports.ubuntu.com/ubuntu-ports mantic InRelease
    Hit:2 http://ports.ubuntu.com/ubuntu-ports mantic-updates InRelease
    Hit:3 http://ports.ubuntu.com/ubuntu-ports mantic-backports InRelease
    Hit:4 http://ports.ubuntu.com/ubuntu-ports mantic-security InRelease
    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    All packages are up to date.
    Stderr: Connection to localhost closed.
    [2] 04:35:09 [SUCCESS] me@two.local
    [sudo] password for me:
    Hit:1 http://ports.ubuntu.com/ubuntu-ports mantic InRelease
    Hit:2 http://ports.ubuntu.com/ubuntu-ports mantic-updates InRelease
    Hit:3 http://ports.ubuntu.com/ubuntu-ports mantic-backports InRelease
    Hit:4 http://ports.ubuntu.com/ubuntu-ports mantic-security InRelease
    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    All packages are up to date.
    Stderr: Connection to two.local closed.
    [3] 04:35:29 [SUCCESS] me@three.local
    [sudo] password for me:
    Hit:1 http://ports.ubuntu.com/ubuntu-ports mantic InRelease
    Hit:2 http://ports.ubuntu.com/ubuntu-ports mantic-updates InRelease
    Hit:3 http://ports.ubuntu.com/ubuntu-ports mantic-backports InRelease
    Hit:4 http://ports.ubuntu.com/ubuntu-ports mantic-security InRelease
    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    All packages are up to date.
    Stderr: Connection to three.local closed.
    ```
