#!/usr/bin/env bash
# Adds the pearOS apt repository (apt.pearos.xyz) and imports its signing key.
#
# Usage: sudo ./pearos-apt-setup.sh [--channel main|testing] [--release latest|pahoe|monterey|...]
#
# Repo layout: https://apt.pearos.xyz/<x86_64|aarch64>/<channel>/<release>/
# Default: main/latest.

set -euo pipefail

nc='\033[0m'
red='\033[0;31m'
green='\033[0;32m'
white='\033[1;37m'
ul='\033[4m'

BASE_URL="https://apt.pearos.xyz"
KEYRING_DIR="/etc/apt/keyrings"
KEYRING_FILE="$KEYRING_DIR/pearos-archive-keyring.gpg"
SOURCES_FILE="/etc/apt/sources.list.d/pearos.list"

channel="main"
release="latest"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --channel) channel="$2"; shift 2 ;;
        --release) release="$2"; shift 2 ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^#//; s/^ //'
            exit 0
            ;;
        *)
            echo -e "${red}[ERROR]${nc} Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${red}[ERROR]${nc} This script needs root (writes to /etc/apt). Run with sudo." >&2
    exit 1
fi

case "$(dpkg --print-architecture)" in
    amd64) arch_dir="x86_64" ;;
    arm64) arch_dir="aarch64" ;;
    *)
        echo -e "${red}[ERROR]${nc} Unsupported architecture: $(dpkg --print-architecture) (pearOS ships x86_64/aarch64 only)." >&2
        exit 1
        ;;
esac

repo_url="$BASE_URL/$arch_dir/$channel/$release"

echo -e "\n${ul}${white}Importing pearOS signing key${nc}\n"

mkdir -p "$KEYRING_DIR"
chmod 755 "$KEYRING_DIR"

