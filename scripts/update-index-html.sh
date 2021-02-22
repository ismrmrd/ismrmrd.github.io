#!/bin/bash

folder=$1
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

cat > $SCRIPTPATH/../index.html<< EOF
<html>
  <head>
    <meta http-equiv="refresh" content="0;url=https://ismrmrd.github.io/${folder}" />
    <title></title>
  </head>
 <body></body>
</html>
EOF