FROM alpine:latest
RUN apk add --no-cache ca-certificates && update-ca-certificates
ADD https://get.aquasec.com/microscanner /
RUN microscannerHash=`md5sum microscanner | awk '{ print $1 }'`; \
    if [ "$microscannerHash" != "1d911d709cb9efb02a4661926af979a6" ]; then echo Microscanner md5 is incorrect;exit 1; fi
RUN chmod +x /microscanner
ARG token
RUN /microscanner ${token}