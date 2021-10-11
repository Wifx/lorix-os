FROM wifx/lorix-os-sdk

# GO
ARG GO_VERSION=1.16
ARG GO_ARCHIVE_NAME=go${GO_VERSION}.linux-amd64.tar.gz

RUN wget https://golang.org/dl/${GO_ARCHIVE_NAME}
RUN tar -xvf ${GO_ARCHIVE_NAME}
RUN mv go /usr/local
RUN rm ${GO_ARCHIVE_NAME}

ENV GOROOT /usr/local/go
ENV GOPATH $WORKDIR
ENV PATH $GOROOT/bin:$PATH

ENV CGO_ENABLED 1
ENV GOOS linux
ENV GOARCH arm
ENV GOARM 7

ENV CGO_CFLAGS="-march=armv7-a -marm -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a5 --sysroot=$SDKTARGETSYSROOT"
ENV CGO_LDFLAGS="--sysroot=$SDKTARGETSYSROOT"
