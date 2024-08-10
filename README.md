# Repo Builder

A simple automation tool that uses msbuild to build projects with complex folder structures for Windows and Linux based systems. Implementation is based on [dotnet/arcade](https://github.com/dotnet/arcade) excluding Microsoft's own things.

## Getting Started

1. Install the latest dotnet SDK.

2. Copy and past these folders and files to your repository:

```
├── eng
│   └── common                  # the toolset
├── Directory.Build.props       # enable properties from the toolset
├── Directory.Build.targets     # enables tasks from the toolset
├── Build.cmd                   # build tool for windows
├── build.sh                    # build tool for linux based systems
├── global.json
```

3. Adjust `global.json` to use the dotnet version you have installed.

4. Add your projects and start building:

```bash
dotnet new console -n MyConsole -o src

# using dotnet command
dotnet build --project src/MyConsole

# using scripts from the toolset
build.{sh,cmd} src/**/*.csproj
```

## Dependencies

The toolset only requires `dotnet` and `msbuild`. Both are included in the SDK.

## Configurations

Configurations and tasks can added using `Directory.Build.{props,targets}` files. You may want to use this globally or locally depending on your use case and repository structure.

**Global**

Global properties and tasks can be found under `\eng\*.{props,targets}` directory. They should be used to enforce global repo behaviours.

**Project Specific**

For project specific configurations, add a `Directory.Build.{props,targets}` to its root directory. Make sure to import the repo root props and targets. Eg:

```
(repo root)
└── src
    ├── ProjectA
    │   └── Directory.Build.props
```

```xml
<Project>
  <Import Project="..\..\Directory.Build.props" />

  <PropertyGroup>
    <PropertyForProjectA>MyProperty</PropertyForProjectA>
  </PropertyGroup>
</Project>
```

Remember that msbuild props and targets applies to the root where the file is located and all subfolders.

**Excluding**

To exclude projects from using the toolset, simply add an empty `Directory.Build.{props,targets}` to its root. Check **project-3-excluded** sample.

## Scripts

There's a set of built-in scripts at `eng\common\scripts` where you can copy and paste wherever needed. These scripts help you chain workflows or use different behaviours for specific projects.

Check **project-2** folder for samples.

## Tests

Test projects are automatically detected using Tests, UniTests or IntegrationTests suffixes. Upon detection, the toolset will add the required dependencies and configure xUnit as the default runner. You can however configure to your liking by manipulating the following properties:

```xml
<!-- MyProject.csproj -->
<PropertyGroup>
  <!-- Test runner: 'MSTest' | 'XUnit' -->
  <TestRunnerName>MSTest</TestRunnerName>
  <!-- Defaults to true if project ends with 'Tests' or 'UnitTests' -->
  <IsUnitTestProject>false</IsUnitTestProject>
  <!-- Defaults to true if project ends with 'IntegrationTests' -->
  <IsIntegrationTestProject>false</IsIntegrationTestProject>
  <!-- Force tests to run only in specific OS -->
  <IsUnitTestProject Condition="'$(OS)' == 'Windows_NT'">true</IsUnitTestProject>
</PropertyGroup>
```

Test logs and results can be found at `artifacts\logs` and `artifacts\TestResults`.

## Artifacts

Build, publish and pack output can be found inside `artifacts` directory at the root level. They are grouped by project name.
