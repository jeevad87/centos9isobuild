# Custom CentOS 9 ISO Builder

>Author      : Jeeva D # Created On  : 28-Feb-2026

# Quick Verification 
```bash 
[root@linux-infra ~]# which wget
/usr/bin/wget
[root@linux-infra ~]# which dnf
/usr/bin/dnf
[root@linux-infra ~]# which createrepo
/usr/bin/createrepo
[root@linux-infra ~]# which xorriso
/usr/bin/xorriso
[root@linux-infra ~]# ls /usr/share/syslinux/isohdpfx.bin
/usr/share/syslinux/isohdpfx.bin
[root@linux-infra ~]#

```
# Install script dependency packages if above are missing 
```bash
> wget              # download the iso
> dnf-plugins-core  # download the rpms
> createrepo_c      # creating repo with downloading packages
> xorriso           # build iso
> syslinux          # Without this → your ISO will NOT be hybrid bootable.
> util-linux        # is a core Linux package that provides essential system utilities lke mounting iso other things
```
```bash
[root@linux-infra ~]# sudo dnf install -y wget dnf-plugins-core createrepo_c  xorriso syslinux util-linux
```
# Download and execute once the dependecy are completed
```bash
[root@linux-infra ~]# git cone https://github.com/jeevad87/centos9isobuild.git
[root@linux-infra ~]# cd centos9isobuild
[root@linux-infra ~]# chmod +x createiso.sh
```

if you have the rpm list and iso already refe below example
```bash
[root@linux-infra ~]# ./createiso.sh --isopath=../CentOS-Stream-9-latest-x86_64-boot.iso --rpmpath=../geniso/Packages

......omitted outputs.....

xorriso : UPDATE :  93.00% done, estimate finish Mon Mar 02 20:15:35 2026
xorriso : UPDATE :  93.73% done, estimate finish Mon Mar 02 20:15:35 2026
xorriso : UPDATE :  94.44% done, estimate finish Mon Mar 02 20:15:36 2026
xorriso : UPDATE :  95.13% done, estimate finish Mon Mar 02 20:15:36 2026
xorriso : UPDATE :  95.98% done, estimate finish Mon Mar 02 20:15:36 2026
xorriso : UPDATE :  96.75% done, estimate finish Mon Mar 02 20:15:36 2026
xorriso : UPDATE :  97.49% done, estimate finish Mon Mar 02 20:15:37 2026
xorriso : UPDATE :  98.67% done
xorriso : UPDATE :  99.48% done
ISO image produced: 2176272 sectors
Written to medium : 2176272 sectors at LBA 0
Writing to 'stdio:/opt/newiso/iso-project/isobuild/custom_centos_9_1772462437.iso' completed successfully.


Custom ISO created successfully:
/opt/newiso/iso-project/isobuild/custom_centos_9_1772462437.iso

```
if you not have any suource like boot iso file and rpm list refer help page
```bash
[root@linux-infra ~]# ./createiso.sh --help
USAGE:
  createiso.sh [OPTIONS]

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
  createiso.sh --isodownload --rpmdownload
  createiso.sh --isopath=/tmp/centos.iso --rpmpath=/tmp/rpms

Download Only:
  createiso.sh --isodownloadonly=/tmp
  createiso.sh --rpmdownloadonly=/tmp/rpms
  createiso.sh --isodownloadonly=/tmp --rpmdownloadonly=/tmp/rpms

```
##  Description :
  This script automates:
      - CentOS Stream 9 ISO download
      - RPM package download
      - Custom ISO generation with Kickstart
      - Download-only mode for ISO and RPMs

```bash
  Supported Modes:`
      --isodownload / --isopath`
      --rpmdownload / --rpmpath`
      --isodownloadonly`
      --rpmdownloadonly`
```
# File system created by iso
```bash
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                       8:0    0   60G  0 disk
├─sda1                    8:1    0    2M  0 part
├─sda2                    8:2    0    1G  0 part /boot
├─sda3                    8:3    0   49G  0 part
│ ├─VolGroup00-LogVol00 253:0    0   10G  0 lvm  /
│ ├─VolGroup00-LogVol06 253:1    0    4G  0 lvm  [SWAP]
│ ├─VolGroup00-LogVol05 253:2    0    5G  0 lvm  /home
│ ├─VolGroup00-LogVol04 253:3    0    5G  0 lvm  /tmp
│ ├─VolGroup00-LogVol03 253:4    0    2G  0 lvm  /var/log/audit
│ ├─VolGroup00-LogVol02 253:5    0    2G  0 lvm  /var/log
│ └─VolGroup00-LogVol01 253:6    0    2G  0 lvm  /var
└─sda4                    8:4    0   10G  0 part
sr0                      11:0    1 14.4G  0 rom
```
