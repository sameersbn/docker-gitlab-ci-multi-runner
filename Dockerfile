FROM ubuntu:xenial
MAINTAINER sameer@damagehead.com


RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      vim.tiny wget sudo net-tools ca-certificates unzip git openssh-client curl libapparmor1

ENV GITLAB_CI_MULTI_RUNNER_VERSION=1.9.3 \
    GITLAB_CI_MULTI_RUNNER_USER=gitlab_ci_multi_runner \
    GITLAB_CI_MULTI_RUNNER_HOME_DIR="/home/gitlab_ci_multi_runner"
ENV GITLAB_CI_MULTI_RUNNER_DATA_DIR="${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/data"

ENV CA_CERTIFICATES_PATH=''
ENV RUNNER_CONCURRENT=''
ENV CI_SERVER_URL=''
ENV RUNNER_TOKEN=''
ENV RUNNER_EXECUTOR='docker'
ENV RUNNER_DESCRIPTION=''

ENV RUNNER_DOCKER_IMAGE='docker:latest'
ENV RUNNER_DOCKER_MODE='socket'
ENV RUNNER_DOCKER_PRIVATE_REGISTRY_URL=''
ENV RUNNER_DOCKER_PRIVATE_REGISTRY_TOKEN=''
ENV RUNNER_DOCKER_ADDITIONAL_VOLUME=''
ENV RUNNER_OUTPUT_LIMIT='4096'

RUN wget -O /usr/local/bin/gitlab-ci-multi-runner \
      https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/v${GITLAB_CI_MULTI_RUNNER_VERSION}/binaries/gitlab-ci-multi-runner-linux-amd64 \
 && chmod 0755 /usr/local/bin/gitlab-ci-multi-runner \
 && adduser --disabled-login --gecos 'GitLab CI Runner' ${GITLAB_CI_MULTI_RUNNER_USER} \
 && sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} ln -sf ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh ${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/.ssh \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

RUN rm -rf /var/lib/apt/lists/*

VOLUME ["${GITLAB_CI_MULTI_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_CI_MULTI_RUNNER_HOME_DIR}"
ENTRYPOINT ["/sbin/entrypoint.sh"]
