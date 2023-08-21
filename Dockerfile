FROM ubuntu

# Install dependencies (curl)
RUN apt-get update && apt-get install -y curl

# Copy files
COPY . .

# Install pvem
RUN ["/bin/bash", "-i", "-c", "./install.sh", "--no-prompt"]

# Keep container running
CMD tail -f /dev/null
