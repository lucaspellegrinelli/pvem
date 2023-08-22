install:
	@./install.sh

test:
	@docker build -f Dockerfile.test -t pvem .
	@docker run -it --rm pvem
