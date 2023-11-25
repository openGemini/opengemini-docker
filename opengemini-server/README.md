# Quick reference

- Maintained by:  
  [openGemini](https://github.com/openGemini/opengemini-docker)

# Supported tags and respective Dockerfile links
- [1.1.1-alpine](https://github.com/openGemini/opengemini-docker/blob/main/opengemini-server/1.1.1/alpine/Dockerfile)
- [1.1.1, latest](https://github.com/openGemini/opengemini-docker/blob/main/opengemini-server/1.1.1/Dockerfile)
- [1.1.0-alpine](https://github.com/openGemini/opengemini-docker/blob/main/opengemini-server/1.1.0/alpine/Dockerfile), [1.1.0](https://github.com/openGemini/opengemini-docker/blob/main/opengemini-server/1.1.0/Dockerfile)
- [1.0.1](https://github.com/openGemini/opengemini-docker/blob/main/opengemini-server/1.0.1/alpine/Dockerfile)
- [1.0.0](https://github.com/openGemini/opengemini-docker/blob/main/opengemini-server/1.0.0/alpine/Dockerfile)

# Quick reference (cont.)

- **Where to file issues**: 
  
  [https://github.com/openGemini/opengemini-docker/issues](https://github.com/openGemini/opengemini-docker/issues?q=)
  
- **Supported architectures**: ([more info](https://github.com/docker-library/official-images#architectures-other-than-amd64))
  
  `amd64`, `arm64`

# openGemini Docker Image

Official docker images for the openGemini stack.

openGemini is an open-source,cloud-native time-series database(TSDB) that can be widely used in IoT, Internet of Vehicles(IoV), O&M monitoring, and industrial Internet scenarios.It developed by HUAWEI CLOUD and it has excellent read/write performance and efficient data analysis capabilities. It uses an SQL-like query language, does not rely on third-party software, and is easy to install, deploy, and maintain. We encourage contribution and collaboration to the community.

[openGemini Documentation](https://docs.opengemini.org/)

![openGemini-logo](https://user-images.githubusercontent.com/49023462/231386185-a18cd5dd-30ef-4d03-b86b-3119b16843a0.png)

## How to use this image

### start server instance

```shell
docker run -d -p 8086:8086 --name opengemini-server-example opengeminidb/opengemini-server
```

By default, starting above server instance will be run as the default user without password.

### connect to it from gemini cli

```shell
docker exec -it opengemini-server-example ts-cli
```

You can also download the latest `ts-cli` from [the latest release package](https://github.com/openGemini/openGemini/releases) and unzip the compressed package.

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
