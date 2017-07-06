all: build

build:
	@docker build --tag=zerrtech/gitlab-ci-multi-runner .

release: build
	@docker build --tag=zerrtech/gitlab-ci-multi-runner:$(shell cat VERSION) .
