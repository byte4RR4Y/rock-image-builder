# rock-image-builder - Daily updated
Image builder for radxa Borads

# Please make use of the Issues and Discussions section

## Current supported Boards:
  - rock 3a
  - rock 4b
  - rock 4c
  - rock 4c plus
  - rock 4se (extensivly tested, works great)
  - rock 5a
  - rock 5b
This boards work sure if you install latest availible Kernel

# INSTALLATION:
------------------------------------------------------------
     git clone https://github.com/byte4RR4Y/rock-image-builder
     cd rock-image-builder
     chmod +x install.sh
     sudo ./install.sh
------------------------------------------------------------

# USAGE
# To build an SD-Card image:
    sudo ./build.sh
Will guide you through a menu to choose all options.

You will find your image in the output folder.

# Adding custom packages to install
    -If you want to add packages to install, append it to config/apt-packages.txt
     instead of modifying the Dockerfile

# Required Host system:
  - Debian/amd64 (bullseye, bookworm, MX 21 and MX23 are tested)
  - maybe Ubuntu works too, but the depencies are slightly different(install.sh is not working)

# What you can build?
## DEBIAN:
  - Testing
  - Experimental
  - Trixie
  - Sid
  - Bookworm
  - Bullseye

## Board:
  - rock3a
  - rock4b (maybe works for rock4a)
  - rock4c
  - rock4se
  - rock5a
  - rock5b

## Kernel
  - Standard Kernel of the Debian Suite
  - Lates availible Linux Kernel (Downloaded and Compiled)

## Kernelheaders
  - Install it or not

## Currently supported desktops:
  - none(Command line interface/tested)
  - xfce     (tested)
  - gnome    (tested)
  - mate
  - cinnamon
  - lxqt
  - lxde
  - unity
  - budgie
  - kde plasma

## Create Sudo User
  - Choose username and password

# Automating the build process by using the commandline is possible
Type './build.sh -h'
---------------------------------------------------
    -h, --help                      Show this help message and exit
    -s, --suite SUITE               Choose the Debian suite (e.g., testing, experimental, trixie)
    -B, --board                     Choose the Radxa Board
    --boardlist                     Show availible Boards
    -k, --kernel latest/standard    Choose which kernel to install
    -H, --headers yes/no            Install Kernelheaders
    -d, --desktop DESKTOP           Choose the desktop environment (e.g., xfce4, kde, none)
    -i, --interactive yes/no        Start an interactive shell in the docker container (yes/no)
                                    This only has an effect in kombination with -d or --desktop
    -u, --username USERNAME         Enter the username for the sudo user
    -p, --password PASSWORD         Enter the password for the sudo user
    -b                              Build the image with the specified configuration without asking
---------------------------------------------------

For example to build Debian testing with XFCE with latest Kernel:
---------------------------------------------------
     sudo ./build -s testing -B rock4se -d xfce4 -k latest -H no -u debian -p 123456 -i no -b
---------------------------------------------------


---------------------------------------------------
 # Contact to the developer: byte4rr4y@gmail.com #
---------------------------------------------------
