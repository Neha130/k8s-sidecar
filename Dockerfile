# Use a base image with a minimal Linux distribution
FROM alpine:latest

# Set the working directory inside the container
WORKDIR /app




# Copy the Bash script into the container
COPY git.sh /app/git.sh





# Make the script executable
RUN apk update && \
    apk add git curl


    
RUN chmod +x /app/git.sh
#CMD ["sh /app/myscript.sh"]




CMD ["sh","/app/git.sh"]

