#!/bin/sh

set -e
cd "$(dirname "$0")"

# SET SOME DESIRED VARIABLES
kubectl_version="v1.28.13"
velero_version="v1.14.0"
# helm_version="v3.7.0"

# GET OS AND ARCH
os=$(uname -s | tr '[:upper:]' '[:lower:]')
if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then arch="arm64"; else arch="amd64"; fi

# SET SOME DEFAULTS
install_dir="/usr/local/bin"
kubectl_version="${kubectl_version:=$(curl -L -s https://dl.k8s.io/release/stable.txt)}"
velero_version="${velero_version:=$(curl -s https://api.github.com/repos/vmware-tanzu/velero/releases/latest | grep tag_name | cut -d '"' -f 4)}"
helm_version="${helm_version:=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep tag_name | cut -d '"' -f 4)}"

if [ ! -d "${install_dir}" ]; then echo "Creating '${install_dir}'"; sudo mkdir -p "${install_dir}"; fi

# INSTALL KUBECTL
if kubectl version --client 2>/dev/null | grep -q -E "${kubectl_version}$"; then
	echo "kubectl version ${kubectl_version} already installed"
else
	echo "Installing kubectl version: ${kubectl_version}"
	curl -sS -L "https://dl.k8s.io/release/${kubectl_version}/bin/${os}/${arch}/kubectl" -o "/tmp/kubectl"
	chmod +x "/tmp/kubectl"
	sudo mv "/tmp/kubectl" "${install_dir}/"
fi

# INSTALL VELERO
if velero version --client-only 2>/dev/null | grep -q -E "${velero_version}$"; then
	echo "velero version ${velero_version} already installed"
else
	echo "Installing velero version: ${velero_version}"
	if [ -d "/tmp/velero" ]; then rm -rf "/tmp/velero"; fi
	mkdir "/tmp/velero"
	curl -sS -L "https://github.com/vmware-tanzu/velero/releases/download/${velero_version}/velero-${velero_version}-${os}-${arch}.tar.gz" -o "/tmp/velero.tar.gz"
	tar -xzf "/tmp/velero.tar.gz" -C "/tmp/velero/"
	chmod +x /tmp/velero/velero*/velero
	sudo mv /tmp/velero/velero*/velero "${install_dir}/"
	rm -rf "/tmp/velero"
fi

# INSTALL HELM
if helm version --short 2>/dev/null | grep -q -E "${helm_version}(\+|$)"; then
	echo "helm version ${helm_version} already installed"
else
	echo "Installing helm version: ${helm_version}"
	if [ -d "/tmp/helm" ]; then rm -rf "/tmp/helm"; fi
	mkdir "/tmp/helm"
	curl -sS -L "https://get.helm.sh/helm-${helm_version}-${os}-${arch}.tar.gz" -o "/tmp/helm.tar.gz"
	tar -xzf "/tmp/helm.tar.gz" -C "/tmp/helm/"
	chmod +x /tmp/helm/*/helm
	sudo mv /tmp/helm/*/helm "${install_dir}/"
	rm -rf "/tmp/helm"
fi
