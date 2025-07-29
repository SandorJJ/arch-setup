# Arch Setup
Install and setup Arch Linux.

## Disclaimer
**The installation script only supports BIOS boot mode.**

## Prerequisits
- A tool, such as [Rufus](rufus.ie/en/), to create USB installation medium.
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
    iwctl station NAME scan
    ```
    - Get list of available networks and their SSID:
    ```
    iwctl station NAME get-networks
    ```
    - Connect to a network:
    ```
    iwctl station NAME connect SSID
    ```
    - Verify connection:
    ```
    ping archlinux.org
    ```

