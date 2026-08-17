# pearOS apt importer

Adds the [pearOS](https://pearos.xyz/) apt repository (`apt.pearos.xyz`) to
your system and imports its signing key
([`pearos-archive-keyring`](https://github.com/Pear-Project/debian-package-repo),
fingerprint `0AB2 738C EF7E DC6B 7B45 178D 4C1A 9F3C 131A CA95`).

## Usage

```sh
sudo ./pearos-apt-setup.sh [--channel <channel>] [--release <release>]
```

Defaults to `--channel main --release latest`. Architecture (`x86_64` /
`aarch64`) is auto-detected from `dpkg --print-architecture`; there's no flag
for it.

```sh
sudo ./pearos-apt-setup.sh                                   # main/latest
sudo ./pearos-apt-setup.sh --channel testing --release pahoe
```

Running it writes `/etc/apt/keyrings/pearos-archive-keyring.gpg` and
`/etc/apt/sources.list.d/pearos.list`, then runs `apt-get update`. After that:

```sh
sudo apt install pearos-magiclamp
```

## Repo layout

The repo is arranged `<arch>/<channel>/<release>/`, one flat apt suite per
directory (`deb [signed-by=...] https://apt.pearos.xyz/<arch>/<channel>/<release> ./`).

**Architectures**

| `dpkg --print-architecture` | Repo dir  |
|------------------------------|-----------|
| `amd64`                      | `x86_64`  |
| `arm64`                      | `aarch64` |

Auto-detected by the script - no flag for it. Any other architecture is
rejected (pearOS doesn't build for it).

**Channels**

| Channel   | Description                  |
|-----------|-------------------------------|
| `main`    | Stable packages (default)     |
| `testing` | Pre-release / testing packages |

**Releases**

| Release      |
|--------------|
| `latest` (default) |
| `pahoe`      |
| `monterey`   |
| `catalina`   |
| `mojave`     |
| `big-sur`    |
| `leopard`    |
| `sierra`     |
| `high-sierra`|

Any `--channel`/`--release` combination above is a valid apt source to point
at - only the directory needs to actually contain packages for `apt install`
to find anything there. Right now that's just `x86_64/main/latest/`
(`pearos-magiclamp`); the rest of the tree exists but is still empty.
