# Crossplane Setup

`crossplane-setup.sh` is a setup script for
[Crossplane](https://crossplane.io) that currently works on macOS with
[Homebrew](https://brew.sh) and on Linux with
[Snap](https://snapcraft.io). It may work on Linux with
Homebrew, but this has not been tested. Crossplane Setup uses Docker and Kind
to run Kubernetes, but other options are available--see the
[Crossplane documentation](https://crossplane.io/docs) for more information.

## Tools required/installed

If any of these are missing on your system Crossplane Setup will
attempt to install them. Note that you can use tools other than Docker and Kind
to run Crossplane, but that is outside the scope of Crossplane Setup.

* [Docker](https://docs.docker.com): Container system
* [Helm](https://helm.sh/docs): Kubernetes package manager
* [Kind](https://kind.sigs.k8s.io): Run Kubernetes locally
* [Kubectl](https://kubernetes.io/docs/reference/kubectl): CLI for Kubernetes
* [Kubernetes](https://kubernetes.io/docs/home): Container orchestration system

## Usage

```
curl https://raw.githubusercontent.com/fuzz/crossplane-setup/main/crossplane-setup.sh | sh
```

On macOS if you do not have Docker installed that process will be started,
then the Docker desktop app will be opened and you'll complete installation
there. Afterward re-run this script to finish setting up Crossplane.

![Planes flying across from each other](https://pinecab.com/assets/images/crossplanes.jpg
    "crosstown traffic")
