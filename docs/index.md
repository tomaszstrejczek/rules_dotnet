---
layout: default
---

Overview
========

This is a minimal viable set of C# bindings for building C# code with
[.NET Core](https://en.wikipedia.org/wiki/.NET_Core).

Caveats
========

These rules are not compatible with [sandboxing](https://bazel.io/blog/2015/09/11/sandboxing.html).
Particularly, running dotnet rules on Linux or OSX requires passing --spawn_strategy=standalone.

[Bazel](https://bazel.build/) creates long paths. Therefore it is recommended to increase the length limit 
using newer version of Windows. Please see 
[here](https://docs.microsoft.com/en-us/windows/desktop/fileio/naming-a-file#maximum-path-length-limitation).

However, some Windows programs do not handle long path names. Most notably - Microsoft 
C compiler (cl.exe). Therefore TMP env variable should be set to something 
short (like X:\\ or c:\\TEMP). 

[Bazel](https://bazel.build/) and dotnet_rules rely on symbolic linking. On Windows it, typically, requires 
elevated permissions. However, newer versions of Windows have a [workaround](https://blogs.windows.com/buildingapps/2016/12/02/symlinks-windows-10/#IJuxPHWEkSSRqC7w.97>).

Setup
-----

* Add the following to your `WORKSPACE` file to add the external repositories:

  ```python

    # A newer version should be fine
    load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
    git_repository(
        name = "io_bazel_rules_dotnet",
        remote = "https://github.com/bazelbuild/rules_dotnet",
        branch = "master",
    )

    load("@io_bazel_rules_dotnet//dotnet:deps.bzl", "dotnet_repositories")
    dotnet_repositories()

    load("@io_bazel_rules_dotnet//dotnet:defs.bzl", "core_register_sdk", "dotnet_register_toolchains", "dotnet_repositories_nugets")
    dotnet_register_toolchains()
    dotnet_repositories_nugets()
    core_register_sdk()
    ```

  The [dotnet_repositories](api.md#dotnet_repositories) rule fetches external dependencies which have to be defined before loading
  any other file of rules_dotnet. [dotnet_repositories_nugets](api.md#dotnet_repositories_nugets) loads nuget packages required by test rules.

  The [dotnet_register_toolchains](api.md#dotnet_register_toolchains) configures toolchains.

  The [core_register_sdk](api.md#core_register_sdk) "glues" toolchains with appropriate SDKs.

* Add a file named ``BUILD.bazel`` in the root directory of your
  project. In general, you need one of these files in every directory
  with dotnet code.
  At the top of the file used rules should be imported:

  ```python
    load("@io_bazel_rules_dotnet//dotnet:defs.bzl", "core_library", "core_binary")
  ```

* Depending on .NET Core version used it may be necessary to install libunwind-devel on Linux systems.

* See [nuget2bazel](nuget2bazel.md) for handling Nuget dependencies.

Advanced usage
--------------

* See [toolchains](toolchains.md) for advanced toolchain usage.

* [Handling multiple versions](multiversion.md).

* [Setting up CI agenet](ci.md).

* [Native dependencies in nuget](nuget_native_deps.md).

* [Building documentation](docs.md)
