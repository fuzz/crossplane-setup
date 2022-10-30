#!/bin/bash
#
# crossplane-setup.sh -- Set up Crossplane using either Homebrew on macOS
# or Snap on Linux. This may work with Homebrew on Linux but is untested.

kind_download_url="https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64"
kind_image="kindest/node:v1.23.0"

# Seconds to wait for Crossplane resources to beceome available
seconds=15

brewcmd=$(which brew)
snapcmd=$(which snap)

if [ -z "${brewcmd}" ] && [ -z "${snapcmd}" ]; then
    echo "No Homebrew/Snap: try https://brew.sh or https://snapcraft.io"
    echo "See https://crossplane.io/docs for other Crossplane install options"
    exit 1
fi

executables="docker kind kubectl helm"
for e in $executables; do
    [ -z "$(which "$e")" ] && missing+="$e "
done

echo "Setting up Crossplane..."
if [ -n "${missing}" ]; then
    echo "Required tools missing: $missing<-attemping to install"

    if [ -n "${snapcmd}" ]; then
        cat <<EOF
You may be asked for your password. On Linux/Snap helm and kubectl will be
installed *unconfined* using '--classic' mode, see
https://askubuntu.com/questions/917049 before proceeding if you do not
understand the security implications.
EOF
    fi

    echo "Sleeping 5 seconds, use <ctrl>-c if you would like to abort..."
    sleep 5
fi

[ -n "${snapcmd}" ] && for m in $missing; do
    case $m in
    docker)
        echo "Installing Docker"
        snap install docker && echo "Docker install complete"
        ;;
    kind)
        echo "Installing Kind from $kind_download_url"
        curl -Lo ./kind $kind_download_url
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind && echo "Kind install complete"
        ;;
    kubectl)
        echo "Installing Kubectl"
        snap install kubectl --classic && echo "Kubectl install complete"
        ;;
    helm)
        echo "Installing Helm"
        snap install helm --classic && echo "Helm install complete"
        ;;
    esac
done

# Check for missing executables again. It's possible a user has both Snap
# and Homebrew installed and one of the above installs has failed. If so,
# we try the install with Homebrew, if not then we don't.
missing=
for e in $executables; do
    [ -z "$(which "$e")" ] && missing+="$e "
done

# Homebrew install--note that 'env -i bash -c' must be used or the brew scripts
# will cause an error in this script. I suspect a bug in Kind's Homebrew script
# but have not confirmed.
[ -n "${brewcmd}" ] && for m in $missing; do
    case $m in
    docker)
        echo "Installing Docker and Docker Desktop"
        env -i bash -c 'brew install --cask docker'
        echo "Re-run this script after completing install of Docker Desktop"
        open /Applications/Docker.app
        exit 2
        ;;
    kind)
        echo "Installing Kind"
        env -i bash -c 'brew install kind'
        echo "Kind install complete"
        ;;
    kubectl)
        echo "Installing kubectl"
        env -i bash -c 'brew install kubectl'
        echo "Kubectl install complete"
        ;;
    helm)
        echo "Installing helm"
        env -i bash -c 'brew install helm'
        echo "Helm install complete"
        ;;
    esac
done

echo "Starting local Kubernetes cluser with Kind..."
kind create cluster --image $kind_image --name crossplane --wait 5m || \
    { echo "Start failed--try 'kind delete cluster -n crossplane'"; exit 1; }

echo "Using Helm to install Crossplane on local Kubernetes cluster..."
helm repo add \
    crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane \
    crossplane-stable/crossplane \
    --namespace crossplane-system \
    --create-namespace

echo "$ kubectl get pods -n crossplane-system"
kubectl get pods -n crossplane-system

echo "Waiting $seconds seconds for Crossplane resources to become available..."
sleep $seconds

echo "$ kubectl api-resources | grep crossplane"
kubectl api-resources | grep crossplane
