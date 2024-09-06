#!/bin/bash

# I have added the comments at each step for the explaination. 
# Step 1: Create the main "projects" directory
mkdir -p projects

# List of project names
projects=("facebook" "google" "meta" "oracle")

# Step 2: Loop through each project and create the directory structure
for project in "${projects[@]}"; do
  # Create the project directory
  mkdir -p "projects/$project"
  
  # For google and meta, create the "oriserve" directory
  if [[ "$project" == "google" || "$project" == "meta" ]]; then
    mkdir -p "projects/$project/oriserve"
  fi
done

# Step 3: Find "oriserve" directories and create test.txt with "oriserve" inside
find projects -type d -name "oriserve" | while read dir; do
  # Create the test.txt file with "oriserve" as its content
  echo "oriserve" > "$dir/test.txt"
done

echo "Folder structure created and test.txt added to oriserve folders."
