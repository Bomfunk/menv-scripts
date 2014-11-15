#!/bin/bash

./maintenance/save-snapshots.sh
./destroy-env.sh

echo "Congratulations! Your new mobile environment is ready to be used."
