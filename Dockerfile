FROM debian:bullseye-slim

RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
                   ca-certificates \
                   libasound2 \
                   libatk-bridge2.0-0 \
                   libatk1.0-0 \
                   libcups2 \
                   libgbm1 \
                   libgtk-3-0 \
                   libnss3 \
                   libsndfile1 \
                   wget && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/VOICEVOX/voicevox/releases/download/0.14.10/voicevox-linux-cpu-0.14.10.tar.gz && \
    tar zxfv voicevox-linux-cpu-0.14.10.tar.gz

CMD /VOICEVOX/run --host 172.18.50.21
