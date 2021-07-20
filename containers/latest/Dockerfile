FROM busybox
ENV QEMU_BIN_DIR=/usr/bin
ADD ./register.sh /register
ADD https://raw.githubusercontent.com/qemu/qemu/7c81570d932268a9626457a662f1c5046ebc455e/scripts/qemu-binfmt-conf.sh /qemu-binfmt-conf.sh
RUN chmod +x /qemu-binfmt-conf.sh
COPY qemu-*-static /usr/bin/
ENTRYPOINT ["/register"]
