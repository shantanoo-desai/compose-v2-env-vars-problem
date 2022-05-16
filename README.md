# Repo to reproduce the environment variable persistence bug 

## System Info

```bash

$ docker info
Client:
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc., v0.8.1-docker)
  compose: Docker Compose (Docker Inc., 2.5.0)

Server:
 Containers: 39
  Running: 1
  Paused: 0
  Stopped: 38
 Images: 45
 Server Version: 20.10.15
 Storage Driver: overlay2
  Backing Filesystem: extfs
  Supports d_type: true
  Native Overlay Diff: false
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: systemd
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: runc io.containerd.runc.v2 io.containerd.runtime.v1.linux
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: f830866066ed06e71bad64871bccfd34daf6309c.m
 runc version: 
 init version: de40ad0
 Security Options:
  apparmor
  seccomp
   Profile: default
  cgroupns
 Kernel Version: 5.10.114-1-MANJARO
 Operating System: Manjaro Linux
 OSType: linux
 Architecture: x86_64
 CPUs: 16
 Total Memory: 30.65GiB
 Name: shan-pc
 ID: DEGH:RPQ4:ONO5:K27S:6T47:BDMJ:Y5RX:RQ3J:3D2R:VIUN:STZ6:WTOQ
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false

```

```
$ docker compose version
Docker Compose version 2.5.0
```

## Usage

The `docker-compose.base.yml` and `services/docker-compose.grafana.yml` file are _merged_
using the `-f` flag for `docker compose` and the corresponding config file `docker-compose.yml` file
(ignored here) should be created using the `Makefile`

```bash
make build
```
to generate the `docker-compose.yml` file


```bash
make run
```
to bring the stack up

```bash
make clean
```
to bring the stack down


## "Bug" reproduction

1. Create the `docker-compose.yml` file

    ```bash
      make build
    ````
2. bring the stack up

    ```bash
      make run
    ```
3. Check if the password in the `conf/grafana/.env` file lets you login (it should)

4. Now change the `GF_SECURITY_ADMIN_PASSWORD` to something else

5. Bring the stack down, build the new compose file and bring the container up

    ```bash
      make clean && make build && make run
    ```

This should bring in the new password set via the Environment Variable and grafana should let you
login via this new password

However, this new password is not set!

### Checks

- You can refer to the `docker-compose.yml` file which is generated via the `docker compose config` command
- You can also do `docker inspect test-grafana` to see that the env var `GF_SECURITY_ADMIN_PASSWORD` will
be the new password you adapted

However the container still keeps persisting the old envrionment variables

## _Solution_/ _Hack_

If you use

```bash
docker compose down --volumes
```

where you purge the volumes and restart again, only then is the new env variable actually set!


## Report

- [StackExchange Query](https://stackoverflow.com/questions/72256782/docker-compose-v2-does-not-pick-up-changes-from-env-file-even-after-updated-comp)
I created
