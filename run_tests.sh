#!/bin/bash
npx nodemon --watch contracts --watch test --ext js,sol,json --exec npx truffle test

