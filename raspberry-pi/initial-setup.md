# Initial Server Setup

## Motivation

> "The beginning is the most important part of the work."
>
> -- <cite>Plato</cite>

As with everything, we need to start somewhere. There are a myriad of different ways to get set up, but this is the route I take.

## Getting an OS onto a Pi

I use the [Raspberry Pi Imager](https://www.raspberrypi.com/software/) to install Ubuntu Server onto a [Micro SD card](https://www.amazon.com/s?k=micro+sd+card).

1. Fire up the Imager, connect the Micro SD card to your machine, and click through. Most of it is pretty self-explanitory, but here are some notes:

    - Ubuntu Server will be under *Other general-purpose OS*
    - After clicking *Next* for the first time, you'll have the option to set advanced settings. I generally set up a hostname, username and password, wireless LAN (for servers that won't be bridged, in other words: only the primary node of a cluster), and enable SSH via password authentication.
2. Once it's done pushing the OS to the Micro SD card, remove the card from your machine, plug it into the Pi, and power it up.

## Connecting to the Pi and Initial Setup

1. Using a machine that's on the same network as your Pi, connect to your Pi using the `USER` and `HOSTNAME` you set up using the Imager:
  ```
  $ ssh USER@HOSTNAME.local
  ```
2. Once connected run the following commands to get the Pi set up
  ```
  $ sudo apt update
  $ sudo apt upgrade
  $ sudo reboot
  ```
3. That's it! Your Pi is ready to be hacked on.

> If you're building a cluster of multiple Pis, this guide can be followed for each one but note that the `sudo apt update` and `sudo apt upgrade` commands won't work on the worker nodes unless a) you've set up a wireless LAN when imaging the OS or b) you've followed the [Internet gateway guide](./internet-gateway.md) to give the worker node Internet access.
