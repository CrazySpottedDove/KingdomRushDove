#!/bin/bash

rm tmp/chars.txt

rg -o '[一-鿿]' --no-filename --no-line-number --text --glob '*.lua' | sort | uniq | tr -d '\n' > tmp/chars.txt

echo "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789,.?!:;\'\"“”‘’()[]{}<>+-=*/%#@&_~|^$￥" >> tmp/chars.txt
echo "，。、？！；：‘’“”（）【】《》〈〉「」『』———…￥·,.?!:;\'\"“”‘’()[]{}<>+-=*/%#@&_~|^$￥→←±×鹿" >> tmp/chars.txt

pyftsubset _assets/all-desktop/fonts/msyh.ttc --output-file=tmp/msyh_minify.ttc --text-file=tmp/chars.txt --font-number=0
pyftsubset _assets/all-desktop/fonts/msyhbd.ttc --output-file=tmp/msyhbd_minify.ttc --text-file=tmp/chars.txt --font-number=0
pyftsubset _assets/all-desktop/fonts/JIMOJW.ttf --output-file=tmp/JIMOJW_minify.ttf --text-file=tmp/chars.txt --font-number=0