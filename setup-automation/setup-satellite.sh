#!/bin/bash

# Unregister Satellite server from itself.
subscription-manager unregister

# Delete Satellite from its inventory.
hammer host delete --name satellite.lab

# TODO: Delete any activation keys created for this lab, e.g.:
# hammer activation-key delete --name "<Activation Key Name>" --organization "Acme Org"

# Get the latest CVE map from Red Hat and copy it to the Foreman directory so that it can be used by the Foreman CVE plugin to determine which CVEs are applicable to the registered hosts.
# curl -o cvemap.xml https://security.access.redhat.com/data/meta/v1/cvemap.xml
# cp cvemap.xml /var/lib/foreman/

# TODO: Add any additional lab-specific reset/setup steps here.

# Uninstall IoP
satellite-installer --iop-ensure absent

# Delete all images.
podman rmi -a

# Log into Red Hat Container Registry.

cat <<REGISTRY_AUTH_EOF > /etc/foreman/registry-auth.json
{
    "auths": {
      "registry.redhat.io": {
        "auth": "${REGISTRY_PULL_TOKEN}"
      }
    }
  }
REGISTRY_AUTH_EOF

# Add a satellite-installer wrapper function so participants can use the shorter
# `satellite-installer --enable-iop` in place of `satellite-installer --iop-ensure present`.
cat <<'BASHRC_EOF' >> /root/.bashrc

satellite-installer() {
  if [ "$1" = "--enable-iop" ]; then
    shift
    command satellite-installer --iop-ensure present "$@"
  else
    command satellite-installer "$@"
  fi
}
BASHRC_EOF
