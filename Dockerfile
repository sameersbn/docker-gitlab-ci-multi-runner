#FROM alpine:3.8
FROM docker:18.06
LABEL author="xiaobo <peterwillcn@gmail.com>" version="0.0.1" \
  description="This is a base image for gitlab-runner for docker"

ENV GITLAB_RUNNER_USER=gitlab-runner
ENV GITLAB_RUNNER_HOME_DIR="/home/${GITLAB_RUNNER_USER}"
ENV GITLAB_RUNNER_DATA_DIR="${GITLAB_RUNNER_HOME_DIR}/data"

RUN apk add --update --no-cache sudo bash shadow ca-certificates git openssl tzdata wget && \
  rm -rf /var/cache/apk/*

RUN addgroup -S ${GITLAB_RUNNER_USER} && adduser -D -S -G ${GITLAB_RUNNER_USER} -h ${GITLAB_RUNNER_HOME_DIR} ${GITLAB_RUNNER_USER}
RUN sudo -HEu ${GITLAB_RUNNER_USER} ln -sf ${GITLAB_RUNNER_DATA_DIR}/.ssh ${GITLAB_RUNNER_HOME_DIR}/.ssh

ENV DOCKER_MACHINE_VERSION=0.15.0
RUN wget -O /usr/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64 && \
    chmod +x /usr/bin/gitlab-runner && \
    ln -s /usr/bin/gitlab-runner /usr/bin/gitlab-ci-multi-runner && \
    gitlab-runner --version && \
    wget -q https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine-Linux-x86_64 -O /usr/bin/docker-machine && \
    chmod +x /usr/bin/docker-machine && \
    docker-machine --version

ENV DUMB_INIT_VERSION=1.2.2
RUN wget -q https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 -O /usr/bin/dumb-init && \
    chmod +x /usr/bin/dumb-init && \
    dumb-init --version

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod +x /sbin/entrypoint.sh

VOLUME ["${GITLAB_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_RUNNER_HOME_DIR}"

ENTRYPOINT ["/usr/bin/dumb-init", "/sbin/entrypoint.sh"]
