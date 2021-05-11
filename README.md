# Binance Smart Chain - Fullnode (main or test) - (servercontainers/bsc) [x86 + arm]

Binance Smart Chain Fullnode.

## Changelogs

* 2021-04-24
    * switched from `alpine` to `debian` due to bugs
* 2021-04-23
    * accept more connections (ws, rpc) and correct expose
    * http now listens to everything
* 2021-04-22
    * multiarch build

## Info

This is a Binance Smart Chain Fullnode Container running on `_/debian`.

For more see: https://docs.binance.org/smart-chain/developer/fullnode.html

## Environment variables and defaults

### Samba

*  __NETWORK__
    * _default:_ `main`
    * can be set to `main` or `test`
    * let's you choose which binance network to use 
    * with existing initialized persistent volume changing has no effect

### Volumes

* __/data__
    * data volume to store all the blockchain / binance smart chain data
    * will be initialized the first time with configured network genesis

### Ports

* 6060 `tcp`
    * pprof / metrics
* 8545 `tcp`
    * HTTP based JSON RPC API
* 8546 `tcp`
    * WebSocket based JSON RPC API
* 8547 `tcp`
    * GraphQL API    
* 30311 `udp` `tcp`
    * Node P2P

### Example docker-compose.yml

```
version: '3'
 
services:
  bsc:
    image: servercontainers/bsc
    restart: always
    environment:
      NETWORK: main
    volumes:
      - ./data:/data
    ports:
      - "127.0.0.1:6060:6060"
      - "127.0.0.1:8545:8545"
      - "127.0.0.1:8546:8546"
      - "127.0.0.1:8547:8547"
      - "30311:30311"
```
