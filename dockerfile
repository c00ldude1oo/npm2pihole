FROM bash:5.2.37-alpine3.20
RUN apk add --no-cache openssh-client
WORKDIR /app
COPY main.bash /app
CMD bash main.bash
