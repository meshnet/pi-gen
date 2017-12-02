# pi-gen

_This version of Raspbian's pi-gen is used to make the system images for NodeOS_

### TODO

1. Documentation

## Dependencies

On Debian-based systems:

```bash
apt-get install quilt parted realpath qemu-user-static debootstrap zerofree pxz zip \
dosfstools bsdtar libcap2-bin grep rsync xz-utils
```

The file `depends` contains a list of tools needed.  The format of this
package is `<tool>[:<debian-package>]`.

## Config

Upon execution, `build.sh` will source the file `config` in the current
working directory.  This bash shell fragment is intended to set needed
environment variables.

The following environment variables are supported:

* `IMG_NAME` (Default: NodeOS)

   The name of the image to build with the current stage directories.  This is
   set to `IMG_NAME=NodeOS` by default for an unmodified meshnet/pi-gen build,
   but you should use something else for a customized version.  Export files
   in stages may add suffixes to `IMG_NAME`.

* `DEBUG` (Default: 0)

   Setting this to 1 will execute the debug stages after executing the normal
   stages.  Debug stages work similar to normal stages except that export files
   in these stages will only be used on debug builds.  With this set to 1 both
   a normal and a debug build will be exported.

* `APT_PROXY` (Default: unset)

   If you require the use of an apt proxy, set it here.  This proxy setting
   will not be included in the image, making it safe to use an `apt-cacher` or
   similar package for development.

   If you have Docker installed, you can set up a local apt caching proxy to
   like speed up subsequent builds like this:

       docker-compose up -d
       echo 'APT_PROXY=http://172.17.0.1:3142' >> config

* `BASE_DIR`  (Default: location of `build.sh`)

   **CAUTION**: Currently, changing this value will probably break build.sh

   Top-level directory for `pi-gen`.  Contains stage directories, build
   scripts, and by default both work and deployment directories.

* `WORK_DIR`  (Default: `"$BASE_DIR/work"`)

   Directory in which `pi-gen` builds the target system.  This value can be
   changed if you have a suitably large, fast storage location for stages to
   be built and cached.  Note, `WORK_DIR` stores a complete copy of the target
   system for each build stage, amounting to tens of gigabytes in the case of
   Raspbian.

* `DEPLOY_DIR`  (Default: `"$BASE_DIR/deploy"`)

   Output directory for target system images.

A simple example for building Raspbian:

```bash
IMG_NAME='Raspbian'
```

## Docker Build

```bash
vi config         # Edit your config file. See above.
./build-docker.sh
```

If everything goes well, your finished image will be in the `deploy/` folder.
You can then remove the build container with `docker rm -v pigen_work`

You can also run a debug build to get an image containing a few debug helpers:
```bash
DEBUG=1 ./build-docker.sh
```

If something breaks along the line, you can edit the corresponding scripts, and
continue:

```bash
CONTINUE=1 ./build-docker.sh
```

There is a possibility that even when running from a docker container, the
installation of `qemu-user-static` will silently fail when building the image
because `binfmt-support` _must be enabled on the underlying kernel_. An easy
fix is to ensure `binfmt-support` is installed on the host machine before
starting the `./build-docker.sh` script (or using your own docker build
solution).

## Stage Anatomy

### NodeOS Stage Overview

The build of Raspbian is divided up into several stages for logical clarity
and modularity.  This causes some initial complexity, but it simplifies
maintenance and allows for more easy customization. NodeOS stays close to
the original Raspbian during stages 0-2.

* **Stage 0** - bootstrap.  The primary purpose of this stage is to create a
   usable filesystem.  This is accomplished largely through the use of
   `debootstrap`, which creates a minimal filesystem suitable for use as a
   base.tgz on Debian systems.  This stage also configures apt settings and
   installs `raspberrypi-bootloader` which is missed by debootstrap.  The
   minimal core is installed but not configured, and the system will not quite
   boot yet.

* **Stage 1** - truly minimal system.  This stage makes the system bootable by
   installing system files like `/etc/fstab`, configures the bootloader, makes
   the network operable, and installs packages like raspi-config.  At this
   stage the system should boot to a local console from which you have the
   means to perform basic tasks needed to configure and install the system.
   This is as minimal as a system can possibly get, and its arguably not
   really usable yet in a traditional sense yet.  Still, if you want minimal,
   this is minimal and the rest you could reasonably do yourself as sysadmin.

* **Stage 2** - lite system.  This stage produces the Raspbian-Lite image.  It
   installs some optimized memory functions, sets timezone and charmap
   defaults, installs fake-hwclock and ntp, wifi and bluetooth support,
   dphys-swapfile, and other basics for managing the hardware.  It also
   creates necessary groups and gives the pi user access to sudo and the
   standard console hardware permission groups.

* **Stage 3** - cleanup.  This stage removes data like documentation that is
   considered unnecessary for a production ready image. If you want to keep
   this data you can skip this stage but be warned that this will just not
   delete existing data, documentation from packages installed throughout these
   stages or on a running system will not be kept after installation due to
   the `01_nodoc` file created in stage 0

* **Debug 0** - debug packages.  This stage installs helpful packages like ssh
   and gdb

### Stage specification

If you wish to build up to a specified stage (such as building up to stage 2
for a lite system), place an empty file named `SKIP` in each of the `./stage`
directories you wish not to include.

Then remove the `EXPORT*` files from stages after the desired one if any exist.

```bash
# Example for building a lite system keeping some documentation
touch ./stage3/SKIP
sudo ./build.sh  # or ./build-docker.sh
```

If you wish to build further configurations upon (for example) the lite
system, you can also delete the contents of `./stage3` and replace with your
own contents in the same format.
