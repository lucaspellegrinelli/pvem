install:
	@./install.sh

test:
	@docker build -f test/Dockerfile.test -t pvem .
	@docker run -it --rm pvem

.PHONY: test
