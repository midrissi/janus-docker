FROM     ubuntu:14.04
MAINTAINER Mohamed IDRISSI "med.idrissi@outlook.com"

# install dependencies
RUN apt-get update && apt-get install -y build-essential autoconf automake git-core nano mercurial subversion build-essential autoconf automake libmicrohttpd-dev libjansson-dev libnice-dev libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev libopus-dev libogg-dev libini-config-dev libcollection-dev pkg-config gengetopt libtool wget

# Install rabbitmq-c
RUN cd /root && git clone https://github.com/alanxz/rabbitmq-c && cd rabbitmq-c && git submodule init && git submodule update
RUN cd /root/rabbitmq-c && autoreconf -i && ./configure --prefix=/usr && make && make install

# Install usrsctp
RUN cd /root && svn co http://sctp-refimpl.googlecode.com/svn/trunk/KERN/usrsctp usrsctp && cd usrsctp && ./bootstrap && ./configure --prefix=/usr && make && make install

# Install libopus
RUN cd /root && wget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz && tar xfv opus-1.1.tar.gz && cd opus-1.1 && ./configure --prefix=/usr && make && make install

# Install Janus gateway
RUN cd /root && git clone https://github.com/meetecho/janus-gateway.git
RUN cd /root/janus-gateway && git checkout master
RUN cd /root/janus-gateway && ./autogen.sh && ./configure --prefix=/opt/janus --disable-websockets --disable-docs && make && make install
RUN ln -s /usr/lib64/librabbitmq.so.1 /usr/lib

### Cleaning ###
RUN apt-get clean && apt-get autoclean && apt-get autoremove

# Activate all plugins
RUN cd /opt/janus/etc/janus && rename 's/\.sample$//' *.sample

EXPOSE 8088
EXPOSE 8188
EXPOSE 7088

CMD /opt/janus/bin/janus --config /opt/janus/etc/janus/janus.cfg --configs-folder=/opt/janus/etc/janus --port=8088 --secure-port=8188 --no-websockets --admin-port=7088 --debug-level=4
