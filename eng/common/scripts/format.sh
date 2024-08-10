#!/usr/bin/env bash

find . -name "*.sln" -print0 | while read -d $'\0' file
do
  echo "Formatting: $file"
  dotnet format whitespace "$file"
  dotnet format analyzers "$file"
  dotnet format style "$file"
done