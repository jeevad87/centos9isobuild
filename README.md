# centos9isobuild
```bash
git cone https://github.com/jeevad87/centos9isobuild.git
cd centos9isobuild
chmod +x createiso.sh
```

if you have the rpm list and iso already refe below example
```bash
./createiso.sh --isopath=../CentOS-Stream-9-latest-x86_64-boot.iso --rpmpath=../geniso/Packages

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
./createiso.sh --help
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
