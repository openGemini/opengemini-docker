# openGemini Docker Image
Official docker images for the openGemini stack

## How to use this image

### start server instance

```shell
docker run -d -p 8086:8086 --name opengemini-server-example opengeminidb/opengemini-server
```

By default, starting above server instance will be run as the default user without password.

### connect to it from gemini cli

Download the latest `ts-cli` from [the latest release package](https://github.com/openGemini/openGemini/releases) and unzip the compressed package.


```shell
ts-cli -p 127.0.0.1 -p 8086
```

### stopping / removing the container

```shell
docker stop opengemini-server-example
docker rm opengemini-server-example
```

## Volumes

Typically, you may want to mount the following folders inside your container to achieve persistence:

- /var/lib/openGemini/ - main folder where openGemini stores the data
- /var/log/openGemini/ - logs

```shell
docker run -d \
    -v $(realpath_data):/var/lib/openGemini \
    -v $(realpath_logs):/var/log/openGemini \
    --name opengemini-server-example opengeminidb/opengemini-server
```
