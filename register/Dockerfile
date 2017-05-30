FROM busybox
ENV QEMU_BIN_DIR=/usr/bin
ADD ./register.sh /register
ADD ./qemu-binfmt-conf.sh /qemu-binfmt-conf.sh
ENTRYPOINT ["/register"]
