# Use a base image with a minimal Linux distribution
FROM alpine:latest

# Set the working directory inside the container
WORKDIR /app

RUN addgroup -S devtron && adduser -S -G devtron devtron
RUN chmod -R 755 /app

# Copy the Bash script into the container
COPY git.sh /app/git.sh


RUN chown -R devtron:devtron /app/git.sh
RUN chown -R devtron:devtron /app


# Make the script executable
RUN apk update && \
    apk add git curl

    

    
RUN chmod +x /app/git.sh
#CMD ["sh /app/myscript.sh"]


USER devtron

CMD ["sh","/app/git.sh"]

