# Kubernetes Cluster

## Motivation

I've only worked with Kubernetes in a Cloud environment, which means I've not had to worry about a lot of the low-level Kubernetes concepts that the Cloud providers do such a good job of taking care of for us. That being said, I want to manually set up a bare-metal Kubernetes cluster from scratch to foray into the unknown and learn the concepts that are generally handled by cloud providers out of the box.

## Cluster Hardware

- 3x [Raspberry Pi 4 Model B, 4 GB RAM](https://www.adafruit.com/product/4296)
- 1x [Raspberry Pi 2 Model B, 1 GB RAM](https://www.adafruit.com/product/2358)
- 3x [Waveshare PoE Hat E](https://www.amazon.com/Raspberry-Ethernet-Standard-Compatible-Connecting/dp/B0974TK3KD)
- 1x [TP-Link TL SG1005P 5 Port Gigabit PoE Switch](https://www.amazon.com/TP-Link-Compliant-Shielded-Optimization-TL-SG1005P/dp/B07PPJTR15)
- 4x [SanDisk 32GB Ultra MicroSDHC Card](https://www.amazon.com/SanDisk-2-Pack-microSDXC-2x128GB-Adapter/dp/B08GY9NYRM)
- 1x [Samsung 870 EVO SATA III SSD, 1 TB](https://www.amazon.com/SAMSUNG-Inch-Internal-MZ-77E1T0B-AM/dp/B08QBJ2YMG)
- 4x [Monoprice Cat6 Ethernet Patch Cable, 0.5'](https://www.amazon.com/Monoprice-Cat6-Ethernet-Patch-Cable/dp/B01C68CVDC)
- 1x [Utronics Raspberry Pi Cluster Case](https://www.amazon.com/UCTRONICS-Upgraded-Enclosure-Raspberry-Compatible/dp/B09S11Q684)

## Guide

1. [Initial setup of the **primary** node](./01-initial-setup.md)
2. [Assign a static IP address to your primary node](./02-static-ip-address.md)
3. [Turn your primary node into a DHCP server for your cluster](./03-dhcp-server.md)
4. [Turn your primary node into an Internet gateway for your cluster](./04-internet-gateway.md)
5. [Initial setup of the **worker** node(s)](./01-initial-setup.md)
6. [Use public key authentication for worker node access](./05-ssh-public-key-authentication.md)
7. [Turn your Pi cluster into a Kubernetes cluster](./06-kubernetes-cluster.md)
8. [Install Metal LB](./07-metallb.md)
9. [Install the NGINX ingress controller](./08-ingress-nginx.md)
