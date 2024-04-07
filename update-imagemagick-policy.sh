#!/bin/sh

# look for the path of policy.xml of ImageMagick
POLICY_XML=$(find /etc -name "policy.xml" | grep -m 1 'ImageMagick')

# If policy.xml is found ，change it to allow pdf conversion
if [ ! -z "$POLICY_XML" ]; then
    sed -i '/<policy domain="coder" rights="none" pattern="PDF" \/>/c\<policy domain="coder" rights="read|write" pattern="PDF" \/>' "$POLICY_XML"
fi
