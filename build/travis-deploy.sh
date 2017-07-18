if [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
    rsync -r -vz _site/ nginx-user@skoji.jp:/usr/share/nginx/html/blog/
    echo done.
fi
