FROM kong:0.13.0-centos

# TODO: Remove the requirement for netcat
RUN yum update -y && yum install gcc gcc-c++ openssl openssl-devel make unzip nc git which -y

RUN luarocks install lbase64 && \
        luarocks install lua-cjson && \
        luarocks install luacrypto && \
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

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -L get.rvm.io | bash -s stable 

RUN mkdir /integration
COPY integration/ /integration
RUN /bin/bash -l -c "rvm install 2.4.0"
RUN /bin/bash -l -c "rvm use 2.4.0 --default"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
RUN /bin/bash -l -c "cd /integration && bundle install"

COPY scripts/ /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/start-kong.sh"]
