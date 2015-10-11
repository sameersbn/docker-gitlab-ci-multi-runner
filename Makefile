all: build

build:
	@docker build --tag=quay.io/sameersbn/gitlab-ci-multi-runner .
