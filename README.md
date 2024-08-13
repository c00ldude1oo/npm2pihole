# NPM2Pihole

A bash script in a docker container that will check nginx proxy manager for configured domains and will add them to pihole's local DNS automatically

## PREREQUISITES

Nginx Proxy Manager (NPM) *\*NPM2Pihole must be on same host as NPM*

pihole *remote or local host is supported

## INSTALL

1 Setup docker-compose.yml

```yaml
services:
  npm2pihole:
    image: ghcr.io/c00ldude1oo/npm2pihole:latest
    env_file: config.env
    restart: unless-stopped
    volumes:
        # Path to Nginx Proxy Mangers data/nginx/proxy_host folder.
      - /path/to/npm/data/nginx/proxy_host/:/app/npm/:ro
        # PiHole's /etc/pihole/custom.list file. comment if remote pihole
#      - /path/to/piholes/data/custom.list:/app/custom.list
        # SSH key(s) for sftp. comment if unused
      - ./ssh/:/root/.ssh/

```

2 Setup configs `config.env`

Check below and set up the configs

3 Start docker

```sh
docker compose up
```

After first run you can quit and add the -d flag

## CONFIGS

### config.env

`NPM_IP=192.168.0.0`
This is set to the IP of the nginx proxy manager

`USE_SFTP=true/false`
This is to enable/disable use of SFTP to use a remote pihole

`SFTP_IP=192.168.0.0`
This is set to the IP of the remote pihole

### docker-compose.yml

The docker volumes need to be configured

#### `/app/data:ro`

This needs to be set to the full path of NPMs proxy_hosts folder
E.g. `path/to/npm/data/nignx/proxy_host:/app/data:ro`

#### `/app/custom.list`

This needs to be set to the full path of pihole's custom DNS list file. *\*only if pihole is on same host*

E.g. `path/to/pihole/etc-pihole/custom.list:/app/custom.list`

#### `/root/.ssh`

If you're not using a remote pihole this can be committed out

E.g. `/home/docker_user/.ssh:/root/.ssh`
