#!/bin/bash

type -a markdown > /dev/null 2>&1 && MD_CONVERTER=markdown

type -a flavor > /dev/null 2>&1 && MD_CONVERTER=flavor

if [ -z "$MD_CONVERTER" ]; then
  echo "No markdown converter found!  You need markdown or flavor installed!"
  exit -1
fi

function to_html {
  local FILENAME_PATH=$(dirname "${1}")
  local FILENAME_MD="${1##*/}"
  local FILENAME_HTML=$(echo "${FILENAME_MD}" | sed -e 's/\.md/\.html/')

  sed -e 's/\.md/\.html/g' "${FILENAME_PATH}/${FILENAME_MD}" > "${FILENAME_PATH}/to_html.${FILENAME_MD}"
  type -a ${MD_CONVERTER} >/dev/null 2>&1 \
    && ${MD_CONVERTER} "${FILENAME_PATH}/to_html.${FILENAME_MD}" > "${FILENAME_PATH}/${FILENAME_HTML}"

  rm "${FILENAME_PATH}/to_html.${FILENAME_MD}"
}

# Generate our index file from the readme.md
#type -a flavor >/dev/null 2>&1 && flavor README.md > index.html

to_html "README.md"
to_html "content-creation.md"

for FILE in sections/*; do
  to_html "${FILE}"
done
