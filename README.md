# gitlab-runner-docker

# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container base image for [gitlab-runner](https://gitlab.com/gitlab-org/gitlab-ci-runner). Use this image to build your docker CI runner images.

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes

## Installation
Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/peterwillcn/gitlab-runner-docker) and is the recommended method of installation.

```bash
docker pull peterwillcn/gitlab-runner-docker
```
Alternatively you can build the image yourself.

```bash
docker build -t gitlab-runner-docker github.com/peterwillcn/gitlab-runner-docker
```

## Quickstart

Before a runner can process your CI jobs, it needs to be authorized to access the the GitLab CI server. The `CI_SERVER_URL`, `RUNNER_TOKEN`, `RUNNER_DESCRIPTION` and `RUNNER_EXECUTOR` environment variables are used to register the runner on GitLab CI.

Update the values of `CI_SERVER_URL`, `RUNNER_TOKEN` and `RUNNER_DESCRIPTION` in the above command. If these enviroment variables are not specified, you will be prompted to enter these details interactively on first run.

```bash
docker-compose up -d

```
*Alternatively, you can use the sample [docker-compose.yml](docker-compose.yml) file to start the container using [Docker Compose](https://docs.docker.com/compose/)*

