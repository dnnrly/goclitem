#!/bin/sh

echo "Enter your username (Github org):"
read ORG

echo "Enter the name of your project:"
read NAME

set -e
set -x

for f in `find . -type f -not -iwholename '*.git*' -not -iwholename '*tmp*' -not -iwholename '*libexec*' -not -iwholename '*bin*' -not -iwholename '*share*' -not -iwholename '*setup*'`
do
    sed -i -e "s/dnnrly/${ORG}/g" $f
    sed -i -e "s/goclitem/${NAME}/g" $f
done

mv ./cmd/goclitem ${NAME}
