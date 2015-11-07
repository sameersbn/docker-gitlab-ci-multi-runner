all: build

build:
	@docker build --tag=sameersbn/gitlab-ci-multi-runner .

release: build
	@docker build --tag=sameersbn/gitlab-ci-multi-runner:$(shell cat VERSION) .
