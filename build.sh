#!/bin/bash

INTERACTIVE=no
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
BUILD=no
##########################################################################################################################
usage() {
    echo "Usage: $0 [-h|--help] [-s|--suite SUITE] [-d|--desktop DESKTOP] [-a|--additional ADDITIONAL] [-u|--username USERNAME] [-p|--password PASSWORD] [-b]"
    echo "-------------------------------------------------------------------------------------------------"
    echo "Options:"
    echo "  -h, --help                      Show this help message and exit"
    echo "  -B, --board                     Define a Rock-board"
    echo "  --boardlist                     Show list of supported boards"
    echo "  -s, --suite SUITE               Choose the Debian suite (e.g., testing, experimental, trixie)"
    echo "  -k, --kernel latest/standard    Choose which kernel to install"
    echo "  -H, --headers yes/no            Install Kernel headers"
    echo "  -d, --desktop DESKTOP           Choose the desktop environment."
    echo "                                  (none/xfce4/gnome/cinnamon/lxqt/lxde/unity/budgie/kde)"
    echo "                                  This only has an effect in kombination with -d or --desktop"
    echo "  -u, --username USERNAME         Enter the username for the sudo user"
    echo "  -p, --password PASSWORD         Enter the password for the sudo user"
    echo "  -i, --interactive yes/no        Start an interactive shell inside the container"
    echo "  -b                              Build the image with the specified configuration without asking"
    echo "-------------------------------------------------------------------------------------------------"
    echo "For example: $0 -s sid -d none -k latest -u USERNAME123 -p PASSWORD123 -b"
    exit 1
}

boardlist() {
    echo "Supported boards are:"
    echo "====================="
    echo "rock3a"
    echo "rock4b"
    echo "rock4c"
    echo "rock4se"
    echo "rock5a"
    echo "rock5b"
    exit 1
}
# Check if running with sudo
if [ "$UID" -ne 0 ]; then
    echo "This program needs sudo rights."
    echo "Run it with 'sudo $0'"
    exit 1
fi

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) usage;;
        -B|--board) BOARD="$2"; shift ;;
        --boardlist) boardlist ;;
        -s|--suite) SUITE="$2"; shift ;;
        -k|--kernel) KERNEL="$2"; shift ;;
        -H|--headers) HEADERS="$2"; shift ;;
        -d|--desktop) DESKTOP="$2"; shift ;;
        -u|--username) USERNAME="$2"; shift ;;
        -p|--password) PASSWORD="$2"; shift ;;
        -i|--interactive) INTERACTIVE="$2"; shift ;;
        -b) BUILD="yes" ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

if [ "$BOARD" == "rock4b" ]; then
  BOOTLOADER="boot-rock_pi_4.bin.gz"
elif [ "$BOARD" == "rock4c" ]; then
  BOOTLOADER="boot-rock_pi_4c.bin.gz"
elif [ "$BOARD" == "rock4se" ]; then
  BOOTLOADER="boot-rock_pi_4se.bin.gz"
elif [ "$BOARD" == "rock5a" ]; then
  BOOTLOADER="boot-rock_5a.bin.gz"
elif [ "$BOARD" == "rock5b" ]; then
  BOOTLOADER="boot-rock_5b.bin.gz"
elif [ "$BOARD" == "rock3a" ]; then
  BOOTLOADER="boot-rock_3a.bin.gz"
fi

