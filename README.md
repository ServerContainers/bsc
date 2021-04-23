# Binance Smart Chain - Fullnode (main or test) - (servercontainers/bsc) [x86 + arm]

Binance Smart Chain Fullnode.

## Changelogs

* 2021-04-23
    * accept more connections (ws, rpc) and correct expose
* 2021-04-22
    * multiarch build

## Info

This is a Binance Smart Chain Fullnode Container running on `_/alpine`.

For more see: https://docs.binance.org/smart-chain/developer/fullnode.html

## Environment variables and defaults

### Samba

*  __NETWORK__
    * default: `main`
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
    * rpc / http

* 8546 `tcp`
    * websocket


* 30311 `udp` `tcp`
    * node p2p

