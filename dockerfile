FROM bash:5.2.15-alpine3.18
RUN apk add --no-cache openssh-client inotify-tools
WORKDIR /app
COPY main.bash /app
CMD bash main.bash
