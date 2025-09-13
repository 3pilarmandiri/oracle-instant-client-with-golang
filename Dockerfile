FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update -q \
    && apt-get install -y -q --no-install-recommends \
    libaio1t64 libaio-dev unzip curl ca-certificates build-essential wget  \
    && rm -rf /var/lib/apt/lists/*

# Oracle Instant Client
ENV ORACLE_BASE=/opt/oracle/instantclient
ENV ORACLE_HOME=${ORACLE_BASE}/instantclient_12_2
RUN mkdir -p $ORACLE_HOME && mkdir -p $ORACLE_HOME/lib

COPY ./install /tmp/install
RUN unzip /tmp/install/instantclient-basic-linux.x64-12.2.0.1.0.zip -d $ORACLE_BASE \
    && unzip /tmp/install/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d $ORACLE_BASE \
    && unzip /tmp/install/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d $ORACLE_BASE

# Environment for Oracle client
ENV LD_LIBRARY_PATH=$ORACLE_HOME
ENV PATH=$ORACLE_HOME:$PATH
RUN echo "$ORACLE_HOME" > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig

# Fix symlinks
RUN ln -sf /usr/lib/x86_64-linux-gnu/libaio.so $ORACLE_HOME/libaio.so.1 \
    && ln -sf $ORACLE_HOME/libclntsh.so.* $ORACLE_HOME/libclntsh.so \
    && ln -sf $ORACLE_HOME/libocci.so.* $ORACLE_HOME/libocci.so \
    && ln -sf $ORACLE_HOME/libclntsh.so.12.1 $ORACLE_HOME/lib/libclntsh.so

# Install Go
ARG GO_VERSION=1.25.0
ENV GO_VERSION=${GO_VERSION}
ENV PATH=/usr/local/go/bin:$PATH

RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

RUN rm -rf /tmp/install  

