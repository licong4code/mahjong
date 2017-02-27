# !/usr/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$PACKER_TOOLS_ROOT/excel2lua $DIR/config $DIR/lua
cp $DIR/lua/* $DIR/../client/mahjong/src/app/config/