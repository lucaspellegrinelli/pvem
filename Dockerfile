FROM ubuntu

# Install dependencies
RUN apt-get update
RUN apt-get install -y curl wget make gcc zlib1g-dev

# Copy files
COPY . .

# Install pvem
RUN ["/bin/bash", "-i", "-c", "./install.sh", "--no-prompt"]

# Keep container running
CMD tail -f /dev/null