echo "----------------------"
echo "cleaning build area..."
echo "----------------------"
sleep 2
rm .config
rm .rootfs.img
rm .rootfs.tar
rm -rf .rootfs/
rm config/rootfs_size.txt
echo ""
##########################################################################################################################
# Check if arguments are missing
if [ -z "$SUITE" ] || [ -z "$DESKTOP" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$KERNEL" ] || [ -z "$HEADERS" ] || [ -z "$BOARD" ]; then
##########################################################################################################################
info_text="HELP ME TO IMPROVE THIS PROGRAM\n\nSend an E-mail with suggestions to: byte4rr4y@gmail.com"
whiptail --title "Information" --msgbox "$info_text" 20 65
##########################################################################################################################
whiptail --title "Menu" --menu "Choose a Debian Suite" 20 65 6 \
"1" "testing" \
"2" "experimental" \
"3" "trixie" \
"4" "sid" \
"5" "bookworm" \
"6" "bullseye" 2> choice.txt
choice=$(cat choice.txt)

case $choice in
  1)
    echo "SUITE=testing" > .config
    ;;
  2)
    echo "SUITE=experimental" > .config
    ;;
  3)
    echo "SUITE=trixie" > .config
    ;;
  4)
    echo "SUITE=sid" > .config
    ;;
  5)
    echo "SUITE=bookworm" > .config
    ;;
  6)
    echo "SUITE=bullseye" > .config
    ;;
  *)
    echo "Invalid option"
    ;;
esac

rm choice.txt
##########################################################################################################################
whiptail --title "Menu" --menu "Choose a board" 20 65 6 \
"1" "rock3a" \
"2" "rock4b(maybe also works for rock4a)" \
"3" "rock4c" \
"4" "rock4se" \
"5" "rock5a" \
"6" "rock5b" 2> choice.txt
choice=$(cat choice.txt)

case $choice in
  1)
    echo "BOARD=rock3a" >> .config
    ;;
  2)
    echo "BOARD=rock4b" >> .config
    ;;
  3)
    echo "BOARD=rock4c" >> .config
    ;;
  4)
    echo "BOARD=rock4se" >> .config
    ;;
  5)
    echo "BOARD=rock5a" >> .config
    ;;
  6)
    echo "BOARD=rock5b" >> .config
    ;;
  *)
    echo "Invalid option"
    ;;
esac

rm choice.txt
##########################################################################################################################
whiptail --title "Menu" --menu "Choose Kernel to install" 20 65 6 \
"1" "Standardkernel of the Debian Suite" \
"2" "Download and compile latest availible Kernel" 2> choice.txt
choice=$(cat choice.txt)

case $choice in
  1)
    echo "KERNEL=standard" >> .config
    ;;
  2)
    echo "KERNEL=latest" >> .config
    ;;
  *)
    echo "Invalid option"
    ;;
esac

rm choice.txt
##########################################################################################################################
whiptail --title "Menu" --menu "KERNEL HEADERS" 20 65 6 \
"1" "Install Kernel headers" \
"2" "Do not install Kernel headers" 2> choice.txt
choice=$(cat choice.txt)

case $choice in
  1)
    echo "HEADERS=yes" >> .config
    ;;
  2)
    echo "HEADERS=no" >> .config
    ;;
  *)
    echo "Invalid option"
    ;;
esac

rm choice.txt
##########################################################################################################################
whiptail --title "Menu" --menu "Choose a Desktop option" 20 65 10 \
"1" "none" \
"2" "xfce" \
"3" "gnome" \
"4" "mate" \
"5" "cinnamon" \
"6" "lxqt" \
"7" "lxde" \
"8" "unity" \
"9" "budgie" \
"10" "kde" 2> choice.txt
choice=$(cat choice.txt)

case $choice in
  1)
    echo "DESKTOP=CLI" >> .config
    ;;
  2)
    echo "DESKTOP=xfce4" >> .config
    ;;
  3)
    echo "DESKTOP=gnome" >> .config
    ;;
  4)
    echo "DESKTOP=mate" >> .config
    ;;
  5)
    echo "DESKTOP=cinnamon" >> .config
    ;;
  6)
    echo "DESKTOP=lxqt" >> .config
    ;;
  7)
    echo "DESKTOP=lxde" >> .config
    ;;
  8)
    echo "DESKTOP=unity" >> .config
    ;;
  9)
    echo "DESKTOP=budgie" >> .config
    ;;
  10)
    echo "DESKTOP=kde" >> .config
    ;;
  *)
    echo "Invalid option"
    ;;
