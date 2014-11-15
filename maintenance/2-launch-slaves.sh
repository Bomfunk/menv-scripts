#!/bin/bash

source env.cfg

sudo ./maintenance/fuel-slaves.sh

echo "Now configure and deploy the environment."
echo "Do not forget to add master-key.pub to .ssh/authorized_keys of the master node."
echo "If you are not using 5.1, then you might want to check the preparation/ folder - it may need editing."
echo "After everything is ready - stop it properly and execute the final script: ./3-stop-and-save.sh"
