Runtime considerations
======================

Runtime setup
-------------

Bazel rules maintain the list of files required to run given executable.
When the run is requested (via bazel run or bazel test) then a manifest
file is generated by Bazel. Rules_dotnet uses this file to link all
runtime files in the same directory as the executable to run.

Bazel works best in the
[monorepo](https://en.wikipedia.org/wiki/Monorepo) scenario where all
dependencies are built by it using the same .NET Core runtime version.
An attempt to build some common open source libraries is maintained
[here](https://github.com/tomaszstrejczek/rules_dotnet_3rd_party).

However, many .NET Core projects are composed of multiple dependencies
gathered via Nuget. Those dependencies are often built using different
versions of .NET Core. Typically, msbuild-based build systems handle it
automatically by providing appropriate deps.json and runtimeconfig.json
files. See [this article](https://natemcmaster.com/blog/2017/12/21/netcore-primitives/)
for a very interesting overview.

Unfortunately, Bazel dotnet rules currently are not able to generate
these files. Therefore, if multiple versions of .NET Core are mixed then
a user has to provide them manually.

