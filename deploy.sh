#!/usr/bin/env sh

# abort on errors
set -e

# clean up public
rm -rf public

# make public
mkdir -p "public"

# add CNAME file
echo 'schema.chora.io' >> public/CNAME

########## root ##########

cd public

# shellcheck disable=SC2129
echo "{" >> index.jsonld
echo "  \"contexts\": \"https://schema.chora.io/contexts\"," >> index.jsonld
echo "  \"examples\": \"https://schema.chora.io/examples\"" >> index.jsonld
echo "}" >> index.jsonld

echo "<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv=\"refresh\" content=\"0; url='index.jsonld'\" />
  </head>
</html>" >> index.html

cd ../

########## contexts ##########

cp -r contexts public/contexts
cd public/contexts

count=0
total=$(find . -type f | wc -l)

for f in *; do
  count=$((count+1))
  if [ $count -eq 1 ]; then
    echo "{" >> index.jsonld
  fi
  if [ $count -eq "$total" ]; then
    echo "  \"${f%.jsonld}\": \"https://schema.chora.io/contexts/$f\"" >> index.jsonld
    echo "}" >> index.jsonld
  else
    echo "  \"${f%.jsonld}\": \"https://schema.chora.io/contexts/$f\"," >> index.jsonld
  fi
done

echo "<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv=\"refresh\" content=\"0; url='index.jsonld'\" />
  </head>
</html>" >> index.html

cd ../../

########## examples ##########

cp -r examples public/examples
cd public/examples

count=0
total=$(find . -type f | wc -l)

for f in *; do
  count=$((count+1))
  if [ $count -eq 1 ]; then
    echo "{" >> index.jsonld
  fi
  if [ $count -eq "$total" ]; then
    echo "  \"${f%.jsonld}\": \"https://schema.chora.io/examples/$f\"" >> index.jsonld
    echo "}" >> index.jsonld
  else
    echo "  \"${f%.jsonld}\": \"https://schema.chora.io/examples/$f\"," >> index.jsonld
  fi
done

echo "<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv=\"refresh\" content=\"0; url='index.jsonld'\" />
  </head>
</html>" >> index.html

cd ../../

##############################

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
