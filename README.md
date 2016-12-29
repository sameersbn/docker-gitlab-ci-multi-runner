[![Docker Repository on Quay.io](https://quay.io/repository/sameersbn/gitlab-ci-multi-runner/status "Docker Repository on Quay.io")](https://quay.io/repository/sameersbn/gitlab-ci-multi-runner)

# sameersbn/gitlab-ci-multi-runner:1.1.4-6

- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
  - [Changelog](Changelog.md)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Command-line arguments](#command-line-arguments)
  - [Persistence](#persistence)
  - [Deploy Keys](#deploy-keys)
  - [Trusting SSL Server Certificates](#trusting-ssl-server-certificates)
- [Maintenance](#maintenance)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)
- [List of runners using this image](#list-of-runners-using-this-image)

# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container base image for [gitlab-ci-multi-runner](https://gitlab.com/gitlab-org/gitlab-ci-multi-runner). Use this image to build your CI runner images.

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).
- Support the development of this image with a [donation](http://www.damagehead.com/donate/)

## Issues

Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

SELinux users should try disabling SELinux using the command `setenforce 0` to see if it resolves the issue.

If the above recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker version` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the image. Mask out the sensitive bits.
- Please state if you are using [Boot2Docker](http://www.boot2docker.io), [VirtualBox](https://www.virtualbox.org), etc.

# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/sameersbn/gitlab-ci-multi-runner) and is the recommended method of installation.

> **Note**: Builds are also available on [Quay.io](https://quay.io/repository/sameersbn/gitlab-ci-multi-runner)

```bash
docker pull sameersbn/gitlab-ci-multi-runner:1.1.4-6
```

Alternatively you can build the image yourself.

```bash
docker build -t sameersbn/gitlab-ci-multi-runner github.com/sameersbn/docker-gitlab-ci-multi-runner
```

## Quickstart

Before a runner can process your CI jobs, it needs to be authorized to access the the GitLab CI server. The `CI_SERVER_URL`, `RUNNER_TOKEN`, `RUNNER_DESCRIPTION` and `RUNNER_EXECUTOR` environment variables are used to register the runner on GitLab CI.

```bash
docker run --name gitlab-ci-multi-runner -d --restart=always \
  --volume /srv/docker/gitlab-runner:/home/gitlab_ci_multi_runner/data \
  --env='CI_SERVER_URL=http://git.example.com/ci' --env='RUNNER_TOKEN=xxxxxxxxx' \
  --env='RUNNER_DESCRIPTION=myrunner' --env='RUNNER_EXECUTOR=shell' \
  sameersbn/gitlab-ci-multi-runner:1.1.4-6
```

*Alternatively, you can use the sample [docker-compose.yml](docker-compose.yml) file to start the container using [Docker Compose](https://docs.docker.com/compose/)*

Update the values of `CI_SERVER_URL`, `RUNNER_TOKEN` and `RUNNER_DESCRIPTION` in the above command. If these enviroment variables are not specified, you will be prompted to enter these details interactively on first run.

## Command-line arguments

You can customize the launch command by specifying arguments to `gitlab-ci-multi-runner` on the `docker run` command. For example the following command prints the help menu of `gitlab-ci-multi-runner` command:

```bash
docker run --name gitlab-ci-multi-runner -it --rm \
  --volume /srv/docker/gitlab-runner:/home/gitlab_ci_multi_runner/data \
  sameersbn/gitlab-ci-multi-runner:1.1.4-6 --help
```

## Persistence

For the image to preserve its state across container shutdown and startup you should mount a volume at `/home/gitlab_ci_multi_runner/data`.

> *The [Quickstart](#quickstart) command already mounts a volume for persistence.*

SELinux users should update the security context of the host mountpoint so that it plays nicely with Docker:

```bash
mkdir -p /srv/docker/gitlab-runner
chcon -Rt svirt_sandbox_file_t /srv/docker/gitlab-runner
```

## Deploy Keys

At first run the image automatically generates SSH deploy keys which are installed at `/home/gitlab_ci_multi_runner/data/.ssh` of the persistent data store. You can replace these keys with your own if you wish to do so.

You can use these keys to allow the runner to gain access to your private git repositories over the SSH protocol.

> **NOTE**
>
> - The deploy keys are generated without a passphrase.
> - If your CI jobs clone repositories over SSH, you will need to build the ssh known hosts file which can be done in the build steps using, for example, `ssh-keyscan github.com | sort -u - ~/.ssh/known_hosts -o ~/.ssh/known_hosts`.

## Trusting SSL Server Certificates

If your GitLab server is using self-signed SSL certificates then you should make sure the GitLab server's SSL certificate is trusted on the runner for the git clone operations to work.

The runner is configured to look for trusted SSL certificates at `/home/gitlab_ci_multi_runner/data/certs/ca.crt`. This path can be changed using the `CA_CERTIFICATES_PATH` enviroment variable.

Create a file named `ca.crt` in a `certs` folder at the root of your persistent data volume. The `ca.crt` file should contain the root certificates of all the servers you want to trust.

With respect to GitLab, append the contents of the `gitlab.crt` file to `ca.crt`. For more information on the `gitlab.crt` file please refer the [README](https://github.com/sameersbn/docker-gitlab/blob/master/README.md#ssl) of the [docker-gitlab](https://github.com/sameersbn/docker-gitlab) container.

Similarly you should also trust the SSL certificate of the GitLab CI server by appending the contents of the `gitlab-ci.crt` file to `ca.crt`.

# Maintenance

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull sameersbn/gitlab-ci-multi-runner:1.1.4-6
  ```

  2. Stop the currently running image:

  ```bash
  docker stop gitlab-ci-multi-runner
  ```

  3. Remove the stopped container

  ```bash
  docker rm -v gitlab-ci-multi-runner
  ```

  4. Start the updated image

  ```bash
  docker run -name gitlab-ci-multi-runner -d \
    [OPTIONS] \
    sameersbn/gitlab-ci-multi-runner:1.1.4-6
  ```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it gitlab-ci-multi-runner bash
```

# List of runners using this image

* [docker-gitlab-ci-multi-runner-ruby](https://github.com/outcoldman/docker-gitlab-ci-multi-runner-ruby) to run ruby builds