esac
rm choice.txt
##########################################################################################################################    

USERNAME=$(whiptail --title "Create sudo user" --inputbox "Enter username:" 20 65 3>&1 1>&2 2>&3)

# Passwort abfragen
PASSWORD=$(whiptail --title "Create sudo user" --passwordbox "Enter password:" 20 65 3>&1 1>&2 2>&3)

echo "USERNAME=${USERNAME}" >> .config
echo "PASSWORD=${PASSWORD}" >> .config
##########################################################################################################################
whiptail --title "Menu" --menu "Choose an option" 20 65 4 \
"1" "Start interactive shell in the container" \
"2" "Just build with the given configuration" 2> choice.txt

choice=$(cat choice.txt)

case $choice in
  1)
    echo "INTERACTIVE=yes" >> .config
    ;;
  2)
    echo "INTERACTIVE=no" >> .config
    ;;
  *)
    echo "Invalid option"
    ;;
esac
rm choice.txt
##########################################################################################################################
while IFS='=' read -r key value; do
    case "$key" in
    	SUITE)
    		SUITE="$value"
    		;;
        BOARD)
            BOARD="$value"
            ;;
        KERNEL)
            KERNEL="$value"
            ;;
        DESKTOP)
            DESKTOP="$value"
            ;;
        HEADERS)
            HEADERS="$value"
            ;;
        USERNAME)
            USERNAME="$value"
            ;;
        PASSWORD)
            PASSWORD="$value"
            ;;
        INTERACTIVE)
            INTERACTIVE="$value"
            ;;
        *)
            ;;
    esac
done < .config
fi

if [ "$BUILD" == "no" ]; then
##########################################################################################################################
    display_variables() {
        whiptail --title "Is this configuration correct?" --yesno \
        "SUITE=$SUITE\nBoard=$BOARD\nKERNEL=$KERNEL\nHEADERS=$HEADERS\nDESKTOP=$DESKTOP\nUSERNAME=$USERNAME\nPASSWORD=$PASSWORD\nINTERACTIVE=$INTERACTIVE" \
        20 65
    }

    display_variables
    if [ $? -eq 0 ]; then
        BUILD=yes
    else
        BUILD=no
    fi
fi
##########################################################################################################################
if [[ "$BUILD" == "yes" ]]; then
    while IFS='=' read -r key value; do
        case "$key" in
    	    SUITE)
    		    SUITE="$value"
    		    ;;
            DESKTOP)
                DESKTOP="$value"
                ;;
            KERNEL)
                KERNEL="$value"
                ;;
            BOARD)
                BOARD="$value"
                ;;
            HEADERS)
                HEADERS="$value"
                ;;
            USERNAME)
                USERNAME="$value"
                ;;
            PASSWORD)
                PASSWORD="$value"
                ;;
            INTERACTIVE)
                INTERACTIVE="$value"
                ;;
            *)
                ;;
        esac
    done < .config

##########################################################################################################################
    if [ "$KERNEL" == "latest" ]; then
      echo "0" > config/kernel_status
      xfce4-terminal --title="Building Kernel" --command="config/makekernel.sh $HEADERS" &
    fi
##########################################################################################################################    
    echo "Building Docker image..."
    sleep 1
    docker kill debiancontainer
    docker rm debiancontainer
    docker rmi debian:finest
    docker build --build-arg "SUITE="$SUITE --build-arg "DESKTOP="$DESKTOP --build-arg "USERNAME="$USERNAME --build-arg "PASSWORD="$PASSWORD --build-arg "KERNEL="$KERNEL --build-arg "HEADERS="$HEADERS -t debian:finest -f config/Dockerfile .
