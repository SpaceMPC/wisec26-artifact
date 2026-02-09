FROM ubuntu:20.04

# Install common dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && \
    apt-get -y install sudo \
    automake \
    build-essential \
    clang \
    cmake \
    git \
    libboost-dev \
    libboost-filesystem-dev \ 
    libboost-iostreams-dev \
    libboost-thread-dev \
    libgmp-dev \
    libntl-dev \
    libsodium-dev \
    libssl-dev \
    libtool \
    python3 \
    python3-pip \ 
    openssl \
    graphviz-dev \
    git \
    autoconf \
    nano \
    libboost-all-dev

# Add a new user ubuntu, pass: ubuntu
RUN groupadd ubuntu && \
    useradd -rm -d /home/ubuntu -s /bin/bash -g ubuntu -G sudo -u 1000 ubuntu -p "$(openssl passwd -1 ubuntu)"

RUN chmod 777 /tmp

# Use ubuntu as default username
USER ubuntu
WORKDIR /home/ubuntu

# Import environment variable to pass as parameter to make (e.g., to make paral>
ARG MAKE_OPT

ARG TARGETPLATFORM    # e.g. "linux/amd64" or "linux/arm64/v8"
ARG TARGETARCH        # e.g. "amd64" or "arm64"

# Show the automatic mapping that BuildKit provides
RUN echo "Docker reports: ${TARGETPLATFORM}, ${TARGETARCH}"

RUN git clone https://github.com/data61/MP-SPDZ.git && \
    cd MP-SPDZ && \
    git checkout -b 91321ff && \
    touch CONFIG.mine
#    echo "ARCH = -march=armv8 \nUSE_NTL=1\nMY_CFLAGS += -DINSECURE" > CONFIG.mine

# Use TARGETARCH to drive the `-march` flag
RUN arch_opt=$(case "$TARGETARCH" in \
        amd64) echo '-march=x86-64' ;; \
        arm64) echo '-march=armv8-a' ;; \
        *)     echo '' ;; \
      esac) \
    && echo "ARCH = ${arch_opt}\nUSE_NTL=1\nMY_CFLAGS += -DINSECURE\nMY_CFLAGS += -DRING_SIZE=154" > CONFIG.mine


RUN cd MP-SPDZ && \
    make libote

RUN cd MP-SPDZ && \
    make semi-he 
RUN cd MP-SPDZ && \
     make rep-field rep-ring 
RUN cd MP-SPDZ && \
     make shamir 
RUN cd MP-SPDZ && \
     make sy
RUN cd MP-SPDZ && \
     make mascot
RUN cd MP-SPDZ && \ 
     make semi-party.x
RUN cd MP-SPDZ && \
     make semi2k-party.x


USER root
RUN apt-get install -y openssh-server openssh-client

RUN mkdir /var/run/sshd
RUN mkdir /home/ubuntu/.ssh/

RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER ubuntu
RUN pip install tqdm
RUN cd MP-SPDZ && \
    ./Scripts/setup-ssl.sh    

CMD ["sudo", "-i", "-u", "root", "/usr/sbin/sshd", "-D"] 

#USER ubuntu
