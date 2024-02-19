# Set up a Plex Media Server

## Motivation

[Plex Media Server](https://www.plex.tv/media-server-downloads/) is a fantastic way to aggregate movies, television shows, music, and more and serve them to clients on your home network. I have an external hard drive that contains all of my media, so I'll be connecting that and pointing my Plex Media Server to it.

## Install Plex Media Server

1. Optionally -- to get the most out of Plex -- you can connect an external hard drive with your own media. You can follow the 'Attach and Format the Drive' instructions [here](nfs.md) to get that set up.
2. Install the Plex Media Server `.deb` using `wget`
    ```
    me@zero:~$ wget -O plex.deb https://downloads.plex.tv/plex-media-server-new/1.40.0.7998-c29d4c0c8/debian/plexmediaserver_1.40.0.7998-c29d4c0c8_arm64.deb
    me@zero:~$ sudo dpkg -i plex.deb
    ```
3. In a browser from a computer on the same network as the Plex server, navigate to `http://<IP_ADDRESS_OF_SERVER>:32400/web` to configure the name of the library and the location of the files the library should be looking for (if you have your own media library)

    > To get the IP address of the server, simply run `hostname -I` on the server
