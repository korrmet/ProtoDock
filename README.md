# ProtoDock

One more attempt to make containers from scratch. This tool is for Arch Linux
only.

# Required packages

- arch-install-scripts
- coreutils
- tar

# Usage

## Warning

This is just simple chroot-based script. Chroot is not secure thing, be careful.

## Build mode

In this mode the script builds container and packs it in a .tar.xz.

```
> protodock.sh --build --name <name of the container> [options] [packages list]
```

It creates folder with specified name and bootstraps pacman, after that it
installs specified packages.

Available options:

- --nozip, prevent to pack container and leave directory exists

Using --nozip option you can chroot to this folder, install or build additional
software, and pack it to .tar.xz manually

## Run mode

In this mode the script extracts container in /tmp/protodock, mounts necessary
folders and chroot here.

```
> protodock.sh --run <path to container> [mount folders]
```

Folders will be mounted in the root folder of the container.
