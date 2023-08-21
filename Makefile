install:
	@./install.sh

test:
	# Create the docker image with the tab pvem and run it
	@docker build -t pvem .
	@docker run -it --rm pvem