# Public signing key for the pearOS package repositories (Arch + Debian),
# fingerprint 0AB2 738C EF7E DC6B 7B45 178D 4C1A 9F3C 131A CA95.
gpg --dearmor -o "$KEYRING_FILE" <<'EOF'
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBGnEdXgBEACyKNbc2suS8/28WFyJdO6EaN5IeljaHliMrd49ivDfw82KvWMf
l7Edey7IzSPOPAy4L6lm7TEPrcLI5yQfaMBpWg0C56UOmtukSgbgMlpOgni3ni1n
BXhS0RAPNfs/jxVNPxPKVoDM82PrsxcXctWP23Zo79xD8wMtz1i3miPkAgBli0+u
W5t2pW9DV/XNqGOc8Pl/0e+FaSFtopar2znNHjhsK4DTU3rFVaPNAx2kTGVS6bA1
A3p/07q5y3uwTnHMMWQjD4zyb2MZ8pWHXWupGMdQTfAzST6iXImVxwNTZB0K7bMd
2qpvIT35REaILDGXvwNoNdwYzTYPgrT9yHeLV7KbubIggSc1Bc4bmP57fO1nIuXL
a9Tel5ysFuivexM0ERMSSrpDeUs2RPYeAjbf3Ip4PEymXiK/DNorMBR7jqm9d+fS
NkRLbu2vxDjx5iY+vEtlkIoKvvB+tEjJXQzCMmQsVwmw1pUARK5HSo0Udxr6Lzco
DsYELpUt1KFwlMPKeaLcWzw61j/ATIYeNegF1zA9BtnkiAGBZuNao7f3JmnPD6w8
ZDJxkYl2xRUjmXnX8aC+84TPjSxQyAef1f62hxljKd2jfNmdDpCcnRvykJmvbm2p
dVRh64xYWTnGM7fidCeHjO3No6f4FKM8DbfKGpR1W0rN8eL8QwpT/mIBVwARAQAB
tFRBbGV4YW5kcnUgQmFsYW4gKFByaXZhdGUga2V5IGZvciBwZWFyT1MgYnkgQWxl
eGFuZHJ1IEJhbGFuKSA8YWxleEBwZWFyLXNvZnR3YXJlLmNvbT6JAk4EEwEKADgW
IQQKsnOM737ca3tFF41MGp88ExrKlQUCacR1eAIbAwULCQgHAgYVCgkICwIEFgID
AQIeAQIXgAAKCRBMGp88ExrKlWMlD/9U/ljfd3mGycQfDqVbfzLeN7BQezx8ihC1
ez32d3faHZnaZDC3GZ8k5wqSy9mODipBreS++tDhGCguOWoWRK3QAhljA+9o+Pa2
0Q+dwaiAHoKeuzGHaZPpJOck0H6OTA1+4xcWBLElF2MAY3ew3xz6aovuGNS/0KPJ
A5rqrLtGLD7xi4GRp+bCiG0R/aitx0SzqvYGzg09+6T7abmvZHLFNHVeyWTq17Gn
iLaFnXBhAsypOni/pSj3xTevRQtahIUYBgXsYgQpmoF4MvYi0sXrrrDvnjtqoQF8
l3YqkF11lLDJxITLKRs3oCBAZCfXiklkEtyWmw3VvOBp0s3TLspa6DSL6vVGKYgg
t2iRxebhFg+5FE4khFg9JftR3y5KuCZ+PuP9NAdizMnDoUkIefFZuWery/y18TSa
sEDpal9WqatMj/ssOv47aGN68wYh5G6/7E+Uz3OdKGEfnGt4iQ+cCcociJuPzf4Y
apT6om5RyKFWqmSaLJfXQOQ64YLaUcZ8xA6z95l5u2aUgP3/gR9BbOIZMXAzuBBP
WFZnrvxYs0nJaIs7xhgZj/mSG2/nyPi4EdMTG5cBOxHl+6yWoLNA1xdqOpXwIj1l
jwN/O4T2N/NL3c1cMj2IIe9arG5MWg5z+pGSSKQ1NL9MPMHeOlKTJgefL/Wj+WLh
GnbMEYCUlbkCDQRpxHV4ARAA3ExY7AXPPWNxAD8WP4GZIBrz07uvXGQysDyy9tKA
l6oRSxZHMZvwyXmdikI/k/30pvTvIfCiUVnTp/Ed285JIE0SU0qW1UjrYDixdjgk
dpYpgzE3IZUpX129aDH1VZlvxPTQtYCH0PjjGRf5kilegUOPFWkxHYFpJdqofEqR
5BsQfKTOiP77t2fP5Gn/bUTlyVA1vltP0LgLGuw20U6UbmrzalWq9TiaUNHBRoed
zmC+hC2G8fsNqUqMwvI3uZApHi1s2CYBkl6Cu+gy7CL05ggA37xyLhtNRgauD/DD
6E3EjXM2mOd9Cg6cCDYqsGH1/ZYY+5oXNgyBdADSpFntpFLneFVx/u80Fo99N/lJ
sjjJTwYVnKxLRV2tGBU8WvfzAIiKUiFWJvtbmhIVAiSXKTqX1VoJhUFexinQPgm/
bqoEGaCptDLHpV4PI9nctqBuM3zMvYHeYttgBmUO+YheIoQcPQGIHPXfNebUFzq5
OrD/UiDnEttmAoY+3me2FBXbeqNUXOiXcWcJ043EAT2mIrC9DL8qImM+2S4WWVVv
YbmGicnge4xq3A2yI8MIhzQ1Mz/dx/n3lmOXgEv6iv68GoY8LRIOm0esqGVOjvfQ
QfJ41dcuhBZK9l40oU6iCvMP6VpXESPG6KVcGcGCci27dKa/V0gfJ8wKw2QY6l7D
7D0AEQEAAYkCNgQYAQoAIBYhBAqyc4zvftxre0UXjUwanzwTGsqVBQJpxHV4AhsM
AAoJEEwanzwTGsqVC/UP+wVD8a72E4ywmtsoo7ODLbF1jGYVrD3zKNzgW55JX1Qv
BGdEHnGsGebxSCmX4NifBX5xxeTbFm5OMNRQqT7Erm6fMQ20JCEVdYLxiJQ1g+z5
eq5mxGAWpw+7LG7q8xKE0kvm7n/d5S03VwCWjcz3AWEnXntAfzqAjefRQwuC+hHN
hs7PwS9zqProb4bNoJ6JFEhW/c6HwTfABGbBAmA7TXtSECZB0tN+p8TtTkLgCkKw
mx/hufyAgyvzl+aEdTUV20HVdqOdul37x0Zt1n+cjAJSpAIDL2c+ECMLe6wn5N6A
ejf6mtPkq/f1j203ozR4ycyH35Jg0Jv6uza8q+DIre6KMv1jAn5/8wIHhK69jOtr
ZIAOxeIBXvoSPGMBMLW4pxF1tXzBxkws4UHVszlGg8FessZK2yq223lzNgP0JL09
7v2lDp/RcXCWWnhnGua+cGGWCoqjZE52mwVTsOwf8AuXDsJi3VB6jMOUkD/ErUMx
l68y4POx8JlTTZMVqXofdMKL0Uq0g0ZpievsyBkLnu4UPRnBZFOJHcx2BcK1uTDr
B3wNzkdsd6OrVowMjBdxPJkOQsaSbpLMW87eUCQQ3p1xJtV+PjhWDLPcjHUR053O
Wv6hbKKe/Cf21HoPu5UA86BkFv6bho6rQiwjhKZHgx2iaiBMKstNp4S6I4D6gHwK
=95MG
-----END PGP PUBLIC KEY BLOCK-----
EOF
chmod 644 "$KEYRING_FILE"

echo -e "${green}[OK]${nc} Key imported to $KEYRING_FILE"

echo -e "\n${ul}${white}Configuring apt source${nc}\n"

echo "deb [signed-by=$KEYRING_FILE] $repo_url ./" > "$SOURCES_FILE"
chmod 644 "$SOURCES_FILE"

echo -e "${green}[OK]${nc} Wrote $SOURCES_FILE:"
cat "$SOURCES_FILE"

echo -e "\n${ul}${white}Updating apt${nc}\n"
apt-get update

echo -e "\n${green}Done.${nc}\n"
