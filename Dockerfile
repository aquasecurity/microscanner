FROM alpine:latest
ARG token
RUN apk add --no-cache ca-certificates \
  && update-ca-certificates \
  && wget https://get.aquasec.com/microscanner -O /microscanner \
  && echo "72fd95ef5d343915c37ad487ba83da56e4d79d2f999cbdb2bfb1afda0d6bd7bb  /microscanner" | sha256sum -c - \
  && chmod +x /microscanner \
  && /microscanner ${token}