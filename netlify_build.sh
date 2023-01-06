#!/bin/sh

bundle exec rake build && \
    mkdir -p netlify_deploy && \
    rm -rf netlify_deploy/* && \
    cp -Rp _site netlify_deploy/blog
