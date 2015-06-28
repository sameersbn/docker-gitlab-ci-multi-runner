#!/bin/bash
set -e

# add git user
adduser --disabled-login --gecos 'GitLab CI Runner' ${GITLAB_CI_MULTI_RUNNER_USER}

sudo -Hu ${GITLAB_CI_MULTI_RUNNER_USER} ln -s ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh ${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/.ssh

# download the gitlab-ci-multi-runner binary
wget -O /usr/local/bin/gitlab-ci-multi-runner \
  https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-ci-multi-runner-linux-amd64
chmod +x /usr/local/bin/gitlab-ci-multi-runner

# create supervisor job for the runner
cat > /etc/supervisor/conf.d/runner.conf <<EOF
[program:runner]
priority=20
directory=${GITLAB_CI_MULTI_RUNNER_HOME_DIR}
environment=HOME=${GITLAB_CI_MULTI_RUNNER_HOME_DIR}
command=/usr/local/bin/gitlab-ci-multi-runner run
  --working-directory ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}
  --config ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/config.toml
user=${GITLAB_CI_MULTI_RUNNER_USER}
autostart=true
autorestart=true
stopsignal=INT
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
EOF
