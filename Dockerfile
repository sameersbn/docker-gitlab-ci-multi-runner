FROM sameersbn/ubuntu:14.04.20151213
MAINTAINER sameer@damagehead.com

ENV GITLAB_CI_MULTI_RUNNER_VERSION=0.7.2 \
    GITLAB_CI_MULTI_RUNNER_USER=gitlab-runner \
    GITLAB_CI_MULTI_RUNNER_HOME_DIR="/home/gitlab-runner"
ENV GITLAB_CI_MULTI_RUNNER_DATA_DIR="${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/data"

RUN wget -q -O - "https://packages.gitlab.com/gpg.key" | sudo apt-key add - \
 && echo "deb http://packages.gitlab.com/runner/gitlab-ci-multi-runner/ubuntu/ trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      gitlab-ci-multi-runner=${GITLAB_CI_MULTI_RUNNER_VERSION} \
      git-core openssh-client curl libapparmor1 libapparmor1 \
 && sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} ln -sf ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh ${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/.ssh \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

VOLUME ["${GITLAB_CI_MULTI_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_CI_MULTI_RUNNER_HOME_DIR}"
ENTRYPOINT ["/sbin/entrypoint.sh"]
