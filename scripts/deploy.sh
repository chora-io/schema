#!/usr/bin/env sh

# abort on errors
set -e

# clean up public
rm -rf public

# make public
mkdir -p "public"

# copy directories
cp -r contexts public/contexts
cp -r examples public/examples

# add CNAME file
echo 'schema.chora.io' >> public/CNAME

# change to public directory
cd public

# clean up git
rm -rf .git

# git init and commit
git init
git add -A
git commit -m 'publish'

# push to gh-pages branch
git push https://github.com/choraio/schema master:gh-pages -f

cd -
