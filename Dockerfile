FROM debian:10 as builder

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -q -y update && \
    apt-get -q -y install wget \
                          curl \
                          git \
                          unzip \
                          build-essential \
                          golang && \
    apt-get -q -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    \
    git clone https://github.com/binance-chain/bsc /bsc && \
    cd /bsc && \
    make geth && \
    cd / && \
    \
    wget   $(curl -s https://api.github.com/repos/binance-chain/bsc/releases/latest |grep browser_ |grep mainnet |cut -d\" -f4) && \
    wget   $(curl -s https://api.github.com/repos/binance-chain/bsc/releases/latest |grep browser_ |grep testnet |cut -d\" -f4) && \
    \
    cp /bsc/build/bin/geth /usr/bin/geth && \
    tar cvf /transfer.tar /usr/bin/geth /*.zip

FROM debian:10

ENV NETWORK=main
COPY --from=builder /transfer.tar /transfer.tar

RUN cd / \
 && tar xvf /transfer.tar \
 && rm /transfer.tar && \
 \
 export DEBIAN_FRONTEND=noninteractive && \
 apt-get -q -y update && \
 apt-get -q -y install unzip && \
 apt-get -q -y clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# NODE P2P
EXPOSE 30311/udp
EXPOSE 30311/tcp

# pprof / metrics
EXPOSE 6060/tcp

# HTTP based JSON RPC API
EXPOSE 8545/tcp
# WebSocket based JSON RPC API
EXPOSE 8546/tcp
# GraphQL API
EXPOSE 8547/tcp

CMD sh -xc "cd /data; [ ! -f '/data/genesis.json' ] && unzip /$NETWORK'net.zip' && geth --datadir . init genesis.json && sed -i '/^HTTP/d' ./config.toml; exec geth --config ./config.toml --datadir . --pprof --pprofaddr 0.0.0.0 --metrics --rpc --rpcapi eth,net,web3,txpool,parlia --rpccorsdomain '*' --rpcvhosts '*' --rpcaddr 0.0.0.0 --rpcport 8545 --ws --wsapi eth,net,web3 --wsorigins '*' --wsaddr 0.0.0.0 --wsport 8546 --graphql --graphql.addr 0.0.0.0 --graphql.port 8587 --graphql.corsdomain '*' --graphql.vhosts '*'"
