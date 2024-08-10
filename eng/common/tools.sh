function ResolvePath {
  local path=$1
  while [[ -h $path ]]; do
    local dir="$( cd -P "$( dirname "$path" )" && pwd )"
    path="$(readlink "$path")"
    [[ $path != /* ]] && path="$dir/$path"
  done
  _ResolvePath="$path"
}

function ExitWithExitCode {
  if [[ "$ci" == true ]]; then
    StopProcesses
  fi
  exit $1
}

function StopProcesses {
  echo "Killing running build processes..."
  pkill -9 "dotnet" || true
  pkill -9 "vbcscompiler" || true
  return 0
}

function MSBuild {
  dotnet msbuild "$eng_root/common/tools/Build.proj" /m /nologo /clp:Summary /v:$verbosity /warnaserror /p:TreatWarningsAsErrors=$warn_as_error "$@" || {
    local exit_code=$?
    echo "Build failed with exit code $exit_code. Check errors above."
    ExitWithExitCode $exit_code
  }
}

ResolvePath "${BASH_SOURCE[0]}"
_script_dir=`dirname "$_ResolvePath"`

eng_root=`cd -P "$_script_dir/.." && pwd`
repo_root=`cd -P "$_script_dir/../.." && pwd`
repo_root="${repo_root}/"
artifacts_dir="${repo_root}artifacts"
log_dir="$artifacts_dir/log/$configuration"
temp_dir="$artifacts_dir/tmp/$configuration"
global_json_file="${repo_root}global.json"

mkdir -p "$temp_dir"
mkdir -p "$log_dir"
