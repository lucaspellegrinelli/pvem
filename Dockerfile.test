FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y curl wget make gcc zlib1g-dev

COPY . .

RUN chmod +x ./test.sh
RUN ./install.sh --no-prompt

CMD ["/bin/bash", "-i", "-c", "./test.sh"]
