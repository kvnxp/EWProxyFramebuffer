#!/bin/sh

cp -R ./Release/EWProxyFrameBufferApp.app /Applications/

rm -rf /System/Library/Extensions/EWProxy*

cp -R ./Release/EWProxyFrameBuffer.kext /System/Library/Extensions
cp -R ./Release/EWProxyFrameBufferConnection.framework /System/Library/Extensions

chown -R root:wheel /System/Library/Extensions/EWProxy*
chmod -R 755 /System/Library/Extensions/EWProxy*