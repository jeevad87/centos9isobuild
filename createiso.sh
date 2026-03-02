#!/bin/bash
#
# ==============================================================
#  Custom CentOS 9 ISO Builder
#
#  Author      : Jeeva D [Linux SME]
#  Created On  : 02-Mar-2026
#
#  Description :
#    This script automates:
#      - CentOS Stream 9 ISO download
#      - RPM package download
#      - Custom ISO generation with Kickstart
#      - Download-only mode for ISO and RPMs
#
#  Supported Modes:
#      --isodownload / --isopath
#      --rpmdownload / --rpmpath
#      --isodownloadonly
#      --rpmdownloadonly
#
# ==============================================================
set -euo pipefail

########################################
# Variables
########################################

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KS_FILE="$BASE_DIR/ks.cfg"
ISO_FILE="$BASE_DIR/custom_centos_9_$(date +%s).iso"
ISO_ISO_LNX_FILE="$BASE_DIR/isolinux.cfg"
ISO_GRUB_FILE="$BASE_DIR/grub.cfg"
ISO_CREATE_DIR="$BASE_DIR/geniso_$(date +%s)"
RPMS_DOWNLOAD_DIR="$ISO_CREATE_DIR/Packages"
RPMS_LIST_FILE="$BASE_DIR/cleancentosrpms.list"

ISO_MODE=""
ISO_PATH=""
RPM_MODE=""
RPM_PATH=""
ISO_DOWNLOAD_ONLY=""
RPM_DOWNLOAD_ONLY=""

CENTOS_ISO_URL="https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso"

########################################
# Help Function
########################################

usage() {
cat <<EOF

Custom CentOS 9 ISO Builder

USAGE:
  $0 [OPTIONS]

BUILD MODE (Choose one ISO and one RPM option)

ISO OPTIONS:
  --isodownload
  --isopath=/full/path.iso

RPM OPTIONS:
  --rpmdownload
  --rpmpath=/full/path_dir

DOWNLOAD ONLY MODE:
  --isodownloadonly=/path     Download ISO only and exit
  --rpmdownloadonly=/path     Download RPMs only and exit

OTHER:
  --help

EXAMPLES:

Build ISO:
  $0 --isodownload --rpmdownload
  $0 --isopath=/tmp/centos.iso --rpmpath=/tmp/rpms

Download Only:
  $0 --isodownloadonly=/tmp
  $0 --rpmdownloadonly=/tmp/rpms
  $0 --isodownloadonly=/tmp --rpmdownloadonly=/tmp/rpms

EOF
exit 1
}

########################################
# Argument Parsing
########################################

if [[ $# -eq 0 ]]; then
    echo "Error: No arguments provided."
    usage
fi

for arg in "$@"
do
    case $arg in
        --help)
            usage
            ;;
        --isodownload)
            [[ -n "$ISO_MODE" ]] && { echo "Error: Multiple ISO options."; usage; }
            ISO_MODE="download"
            ;;
        --isopath=*)
            [[ -n "$ISO_MODE" ]] && { echo "Error: Multiple ISO options."; usage; }
            ISO_MODE="local"
            ISO_PATH="${arg#*=}"
            ;;
        --rpmdownload)
            [[ -n "$RPM_MODE" ]] && { echo "Error: Multiple RPM options."; usage; }
            RPM_MODE="download"
            ;;
        --rpmpath=*)
            [[ -n "$RPM_MODE" ]] && { echo "Error: Multiple RPM options."; usage; }
            RPM_MODE="local"
            RPM_PATH="${arg#*=}"
            ;;
        --isodownloadonly=*)
            ISO_DOWNLOAD_ONLY="${arg#*=}"
            ;;
        --rpmdownloadonly=*)
            RPM_DOWNLOAD_ONLY="${arg#*=}"
            ;;
        *)
            echo "Error: Unknown argument '$arg'"
            usage
            ;;
    esac
done

########################################
# Download Only Mode
########################################

if [[ -n "$ISO_DOWNLOAD_ONLY" || -n "$RPM_DOWNLOAD_ONLY" ]]; then

    if [[ -n "$ISO_MODE" || -n "$RPM_MODE" ]]; then
        echo "Error: Download-only options cannot be combined with build options."
        usage
    fi

    if [[ -n "$ISO_DOWNLOAD_ONLY" ]]; then
        mkdir -p "$ISO_DOWNLOAD_ONLY"
        ISO_TARGET="$ISO_DOWNLOAD_ONLY/CentOS-Stream-9-latest-x86_64-boot.iso"

        echo "Downloading ISO to $ISO_TARGET"
        wget -O "$ISO_TARGET" "$CENTOS_ISO_URL"
        echo "ISO download completed."
    fi

    if [[ -n "$RPM_DOWNLOAD_ONLY" ]]; then
        mkdir -p "$RPM_DOWNLOAD_ONLY"

        echo "Downloading RPMs to $RPM_DOWNLOAD_ONLY"

        dnf download \
            --disablerepo="*" \
            --repofrompath=centos_baseos,https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/ \
            --repofrompath=centos_appstream,https://mirror.stream.centos.org/9-stream/AppStream/x86_64/os/ \
            --enablerepo=centos_baseos,centos_appstream \
            --resolve --alldeps \
            --destdir="$RPM_DOWNLOAD_ONLY" \
            $(cat "$RPMS_LIST_FILE")

        echo "RPM download completed."
    fi

    exit 0
