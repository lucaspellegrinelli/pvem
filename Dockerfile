FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y curl wget make gcc zlib1g-dev

COPY . .

RUN ["/bin/bash", "-i", "-c", "./install.sh --no-prompt"]

CMD ["/bin/bash", "-i", "-c", "chmod +x ./test.sh && ./test.sh"]
