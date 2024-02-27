# Use a base image with a minimal Linux distribution
FROM alpine:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the Bash script into the container
COPY git.sh /app/git.sh

# Make the script executable
RUN apk update && \
    apk add git
# Update and install Curl
RUN apk update && \
    apk add curl
RUN apk update && \
    apk add rsync
    
RUN chmod +x /app/git.sh

