# Docker

Expose the Docker Remote API on Mac with a container using the socat utility to map the UNIX sock to a TCP/IP socket.

## Commands

```
docker run --detach=true --dns=172.16.0.5 --dns=172.22.0.6 --dns=1.1.1.1 --hostname=docker.gautier.local --name=docker.gautier.docker --network=gautier.docker --restart=always --ip=172.22.0.2 --publish=4243:4243/tcp --volume=/var/run/docker.sock:/var/run/docker.sock docker:run
```

```
docker rmi $(docker images -a -q)


```


--ip=172.22.0.2 --publish=4243:4243/tcp --volume=/var/run/docker.sock:/var/run/docker.sock
