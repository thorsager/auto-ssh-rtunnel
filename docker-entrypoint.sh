#!/usr/bin/env sh

KEY_ALGO=${KEY_ALGO:-"ed25519"}
KEY_FILE=${KEY_FILE:-"/root/.ssh/id_${KEY_ALGO}_AUTO_RTUNNEL"}

if [[ ! -d /root/.ssh ]]; then
  echo "Creating .ssh"
  mkdir /root/.ssh
  chmod 600 /root/.ssh
fi

if [[ ! -e /root/.ssh/config ]]; then
  echo "Creating ssh config."
  cat > /root/.ssh/config <<-ConfigHD
  Host    *
        UserKnownHostsFile        /dev/null
        StrictHostKeyChecking     no
        TCPKeepAlive              no
        ServerAliveInterval       5
        ServerAliveCountMax       3
ConfigHD
  chmod 600 /root/.ssh/config
fi

if [[ ! -e ${KEY_FILE} ]]; then
  echo "Generating key."
  ssh-keygen -t ${KEY_ALGO} -C "root@ssh-auto-rtunnel" -P "" -f ${KEY_FILE}
fi

echo "==== Public key ===="
cat ${KEY_FILE}.pub
echo "===================="

if [[ -z ${RT_TARGET} ]]; then
  echo "NO Target host found! please set RT_TARGET"
  exit 1;
fi

if [[ -z ${RT_TARGET_PORT} ]]; then
  echo "NO Target port found! please set RT_TARGET_PORT"
  exit 1;
fi

for TUNNEL_CFG in $(env | grep RT_TUNNEL_); do
  TUNNEL_OPTS="${TUNNEL_OPTS} -R ${TUNNEL_CFG#*=}"
done

echo "****"
echo "**** ${TUNNEL_OPTS}"
echo "****"

echo autossh -N ${TUNNEL_OPTS} ${RT_TARGET} -p ${RT_TARGET_PORT} -i ${KEY_FILE} ${SSH_OPTS}
exec autossh -N ${TUNNEL_OPTS} ${RT_TARGET} -p ${RT_TARGET_PORT} -i ${KEY_FILE} ${SSH_OPTS}
