FROM sameersbn/ubuntu:14.04.20150613
MAINTAINER sameer@damagehead.com

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y supervisor git-core openssh-client \
 && rm -rf /var/lib/apt/lists/*

COPY assets/install.sh /var/cache/gitlab-ci-multi-runner/install.sh
RUN bash /var/cache/gitlab-ci-multi-runner/install.sh

COPY assets/entrypoint.sh /app/entrypoint.sh
RUN chmod 755 /app/entrypoint.sh

VOLUME ["/home/gitlab_ci_multi_runner/data"]
WORKDIR "/home/gitlab_ci_multi_runner"
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["app:start"]
