#!/bin/bash
set -e

CA_CERTIFICATES_PATH=${CA_CERTIFICATES_PATH:-$GITLAB_CI_MULTI_RUNNER_DATA_DIR/certs/ca.crt}

create_data_dir() {
  mkdir -p ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}
  chown ${GITLAB_CI_MULTI_RUNNER_USER}:${GITLAB_CI_MULTI_RUNNER_USER} ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}
}

generate_ssh_deploy_keys() {
  sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} mkdir -p ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/

  if [ ! -e ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa -o ! -e ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa.pub ]; then
    echo "Generating SSH deploy keys..."
    rm -rf ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa.pub
    sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} ssh-keygen -t rsa -N "" -f ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa
  fi

  chmod 600 ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/id_rsa.pub
  chmod 700 ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh
  chown -R ${GITLAB_CI_MULTI_RUNNER_USER}:${GITLAB_CI_MULTI_RUNNER_USER} ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh/
}

update_ca_certificates() {
  if [ -f "${CA_CERTIFICATES_PATH}" ]; then
    echo "Updating CA certificates..."
    cp "${CA_CERTIFICATES_PATH}" /usr/local/share/ca-certificates/ca.crt
    update-ca-certificates --fresh >/dev/null
  fi
}

appStart () {
  echo "Starting gitlab-ci-multi-runner..."

  # make sure the runner is configured
  if [ ! -e ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/config.toml ]; then
    appSetup
  fi

  start-stop-daemon --start \
    --chuid ${GITLAB_CI_MULTI_RUNNER_USER}:${GITLAB_CI_MULTI_RUNNER_USER} \
    --exec /usr/local/bin/gitlab-ci-multi-runner -- run \
      --working-directory ${GITLAB_CI_MULTI_RUNNER_DATA_DIR} \
      --config ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/config.toml
}

appSetup () {
  if [ -n "${CI_SERVER_URL}" -a -n "${RUNNER_TOKEN}" -a -n "${RUNNER_DESCRIPTION}" -a -n "${RUNNER_EXECUTOR}" ]; then
    sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} \
      gitlab-ci-multi-runner register --config config.toml \
        -n -u "${CI_SERVER_URL}" -r "${RUNNER_TOKEN}" -d "${RUNNER_DESCRIPTION}" -e "${RUNNER_EXECUTOR}"
  else
    sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} \
      gitlab-ci-multi-runner register --config config.toml
  fi
  mv config.toml "${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/config.toml"
}

appHelp () {
  echo "Available options:"
  echo " app:start          - Starts the gitlab-ci-multi-runner (default)"
  echo " app:setup          - Setup the runner. Interactively or by passing URL, Token and Description params."
  echo " app:help           - Displays the help"
  echo " [command]          - Execute the specified linux command eg. bash."
}

create_data_dir
generate_ssh_deploy_keys
update_ca_certificates

case "$1" in
  app:start)
    appStart
    ;;
  app:setup)
    appSetup
    ;;
  app:help)
    appHelp
    ;;
  *)
    if [ -x ${1} ]; then
      $@
    else
      prog=$(which ${1})
      if [ -n "${prog}" ] ; then
        shift 1
        exec ${prog} $@
      else
        appHelp
      fi
    fi
    ;;
esac

exit 0
