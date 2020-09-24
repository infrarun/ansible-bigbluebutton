#!/bin/bash

IS_MASTER=`mongo mongodb://127.0.1.1:27017/ --eval  'db.isMaster().ismaster' | tail -n 1`
if [ "$IS_MASTER" \!= "true" ]; then
        mongo 127.0.1.1 --eval 'rs.initiate({ _id: "rs0", members: [ {_id: 0, host: "127.0.1.1"} ]})'
fi
