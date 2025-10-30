FROM jrottenberg/ffmpeg:7-ubuntu

# VOLUME [ "/output" ]

WORKDIR /ffmpeg

COPY ./ffmpeg-lastframe.sh /ffmpeg/

RUN apt-get update && apt-get install -y bc && rm -rf /var/lib/apt/lists/*

RUN chmod +x ./ffmpeg-lastframe.sh

ENTRYPOINT [ "bash" ]

CMD [ "./ffmpeg-lastframe.sh" ]



