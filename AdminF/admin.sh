# The initial runner to get the tool running
#!/bin/bash

# Will always run from the tool base directory
cd "$(dirname "$0")" || exit 1

source core/main.sh
