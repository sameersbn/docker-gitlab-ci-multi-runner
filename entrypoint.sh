#!/bin/bash
set -e

CA_CERTIFICATES_PATH=${CA_CERTIFICATES_PATH:-$GITLAB_CI_MULTI_RUNNER_DATA_DIR/certs/ca.crt}

create_data_dir() {
  mkdir -p ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}
  chown ${GITLAB_CI_MULTI_RUNNER_USER}:${GITLAB_CI_MULTI_RUNNER_USER} ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}
}

generate_ssh_deploy_keys() {
  sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} mkdir -p ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/

  if [[ ! -e ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa || ! -e ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa.pub ]]; then
    echo "Generating SSH deploy keys..."
    rm -rf ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa.pub
    sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} ssh-keygen -t rsa -N "" -f ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa

    echo ""
    echo -n "Your SSH deploy key is: "
    cat ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa.pub
    echo ""
  fi

  chmod 600 ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa.pub
  chmod 700 ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh
  chown -R ${GITLAB_CI_MULTI_RUNNER_USER}:${GITLAB_CI_MULTI_RUNNER_USER} ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/
}

update_ca_certificates() {
  if [[ -f ${CA_CERTIFICATES_PATH} ]]; then
    echo "Updating CA certificates..."
    cp "${CA_CERTIFICATES_PATH}" /usr/local/share/ca-certificates/ca.crt
    update-ca-certificates --fresh >/dev/null
  fi
}

grant_access_to_docker_socket() {
  if [ -S /run/docker.sock ]; then
    DOCKER_SOCKET_GID=$(stat -c %g  /run/docker.sock)
    DOCKER_SOCKET_GROUP=$(stat -c %G /run/docker.sock)
    if [[ ${DOCKER_SOCKET_GROUP} == "UNKNOWN" ]]; then
      DOCKER_SOCKET_GROUP=docker
      groupadd -g ${DOCKER_SOCKET_GID} ${DOCKER_SOCKET_GROUP}
    fi
    usermod -a -G ${DOCKER_SOCKET_GROUP} ${GITLAB_CI_MULTI_RUNNER_USER}
  fi
}

configure_ci_runner() {
  if [[ ! -e ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/config.toml ]]; then
    if [[ -n ${CI_SERVER_URL} && -n ${RUNNER_TOKEN} && -n ${RUNNER_DESCRIPTION} && -n ${RUNNER_EXECUTOR} ]]; then
      sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} \
        gitlab-ci-multi-runner register --config ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/config.toml \
          -n -u "${CI_SERVER_URL}" -r "${RUNNER_TOKEN}" --name "${RUNNER_DESCRIPTION}" --executor "${RUNNER_EXECUTOR}"
    else
      sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} \
        gitlab-ci-multi-runner register --config ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/config.toml
    fi
  fi
}

# allow arguments to be passed to gitlab-ci-multi-runner
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == gitlab-ci-multi-runner || ${1} == $(which gitlab-ci-multi-runner) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch gitlab-ci-multi-runner
if [[ -z ${1} ]]; then
  create_data_dir
  update_ca_certificates
  generate_ssh_deploy_keys
  grant_access_to_docker_socket
  configure_ci_runner

  start-stop-daemon --start \
    --chuid ${GITLAB_CI_MULTI_RUNNER_USER}:${GITLAB_CI_MULTI_RUNNER_USER} \
    --exec $(which gitlab-ci-multi-runner) -- run \
      --working-directory ${GITLAB_CI_MULTI_RUNNER_DATA_DIR} \
      --config ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/config.toml ${EXTRA_ARGS}
else
  exec "$@"
fi
