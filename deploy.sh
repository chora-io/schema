#!/usr/bin/env sh

# abort on errors
set -e

# clean up public
rm -rf public

# make public
mkdir -p "public"

# add CNAME file
echo 'schema.chora.io' >> public/CNAME

gen_public_files() {

  # copy jsonld files
  cp -r "$1" public/"$1"

  # change directories
  cd public/"$1"

  # file count
  count=0

  # file total
  total=$(find . -type f | wc -l)

  # add index
  for f in *; do
    count=$((count+1))
    if [ $count -eq 1 ]; then
      echo "{" >> index.jsonld
    fi
    if [ $count -eq "$total" ]; then
      echo "  \"${f%.jsonld}\": \"https://schema.chora.io/$1/$f\"" >> index.jsonld
      echo "}" >> index.jsonld
    else
      echo "  \"${f%.jsonld}\": \"https://schema.chora.io/$1/$f\"," >> index.jsonld
    fi
  done

  # add index redirect
  echo "<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv=\"refresh\" content=\"0; url='index.jsonld'\" />
  </head>
</html>" >> index.html

  # change directories
  cd ../../
}

gen_public_files "contexts"
gen_public_files "examples"
gen_public_files "templates"

# change directories
cd public

# add index
echo "{
  \"contexts\": \"https://schema.chora.io/contexts/index.jsonld\",
  \"examples\": \"https://schema.chora.io/examples/index.jsonld\",
  \"templates\": \"https://schema.chora.io/templates/index.jsonld\"
}" >> index.jsonld

# add index redirect
echo "<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv=\"refresh\" content=\"0; url='index.jsonld'\" />
  </head>
</html>" >> index.html

# git init and commit
git init
git add -A
git commit -m 'publish'

# push to gh-pages branch
git push https://github.com/choraio/schema master:gh-pages -f
