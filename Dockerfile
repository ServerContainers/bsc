FROM alpine as builder

ARG GOLANG_VERSION=1.16.3
ENV PATH=$PATH:/usr/local/go/bin

RUN apk add --no-cache git curl wget make go gcc bash linux-headers musl-dev openssl-dev ca-certificates \
 && update-ca-certificates \
 && wget https://dl.google.com/go/go$GOLANG_VERSION.src.tar.gz \
 && tar -C /usr/local -xzf go$GOLANG_VERSION.src.tar.gz \
 \
 && cd /usr/local/go/src \
 && ./make.bash \
 && apk del go \
 && go version \
 && cd /

RUN git clone https://github.com/binance-chain/bsc /bsc \
 && cd /bsc \
 && git checkout $(git tag | grep '^v.' | grep -v '-' | sort -r | head -n1) \
 && sed -i 's/PamBMopnHxO2nEIsU89ibVVnqnXR2yFTgGNc+PdG68o=/DnZGUjFbRkpytojHWwy6nfUSA7vFrzWXDLpFNzt74ZA=/g' go.sum \
 && make geth \
 && cd /

RUN wget   $(curl -s https://api.github.com/repos/binance-chain/bsc/releases/latest |grep browser_ |grep mainnet |cut -d\" -f4) \
 && wget   $(curl -s https://api.github.com/repos/binance-chain/bsc/releases/latest |grep browser_ |grep testnet |cut -d\" -f4)

RUN cp /bsc/build/bin/geth /usr/bin/geth \
 && tar cvf /transfer.tar /usr/bin/geth /*.zip

FROM alpine
ENV NETWORK=main

COPY --from=builder /transfer.tar /transfer.tar

RUN cd / \
 && tar xvf /transfer.tar

# NODE P2P
EXPOSE 30311/udp
EXPOSE 30311/tcp

# pprof / metrics
EXPOSE 6060

# HTTP / RPC
EXPOSE 8545
# Websocket
EXPOSE 8546

CMD sh -xc "cd /data; [ ! -f '/data/genesis.json' ] && unzip /$NETWORK'net.zip' && geth --datadir . init genesis.json && sed -i '/^HTTP/d' ./config.toml; exec geth --config ./config.toml --datadir . --pprof --pprofaddr 0.0.0.0 --metrics --ws --wsapi eth,net,web3 --wsorigins '*' --wsaddr 0.0.0.0 --wsport 8546 --rpc --rpcapi eth,net,web3,txpool,parlia --rpccorsdomain '*' --rpcvhosts '*' --rpcaddr 0.0.0.0 --rpcport 8545"
