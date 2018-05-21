#! /bin/bash

rm -rf dist
rm footnotes.zip
mkdir dist
cp -R manifest.json *.html images js dist
cd dist
zip -r ../footnotes.zip ./*
cd ..