fi

########################################
# Validation for Build Mode
########################################

if [[ -z "$ISO_MODE" ]]; then
    echo "Error: You must specify one ISO option."
    usage
fi

if [[ -z "$RPM_MODE" ]]; then
    echo "Error: You must specify one RPM option."
    usage
fi

########################################
# Prepare Directories
########################################

mkdir -p "$ISO_CREATE_DIR/mountiso"
mkdir -p "$RPMS_DOWNLOAD_DIR"

########################################
# Function
########################################

COPYISO () {
#    cp -rpf "$ISO_CREATE_DIR/mountiso/EFI" "$ISO_CREATE_DIR/"
#    cp -rpf "$ISO_CREATE_DIR/mountiso/isolinux" "$ISO_CREATE_DIR/"
#    cp -rpf "$ISO_CREATE_DIR/mountiso/images" "$ISO_CREATE_DIR/"
#    cp -rpf "$ISO_CREATE_DIR/mountiso/LICENSE" "$ISO_CREATE_DIR/"
    rsync -a \
  --include=".discinfo" \
  --include=".treeinfo" \
  --include="media.repo" \
  --include="LICENSE*" \
  --include="images/***" \
  --include="EFI/***" \
  --include="isolinux/***" \
  --exclude="*" \
  "$ISO_CREATE_DIR/mountiso/" "$ISO_CREATE_DIR/"

    umount "$ISO_CREATE_DIR/mountiso"
    rm -rf "$ISO_CREATE_DIR/mountiso"
}

########################################
# ISO Handling
########################################

if [[ "$ISO_MODE" == "local" ]]; then

    [[ ! -f "$ISO_PATH" ]] && { echo "Error: ISO not found: $ISO_PATH"; exit 1; }

    mount "$ISO_PATH" "$ISO_CREATE_DIR/mountiso"
    COPYISO

elif [[ "$ISO_MODE" == "download" ]]; then

    ISO_DL="$ISO_CREATE_DIR/CentOS-Stream-9-latest-x86_64-boot.iso"

    wget -O "$ISO_DL" "$CENTOS_ISO_URL"
    mount "$ISO_DL" "$ISO_CREATE_DIR/mountiso"
    COPYISO
fi

########################################
# RPM Handling
########################################

if [[ "$RPM_MODE" == "local" ]]; then

    [[ ! -d "$RPM_PATH" ]] && { echo "Error: RPM directory not found: $RPM_PATH"; exit 1; }

    cp -rpf "$RPM_PATH"/* "$RPMS_DOWNLOAD_DIR/"

elif [[ "$RPM_MODE" == "download" ]]; then

    echo "Downloading RPMs..."

    dnf download \
        --disablerepo="*" \
        --repofrompath=centos_baseos,https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/ \
        --repofrompath=centos_appstream,https://mirror.stream.centos.org/9-stream/AppStream/x86_64/os/ \
        --enablerepo=centos_baseos,centos_appstream \
        --resolve --alldeps \
        --destdir="$RPMS_DOWNLOAD_DIR" \
        $(cat "$RPMS_LIST_FILE")
fi

########################################
# Create Repo
########################################

createrepo "$ISO_CREATE_DIR"

cp -rpf "$KS_FILE" "$ISO_CREATE_DIR/ks.cfg"
cp -rpf "$ISO_GRUB_FILE" "$ISO_CREATE_DIR/EFI/BOOT/grub.cfg"
cp -rpf "$ISO_ISO_LNX_FILE" "$ISO_CREATE_DIR/isolinux/isolinux.cfg"

########################################
# Build ISO
########################################

xorriso -as mkisofs -o "$ISO_FILE" \
  -isohybrid-mbr /usr/share/syslinux/isohdpfx.bin \
  -c isolinux/boot.cat \
  -b isolinux/isolinux.bin \
     -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e images/efiboot.img \
     -no-emul-boot \
  -isohybrid-gpt-basdat \
  -V "CS9_CUSTOM" \
  "$ISO_CREATE_DIR"

rm -rf "$ISO_CREATE_DIR"

echo ""
echo "Custom ISO created successfully:"
echo "$ISO_FILE"
