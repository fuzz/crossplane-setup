#/bin/sh
#
# crossplane-setup.sh -- Set up Crossplane using either Homebrew on macOS
# or Snap on Linux. This may work with Homebrew on Linux but is untested.

kind_download_url="https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64"
kind_image="kindest/node:v1.23.0"

homebrew=`which brew`
snap=`which snap`

docker=`which docker`
kind=`which kind`
kubectl=`which kubectl`
helm=`which helm`

# Seconds to wait for Crossplane resources to beceome available
seconds=15

if [ -z "${homebrew}" ] && [ -z "${snap}" ]; then
    echo "No Homebrew/Snap: try https://brew.sh or https://snapcraft.io"
    echo "See https://crossplane.io/docs for other Crossplane install options"
    exit 1
fi

echo "Setting up Crossplane..."

if [ ! -z "${homebrew}" ]; then
    [ -z "${docker}" ]  && { brew install --cask docker; \
	                     echo "Rerun this script after Docker installed"; \
			     open /Applications/Docker.app; \
			     exit 2; }
    [ -z "${kind}" ]    && brew install kind
    [ -z "${kubectl}" ] && brew install kubectl
    [ -z "${helm}" ]    && brew install helm
fi

if [ ! -z "${snap}" ]; then
    [ -z "${docker}" ]  && sudo snap install docker
    [ -z "${kind}" ]    && { curl -Lo ./kind $kind_download_url; \
                             chmod +x ./kind; \
                             sudo mv ./kind /usr/local/bin/kind; }
    [ -z "${kubectl}" ] && sudo snap install kubectl --classic
    [ -z "${helm}" ]    && sudo snap install helm --classic
fi

kind create cluster --image $kind_image --name crossplane --wait 5m || \
    { echo "Cluster failed--try 'kind delete cluster -n crossplane'"; exit 1; }

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
