# Local Development Arch Repository

A signed Arch Linux package repository for development builds. Initially includes Dropmux `0.1.0.alpha1-1`.

## Add to pacman

Download and inspect the repository signing key:

```sh
curl -fL https://github.com/Biggamer11/local-dev-arch/releases/download/repository/local-dev-signing-key.asc -o /tmp/local-dev-signing-key.asc
gpg --show-keys --with-fingerprint /tmp/local-dev-signing-key.asc
```

Expected fingerprint:

```text
8655 98DF 7228 1945 59CC DBE0 A145 D35E ABFD 8722
```

After verifying the fingerprint, import and trust this repository key:

```sh
sudo pacman-key --add /tmp/local-dev-signing-key.asc
sudo pacman-key --lsign-key 865598DF7228194559CCDBE0A145D35EABFD8722
```

Add this section to `/etc/pacman.conf` in the Arch installation or Distrobox that will use the packages:

```ini
[local-dev]
SigLevel = Required
Server = https://github.com/Biggamer11/local-dev-arch/releases/download/repository
```

Then install Dropmux:

```sh
sudo pacman -Syu dropmux
```

Future `pacman -Syu` runs sync the repository and upgrade installed packages when newer versions are published. Adding this configuration does not start a background updater.

## Publishing updates

Run `publish.sh` with one or more built `.pkg.tar.zst` files on the development machine. It signs packages, rebuilds and signs the database, and uploads repository assets to the stable `repository` GitHub release. Increase a package's version or release number for upgrades.

The private signing key stays local. Only the public key, signed packages, repository indexes and signatures are hosted here. This repository contains development packages; it is separate from application source repositories.
