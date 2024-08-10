#!/usr/bin/env bash

# Stop script if unbound variable found (use ${var:-} if intentional)
set -u

# Stop script if command returns non-zero exit code.
# Prevents hidden errors caused by missing error code propagation.
set -e

usage()
{
  echo "Common settings:"
  echo "  --configuration <value>    Build configuration: 'Debug' or 'Release' (short: -c)"
  echo "  --verbosity <value>        Msbuild verbosity: q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic] (short: -v)"
  echo "  --help                     Print help and exit (short: -h)"
  echo ""

  echo "Actions:"
  echo "  --restore                  Restore dependencies (short: -r)"
  echo "  --build                    Build solution (short: -b)"
  echo "  --rebuild                  Rebuild solution"
  echo "  --test                     Run all unit tests in the solution (short: -t)"
  echo "  --integrationTest          Run all integration tests in the solution"
  echo "  --pack                     Package build outputs into NuGet packages and Willow components"
  echo "  --publish                  Publish artifacts (e.g. symbols)"
  echo "  --clean                    Clean the solution"
  echo ""

  echo "Advanced settings:"
  echo "  --projects <value>       Project or solution file(s) to build"
  echo "  --ci                     Set when running on CI server"
  echo "  --warnAsError <value>    Sets warnaserror msbuild parameter ('true' or 'false')"
  echo ""
}

source="${BASH_SOURCE[0]}"
scriptroot="$( cd -P "$( dirname "$source" )" && pwd )"

restore=false
build=false
rebuild=false
test=false
integration_test=false
pack=false
publish=false
ci=false
clean=false

warn_as_error=true

projects=''
configuration='Debug'
verbosity='minimal'

properties=''
while [[ $# > 0 ]]; do
  opt="$(echo "${1/#--/-}" | tr "[:upper:]" "[:lower:]")"
  case "$opt" in
    -help|-h)
      usage
      exit 0
      ;;
    -clean)
      clean=true
      ;;
    -configuration|-c)
      configuration=$2
      shift
      ;;
    -verbosity|-v)
      verbosity=$2
      shift
      ;;
    -restore|-r)
      restore=true
      ;;
    -build|-b)
      build=true
      ;;
    -rebuild)
      rebuild=true
      ;;
    -pack)
      pack=true
      ;;
    -test|-t)
      test=true
      ;;
    -integrationtest)
      integration_test=true
      ;;
    -publish)
      publish=true
      ;;
    -projects)
      projects=$2
      shift
      ;;
    -ci)
      ci=true
      ;;
    -warnaserror)
      warn_as_error=$2
      shift
      ;;
    *)
      properties="$properties $1"
      ;;
  esac

  shift
done

. "$scriptroot/tools.sh"

if [[ "$clean" == true ]]; then
  if [ -d "$artifacts_dir" ]; then
    rm -rf $artifacts_dir
    echo "Artifacts directory deleted."
  fi
  exit 0
fi

if [[ ! -z "$projects" ]]; then
  properties="$properties /p:Projects=$projects"
fi

MSBuild \
  /p:Configuration=$configuration \
  /p:RepoRoot="$repo_root" \
  /p:Restore=$restore \
  /p:Build=$build \
  /p:Rebuild=$rebuild \
  /p:Test=$test \
  /p:Pack=$pack \
  /p:IntegrationTest=$integration_test \
  /p:Publish=$publish \
  $properties

ExitWithExitCode 0
