#!/usr/bin/env bash

export ASPNETCORE_ENVIRONMENT=Development
export DOTNET_ENVIRONMENT=Development

if [[ $1 == "" ]]; then
  code .
else
  code $1
fi

exit 1
