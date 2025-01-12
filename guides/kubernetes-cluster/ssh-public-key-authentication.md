# Use Public Key SSH Authentication on Your Worker Nodes

## Motivation

When SSHing in and out of your worker nodes, it gets a bit strenuous to constantly be entering a password (especially if it's a strong one). That's why we're going to enable public key authentication to circumvent that problem altogether.

## Creating an SSH Key and Updating `authorized_keys` on the Worker Node

To enable SSH key auth, the control-plane node needs to have a key to advertise to the worker nodes when trying to connect, and the worker nodes need to recognie that key.

1. On the control-plane node of the cluster, first check to see if an SSH key already exists. If not, we'll create one.
    ```
    me@kubernetes-primary:~$ ls ~/.ssh/id_rsa.pub
    # nothing's there, so we'll create one
    me@kubernetes-primary:~$ ssh-keygen -t rsa -C "your@emailaddress.com"
    ```
2. Add our control-plane node's public key to the worker node's `~/.ssh/authorized_keys` file. We can do this with a single command, and it'll be the last time you have to enter the password to access the worker node.
    ```
    me@kubernetes-primary:~$ cat ~/.ssh/id_rsa.pub | ssh me@one.local -T "cat >> ~/.ssh/authorized_keys"
    ```
    Alternatively, you can use the server's IP address:
    ```
    me@kubernetes-primary:~$ cat ~/.ssh/id_rsa.pub | ssh me@10.4.4.2 -T "cat >> ~/.ssh/authorized_keys"
    ```
3. We can now SSH into our worker node without entering a password:
    ```
    me@kubernetes-primary:~$ ssh one.local
    # no password required
    ```

## Next Step

- [Transform your Pi cluster into a Kubernetes cluster](./kubernetes-cluster.md)