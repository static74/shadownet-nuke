# syntax=docker/dockerfile:1
FROM alpine
RUN export PATH=/hunter/Software:$PATH
RUN apk add --no-cache boost-dev vlc openjdk11-jre bash iproute2 grep sed
    # Clean up any unnecessary package indexes to keep the image small
    rm -rf /var/cache/apk/*
COPY . /hunter/Software
WORKDIR /hunter/Software
RUN ln -sf jre1.8.0_421 jre
RUN ln -sf shared_libs/libHardContact.so libHardContact.so
RUN ln -sf shared_libs/libVMD.so libVMD.so
RUN ln -sf shared_libs/libShotSensor.so libShotSensor.so
RUN ln -sf shared_libs/libCamPTZ.so libCamPTZ.so
RUN chmod +x run.sh
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV PATH="$JAVA_HOME/bin:$PATH"
EXPOSE 8888/tcp
EXPOSE 38423/tcp
EXPOSE 9010/tcp
EXPOSE 41675/tcp
EXPOSE 50000/tcp
EXPOSE 1025/tcp
EXPOSE 587/tcp
EXPOSE 22/tcp
#ENTRYPOINT ["./run.sh"]
CMD ["/bin/sh", "/hunter/Software/run.sh"]
