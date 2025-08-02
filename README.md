# Arch Setup
Install and setup Arch Linux.

## Disclaimer
The scripts found in this repository are meant to setup Arch Linux how I like it and were not created with the intention to be used by others.
If you do wish to use the scripts, make sure you understand what they do before you run them. In other words, use at your own risk!

## Prerequisits
- A tool, such as [Rufus](rufus.ie/en/), to create a USB installation medium.
- Disable Secure Boot on machine.

## Pre-Installation
1. Acquire an Installation Image
    - Download an ISO file from the [official download page](archlinux.org/download/).
    - **TODO: verification**
2. Connect to the Internet ([iwctl](wiki.archlinux.org/title/lwd#iwctl))
    - Get device name by listing devices:
    ```
    iwctl device list
    ```
    - Initiate scan for networks:
    ```
    iwctl station DEVICE_NAME scan
    ```
    - Get list of available networks and their SSID:
    ```
    iwctl station DEVICE_NAME get-networks
    ```
    - Connect to a network:
    ```
    iwctl station DEVICE_NAME connect NETWORK_SSID
    ```
    - Verify connection:
    ```
    ping archlinux.org
    ```

## Usage
```
curl -LO https://github.com/SandorJJ/arch-setup/raw/refs/heads/main/arch-install.sh
```
