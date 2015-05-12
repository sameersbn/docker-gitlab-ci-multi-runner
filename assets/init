#!/bin/bash
set -e

HOME_DIR="/home/gitlab_ci_multi_runner"
DATA_DIR="${HOME_DIR}/data"

CA_CERTIFICATES_PATH=${CA_CERTIFICATES_PATH:-$DATA_DIR/certs/ca.crt}

# create and take ownership of ${DATA_DIR}
mkdir -p ${DATA_DIR}
chown gitlab_ci_multi_runner:gitlab_ci_multi_runner ${DATA_DIR}

# create the .ssh directory
sudo -u gitlab_ci_multi_runner -H mkdir -p ${DATA_DIR}/.ssh/

# generate deploy key
if [ ! -e ${DATA_DIR}/.ssh/id_rsa -o ! -e ${DATA_DIR}/.ssh/id_rsa.pub ]; then
  echo "Generating SSH deploy keys..."
  rm -rf ${DATA_DIR}/.ssh/id_rsa ${DATA_DIR}/.ssh/id_rsa.pub
  sudo -u gitlab_ci_multi_runner -H ssh-keygen -t rsa -N "" -f ${DATA_DIR}/.ssh/id_rsa
fi

# make sure the ssh keys have the right ownership and permissions
chmod 600 ${DATA_DIR}/.ssh/id_rsa ${DATA_DIR}/.ssh/id_rsa.pub
chmod 700 ${DATA_DIR}/.ssh
chown -R gitlab_ci_multi_runner:gitlab_ci_multi_runner ${DATA_DIR}/.ssh/

if [ -f "${CA_CERTIFICATES_PATH}" ]; then
  echo "Updating CA certificates..."
  cp "${CA_CERTIFICATES_PATH}" /usr/local/share/ca-certificates/ca.crt
  update-ca-certificates --fresh >/dev/null
fi

appStart () {
  echo "Starting gitlab-ci-multi-runner..."

  # make sure the runner is configured
  if [ ! -e ${DATA_DIR}/config.toml ]; then
    appSetup
  fi
  exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
}

appSetup () {
  if [ -n "${CI_SERVER_URL}" -a -n "${RUNNER_TOKEN}" -a -n "${RUNNER_DESCRIPTION}" -a -n "${RUNNER_EXECUTOR}" ]; then
    sudo -u gitlab_ci_multi_runner -H \
      gitlab-ci-multi-runner register --config config.toml \
        -u "${CI_SERVER_URL}" -r "${RUNNER_TOKEN}" -d "${RUNNER_DESCRIPTION}" -e "${RUNNER_EXECUTOR}"
  else
    sudo -u gitlab_ci_multi_runner -H \
      gitlab-ci-multi-runner register --config config.toml
  fi
  mv config.toml "${DATA_DIR}/config.toml"
}

appHelp () {
  echo "Available options:"
  echo " app:start          - Starts the gitlab-ci-multi-runner (default)"
  echo " app:setup          - Setup the runner. Interactively or by passing URL, Token and Description params."
  echo " app:help           - Displays the help"
  echo " [command]          - Execute the specified linux command eg. bash."
}

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
    if [ -x $1 ]; then
      $1
    else
      prog=$(which $1)
      if [ -n "${prog}" ] ; then
        shift 1
        $prog $@
      else
        appHelp
      fi
    fi
    ;;
esac

exit 0
