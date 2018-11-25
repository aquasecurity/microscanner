FROM alpine:latest
ARG token
RUN apk add --no-cache ca-certificates \
  && update-ca-certificates \
  && wget https://get.aquasec.com/microscanner -O /microscanner \
  && echo "8e01415d364a4173c9917832c2e64485d93ac712a18611ed5099b75b6f44e3a5  /microscanner" | sha256sum -c - \
  && chmod +x /microscanner \
  && /microscanner ${token}