FROM mrsaints/kong-dev

WORKDIR /okta-auth

RUN luarocks install lua-cjson

COPY . .

RUN make install
