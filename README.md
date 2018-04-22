Auto SSH RemoteTunnel
=====================
This container can be used for tunneling traffic from a remote endpoint onto
containers, using the SSH protocol.
This can be very useful if you docker-node or even swarm is located behind NAT.

Configuring sshd
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
- `RT_TARGET` - The target/_remote endpoint_ on which to login.
  Fx. `joe@server.mydomain.tld`
- `RT_TARGET_PORT` - The port on which the *sshd* is listening on the target-host
- `RT_TUNNEL_*` - All _tunnel-descriptions_ are converted into `-R` arguments on
  the ssh connection. **(Note names of RT_TUNNEL_* variables MUST be unique, but
  the suffix is not of importance)**

- `KEY_FILE` - ..
- `KEY_ALGO` - ..
- `SSH_OPTS` - Can be used for passing arguments directly to the ssh-client such
  as `-v` for a bit of debugging.

Volumes
=======
A single volume is defined in the container `/root/.ssh` this volume will hold
the generated pubic/private key-pair, as well as the `config` file that will
hold some general configuration.
It is also using this volume possible to move tunnel configuration away from
environment variables and store it in the `config` file using `RemoteForward`.

Docker-compose
==============
A small example of how this could be used id found here [here](docker-compose.yml)
