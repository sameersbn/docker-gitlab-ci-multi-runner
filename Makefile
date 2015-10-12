all: build

build:
	@docker build --tag=quay.io/sameersbn/gitlab-ci-multi-runner .

release: build
	@docker build --tag=quay.io/sameersbn/gitlab-ci-multi-runner:$(shell cat VERSION) .
