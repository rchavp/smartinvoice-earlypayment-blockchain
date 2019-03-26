## This container will make sure we have a persisted local blockchain
## along with all the tools to create, text and deply smart contracts
FROM node:8
MAINTAINER Tradeshift Frontiers

ARG CONFIG_ENV=local
ARG NODE_ENV=development
RUN test -n "$CONFIG_ENV"
RUN test -n "$NODE_ENV"
ENV CONFIG_ENV $CONFIG_ENV
ENV NODE_ENV $NODE_ENV

WORKDIR /root

## Add common aliases and up/down arrow hist search
RUN echo "alias ll='ls -l'" >> .bashrc \
  && echo "alias lll='ls -l -a'" >> .bashrc \
  && echo "\"\e[B\": history-search-forward" >> .inputrc \
  && echo "\"\e[A\": history-search-backward" >> .inputrc


RUN apt update && apt -y full-upgrade

WORKDIR /mount

COPY ./ ./smart-invoice

WORKDIR /mount/smart-invoice

RUN npm install

RUN rm -rf dist

