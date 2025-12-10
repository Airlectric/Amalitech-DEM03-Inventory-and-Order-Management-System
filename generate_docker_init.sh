#!/bin/bash
# generate_docker_init.sh
# This script flattens ddl/ and dml/ files into docker_init/ with numbered prefixes.


DOCKER_INIT_DIR="./sql/docker_init"

# Ensure the docker_init directory exists
mkdir -p "$DOCKER_INIT_DIR"

# Clear old files
rm -f $DOCKER_INIT_DIR/*.sql

# Prefix counter
count=1

# Function to generate prefix like 01, 02, ...
generate_prefix() {
  printf "%02d" $1
}

# Copy DDL files
for file in ./sql/ddl/*.sql; do
  prefix=$(generate_prefix $count)
  base=$(basename $file)
  cp "$file" "$DOCKER_INIT_DIR/${prefix}_ddl_${base}"
  count=$((count + 1))
done

# Copy DML files
for file in ./sql/dml/*.sql; do
  prefix=$(generate_prefix $count)
  base=$(basename $file)
  cp "$file" "$DOCKER_INIT_DIR/${prefix}_dml_${base}"
  count=$((count + 1))
done

echo "docker_init/ folder updated with flattened SQL files."
