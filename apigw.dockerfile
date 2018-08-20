FROM kong:0.13.0-centos

# TODO: Remove the requirement for netcat
RUN yum update -y && yum install gcc gcc-c++ openssl openssl-devel make unzip nc git ruby -y

RUN luarocks install lbase64 && \
        luarocks install lua-cjson && \
        luarocks install luacrypto && \
        luarocks install busted && \
        luarocks install inspect

RUN mkdir -p /opt/kong-custom-plugin/ && \
    mkdir /opt/kong-custom-plugin/kong-okta-auth-plugin/

COPY . /opt/kong-custom-plugin/kong-okta-auth-plugin

RUN cd /opt/kong-custom-plugin/kong-okta-auth-plugin && \
    luarocks make

ARG ZIPKIN_PLUGIN_VERSION=0.1.2

RUN cd /opt/kong-custom-plugin && \
    wget https://github.com/Mokaffe/kong-plugin-zipkin/archive/${ZIPKIN_PLUGIN_VERSION}.tar.gz && \
    tar -xvzf ${ZIPKIN_PLUGIN_VERSION}.tar.gz && \
    cd kong-plugin-zipkin-${ZIPKIN_PLUGIN_VERSION} && \
    luarocks make

COPY scripts/ /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/start-kong.sh"]
