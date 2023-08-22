# NPM2Pihole

A bash script in a docker container that will check nginx proxy manager for configured domains and will add them to pihole's local DNS automatically

### PREREQUISITES
Nginx proxy manager *\*Must be on same host as nginx proxy manager*

pi.hole *remote or local host is supported

## INSTALL
1. Setup docker-compose.yml 
```
version: '3.3'
services:
  npm2pihole:
    image: ghcr.io/c00ldude1oo/npm2pihole:main
    env_file: config.env
    volumes:
        # Path to Nginx Proxy Mangers data/nginx/proxy_host folder.
      - /path/to/npm/data/nginx/proxy_host/:/app/npm/:ro
        # PiHole's /etc/pihole/custom.list file. commit if remote pihole
#      - /path/to/piholes/data/custom.list:/app/custom.list
        # SSH key(s) for sftp. commit if unused
      - ./ssh/:/root/.ssh/

```
2. Setup configs `config.env`

Check below and set up the configs

3. Start docker 
~~~
docker compose up
~~~
After frist run you can quit and add the -d flag

## CONFIGS

### config.env
`IP=192.168.0.0`
This is set to the IP of the nginx proxy manager

`USFTP=true/false`
This is to enable/disable use of SFTP to use a remote pihole

`SFTPIP=192.168.0.0`
This is set to the IP of the pihole
### docker-compose.yml
The docker volumes need to be configured

#### `/app/data:ro`
This needs to be set to the full path of NPMs proxy_hosts folder
E.g. `path/to/npm/data/nignx/proxy_host:/app/data:ro`

#### `/app/custom.list`
*\*only if pihole is on same host*

 This needs to be set to the full path of pihole's custom DNS list file
 
E.g. `path/to/pihole/etc-pihole/custom.list:/app/custom.list`

#### `/root/.ssh`
If your not using a remote pihole this can be commited out
