install:
	@./install.sh --local

test:
	@docker build -f test/Dockerfile.test -t pvem .
	@docker run -it --rm pvem

lint:
	shellcheck -e SC1090 -e SC1091 ./scripts/*.sh ./pvem/*.sh pvem.sh install.sh ./test/test.sh

.PHONY: test
