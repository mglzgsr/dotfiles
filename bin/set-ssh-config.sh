#!/usr/local/bin/bash

# set -x

DESIRED=${1:-work}
BASTION_KEY=~/.ssh/balabit_rsa
DC=lon5

USERNAME=$(whoami)
BASTION=cbast.${DC}.corp.rackspace.net
SSH_DIR=~/.ssh

echo "----> Creating 'home' config file"
cat > ${SSH_DIR}/config-home <<EOF
##
# SSH 'home' config generated $(date)
##

Host localhost
     ProxyCommand none
EOF

echo "----> Creating 'work' config file"
cat > ${SSH_DIR}/config-work <<EOF
##
# SSH 'work' config generated $(date)
##

Host localhost
     ProxyCommand none

# RSA Logins: helpful links that match your preferred HostName below.
# You will need to make sure you are authenticated to the endpoint 
# in your datacenter, otherwise you won't be able to connect.
#  https://auth.${DC}.gateway.rackspace.com/netaccess/connstatus.html

Host bastion
    Hostname ${BASTION}
    ForwardAgent yes
    ForwardX11Trusted yes
    ProxyCommand none
    User ${USERNAME}
    ControlMaster auto
    ControlPath ~/.ssh/master-%r@%h:%p
    TCPKeepAlive yes
    ServerAliveInterval 300
    #
    # Most techs run a terminal permanently open to the bastion
    # which serves as the MUX socket; if you do not do this,
    # uncomment the below to have the first MUX created tossed
    # into the background instead (man ssh -> "-O ctl_cmd")
    # ControlPersist 10h

Host *
    ProxyCommand ssh -A -i ${BASTION_KEY} 'nc %h %p'
    ForwardX11Trusted yes
    GSSAPIAuthentication no
    StrictHostKeyChecking no
    VerifyHostKeyDNS no
    HashKnownHosts no
    TCPKeepAlive yes
    ServerAliveInterval 300

EOF

pushd $SSH_DIR > /dev/null
echo "----> Setting config to '$DESIRED' in $SSH_DIR"
cp -f config-$DESIRED config
popd > /dev/null

echo "==>   Done"
