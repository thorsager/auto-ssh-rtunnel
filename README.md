Auto SSH RemoteTunnel
=====================
This image can be used for tunneling traffic from a remote endpoint onto
containers, using the SSH protocol, which can be very useful if you docker-node
or even swarm is located behind NAT. Also this image can be used for "proxying"
from a stack to an external service, through SSH.

Configuring sshd _(for RemoteForward)_
================
For the setup to work, the sshd running on the _remote_ server must be have the
following enabled
```
GatewayPorts yes
```
And if tunneling of privileged ports (< 1024) it requires that the services
logs in as *root* at the remote end, which requires the following configuration
```
PermitRootLogin yes
```

Key Authentication
==================
Login is done using keys, and the public key of the service must be added to the
`authorized_keys` file on the remote endpoint, for the user that is used for
login.

**The public key that MUST be added to the remote endpoint is printed on
container startup**

Setting up Tunnels
==================
Which ports should be tunneled is controlled by setting environment variables
in the container.
- `TARGET` - The target/_remote endpoint_ on which to login.
  Fx. `joe@server.mydomain.tld`
- `TARGET_PORT` - The port on which the *sshd* is listening on the target-host
- `R_TUNNEL_*` - All _remote-forward-descriptions_ are converted into `-R` arguments
  on the ssh connection. **(Note names of `R_TUNNEL_*` variables MUST
  be unique, but the suffix is not of importance)**
- `L_TUNNEL_*` - All _local-forward-descriptions_ are converted into `-L` arguments
  on the ssh connection. **(Note names of `L_TUNNEL_*` variables MUST bu unique,
  but the suffix is not of importance)**
- `KEY_FILE` - Can be used for overriding the name of the key to be generated or
  to force autossh to use a specific key.
- `KEY_ALGO` - Can be used to override the algorithm used when generating a new
  key, defaults to `ed25519`
- `SSH_OPTS` - Can be used for passing arguments directly to the ssh-client such
  as `-v` for a bit of debugging.

Volumes
=======
A single volume is defined in the container `/root/.ssh` this volume will hold
the generated pubic/private key-pair, as well as the `config` file that will
hold some general configuration.
It is also using this volume possible to move tunnel configuration away from
environment variables and store it in the `config` file using `RemoteForward` and
`LocalForward`

Docker-compose
==============
A small example of how this could be used id found here [here](https://github.com/thorsager/auto-ssh-rtunnel/blob/master/docker-compose.yml)
