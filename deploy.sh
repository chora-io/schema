#!/usr/bin/env sh

# abort on error
set -e

# clean up public
rm -rf public

# make public
mkdir -p "public"

# add CNAME file
echo 'schema.chora.io' >> public/CNAME

# json template for all indexes
index_json_template='{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": []
}'

# html redirect for all indexes
index_html="<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv=\"refresh\" content=\"0; url='index.jsonld'\" />
  </head>
</html>"

# set index json using template
index_json="$index_json_template"

# add contexts item to index json
index_json=$(echo "$index_json" | jq -r '.itemListElement += [{
  "@type": "ListItem",
  "position": 1,
  "item": {
    "@id": "https://schema.chora.io/contexts/index.jsonld",
    "name": "contexts"
  }
}]')

# add examples item to index json
index_json=$(echo "$index_json" | jq -r '.itemListElement += [{
  "@type": "ListItem",
  "position": 2,
  "item": {
    "@id": "https://schema.chora.io/examples/index.jsonld",
    "name": "examples"
  }
}]')

# add templates item to index json
index_json=$(echo "$index_json" | jq -r '.itemListElement += [{
  "@type": "ListItem",
  "position": 3,
  "item": {
    "@id": "https://schema.chora.io/templates/index.jsonld",
    "name": "templates"
  }
}]')

# add site index json
echo "$index_json" >> public/index.jsonld

# add site index redirect
echo "$index_html" >> public/index.html

# generate public files
gen_public_files() {

  # copy jsonld files
  cp -r "$1" public/"$1"

  # change directories
  cd public/"$1"

  # index item count
  count=0

  # index item total
  total=$(find . -type f | wc -l)

  # set index json using template
  index_json="$index_json_template"

  # loop through files
  for f in *; do

    # increment count
    count=$((count+1))

    # set item id
    id="https://schema.chora.io/$1/$f"

    # set item name
    name=$(echo "$f" | sed -e "s|.jsonld||")

    # set jq arguments (argjson required for integer)
    args="--argjson position $count --arg id $id --arg name $name"

    # add index item to index json
    index_json=$(echo "$index_json" | jq -r $args '.itemListElement += [{
      "@type": "ListItem",
      "position": $position,
      "item": {
        "@id": $id,
        "name": $name
      }
    }]')

  done

  # add index json
  echo "$index_json" >> index.jsonld

  # add index redirect
  echo "$index_html" >> index.html

  # change directories
  cd ../../
}

# generate public files
gen_public_files "contexts"
gen_public_files "examples"
gen_public_files "templates"

# change directories
cd public

# git init and commit
git init
git add -A
git commit -m 'publish'

# push to gh-pages branch
git push https://github.com/choraio/schema master:gh-pages -f
