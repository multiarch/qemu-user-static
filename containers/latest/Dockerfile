FROM busybox
ENV QEMU_BIN_DIR=/usr/bin
ADD ./register.sh /register
ADD https://raw.githubusercontent.com/qemu/qemu/f8d1ae82623fef4e7fb796efbaaa2ddc63594d09/scripts/qemu-binfmt-conf.sh /qemu-binfmt-conf.sh
RUN chmod +x /qemu-binfmt-conf.sh
COPY qemu-*-static /usr/bin/
ENTRYPOINT ["/register"]
