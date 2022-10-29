# Crossplane Setup

`crossplane-setup.sh` is a setup script for
[Crossplane](https://crossplane.io/) that currently works on macOS with
[Homebrew](https://brew.sh) and on Linux with
[Snap](https://snapcraft.io). It may work on Linux with
Homebrew, but this has not been tested.

## Usage

```
curl https://raw.githubusercontent.com/fuzz/crossplane-setup/main/crossplane-setup.sh | sh
```

On macOS if you do not have Docker installed that process will be started,
then the Docker desktop app will be opened and you'll complete installation
there. Afterward re-run this script to finish setting up Crossplane.

![Planes flying across from each other](https://pinecab.com/assets/images/crossplanes.jpg
    "crosstown traffic")
