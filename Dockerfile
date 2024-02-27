# Use a base image with a minimal Linux distribution
FROM alpine:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the Bash script into the container
COPY git.sh /app/git.sh

# Make the script executable
RUN chmod +x /app/git.sh

# Define the default command to run when the container starts
CMD ["/app/git.sh"]
