#!/bin/bash

mkdir kubernetes
cat temp/files.list | xargs -I @ wget -P kubernetes @
cp temp/files.list ./kubernetes
tar zcvf offline_files.tar.gz kubernetes
rm -rf offline_files