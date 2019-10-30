#!/usr/bin/env sh

KEY_ALGO=${KEY_ALGO:-"ed25519"}
KEY_FILE=${KEY_FILE:-"/root/.ssh/id_${KEY_ALGO}_AUTO_RTUNNEL"}
DOCKER_HOST=$(ip route show | awk '/default/ {print $3}')

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

if [[ -z ${TARGET} ]]; then
  echo "NO Target host found! please set TARGET"
  exit 1;
fi

if [[ -z ${TARGET_PORT} ]]; then
  echo "NO Target port found! please set TARGET_PORT"
  exit 1;
fi

for TUNNEL_CFG in $(env | grep R_TUNNEL_); do
  CFG=${TUNNEL_CFG#*=}
  CFG=${CFG/docker.host/$DOCKER_HOST}
  TUNNEL_OPTS="${TUNNEL_OPTS} -R ${CFG}"
done

for TUNNEL_CFG in $(env | grep L_TUNNEL_); do
  CFG=${TUNNEL_CFG#*=}
  CFG=${CFG/docker.host/$DOCKER_HOST}
  TUNNEL_OPTS="${TUNNEL_OPTS} -L ${HOST_IP}:${CFG#*=}"
done

echo "****"
echo "**** autossh -N ${TUNNEL_OPTS} ${TARGET} -p ${TARGET_PORT} -i ${KEY_FILE} ${SSH_OPTS}"
echo "****"

echo autossh ${AUTOSSH_OPTS} -N ${TUNNEL_OPTS} ${TARGET} -p ${TARGET_PORT} -i ${KEY_FILE} ${SSH_OPTS}
exec autossh ${AUTOSSH_OPTS} -N ${TUNNEL_OPTS} ${TARGET} -p ${TARGET_PORT} -i ${KEY_FILE} ${SSH_OPTS}
