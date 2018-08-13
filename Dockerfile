FROM mrsaints/kong-dev

WORKDIR /okta-auth

RUN luarocks install lua-cjson \
    && luarocks install lbase64

COPY . .

RUN make install
