#!/bin/bash

make DEBUG=0
make DEBUG=0 MACOS=1
lipo -create .theos/obj/crackit .theos/obj/macosx/crackit -output crackit
