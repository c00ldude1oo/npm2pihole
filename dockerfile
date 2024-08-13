FROM bash:5.2.21-alpine3.18
RUN apk add --no-cache openssh-client
WORKDIR /app
COPY main.bash /app
CMD bash main.bash
