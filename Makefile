install:
	@./install.sh

test:
	@docker build -t pvem .
	@docker run -it --rm pvem