##########################################################################################################################    
    docker run --platform=aarch64 -dit --name debiancontainer debian:finest /bin/bash  

    if [ "$KERNEL" == "latest" ]; then
      echo "Waiting for Kernel compilation..."
      while [[ "$(cat config/kernel_status)" != "1" ]]; do
        sleep 2
      done
      rm config/kernel_status
      docker cp kernel*.zip debiancontainer:/
      docker cp config/installkernel.sh debiancontainer:/
      docker exec debiancontainer bash -c '/installkernel.sh kernel-*.zip'
      docker exec debiancontainer bash -c 'rm -rf /kernel*.zip'
      docker exec debiancontainer bash -c 'rm /installkernel.sh'
      docker exec debiancontainer bash -c 'u-boot-update'
      rm kernel-*.zip
    else
      echo "standard" > config/release
    fi

    docker cp config/resizeroot debiancontainer:/usr/local/bin
    docker exec debiancontainer bash -c 'chmod +x /usr/local/bin/resizeroot'
    
##########################################################################################################################    
    if [[ "$INTERACTIVE" == "yes" ]]; then
        docker attach debiancontainer
        docker start debiancontainer       
    fi
##########################################################################################################################    
    docker cp debiancontainer:/rootfs_size.txt config/
    ROOTFS=.rootfs.img
    rootfs_size=$(cat config/rootfs_size.txt)
    echo "Creating an empty rootfs image..."
    dd if=/dev/zero of=$ROOTFS bs=1M count=$((${rootfs_size} + 750)) status=progress
    rm config/rootfs_size.txt
    mkfs.ext4 -L rootfs $ROOTFS -F
    mkfs.ext4 ${ROOTFS} -L rootfs -F
    mkdir -p .loop/root
    mount ${ROOTFS} .loop/root
    docker export -o .rootfs.tar debiancontainer
    tar -xvf .rootfs.tar -C .loop/root
    
    docker kill debiancontainer
    mkdir -p output/Debian-${SUITE}-${DESKTOP}-build-${TIMESTAMP}/.qemu
    rm .loop/root/.dockerenv
    cp .loop/root/boot/vmlinuz* output/Debian-${SUITE}-${DESKTOP}-build-${TIMESTAMP}/.qemu/vmlinuz
    cp .loop/root/boot/initrd* output/Debian-${SUITE}-${DESKTOP}-build-${TIMESTAMP}/.qemu/initrd.img
    cp .loop/root/lib/linux-image-${BUILD}/rockchip/rk3399-rock-4se.dtb output/Debian-${SUITE}-${DESKTOP}-build-${TIMESTAMP}/.qemu/
    umount .loop/root

    e2fsck -f ${ROOTFS}
    gzip ${ROOTFS}
    mkdir -p output/Debian-${SUITE}-${DESKTOP}-build-${TIMESTAMP}/.qemu
    RELEASE=$(cat config/release)
    if [ "$DESKTOP" == "none" ]; then
      DESKTOP="CLI"
    fi
    zcat config/${BOOTLOADER} ${ROOTFS}.gz > "output/Debian-${SUITE}-${DESKTOP}-build-${TIMESTAMP}/Debian-${SUITE}-${DESKTOP}-Kernel-${RELEASE}.img"
    chown -R ${SUDO_USER}:${SUDO_USER} output/
    rm -rf .loop/root .loop/ .rootfs.img .rootfs.tar "${ROOTFS}.gz"
##########################################################################################################################
    filesize=$(stat -c %s "output/Debian-${SUITE}-${DESKTOP}-build-${TIMESTAMP}/Debian-${SUITE}-${DESKTOP}-Kernel-${RELEASE}.img")
    if [ $filesize -gt 1073741824 ]; then
        echo "--------------------------------------"
        echo "CONGRATULATION, BUILD WAS SUCCESSFULL!"
        echo "--------------------------------------"
    else
        echo "--------------------------------"
        echo "SORRY, BUILD WAS NOT SUCCESSFULL"
        echo "--------------------------------"
    fi
    rm config/release
fi