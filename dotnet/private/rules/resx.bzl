load(
    "//dotnet/private:context.bzl",
    "dotnet_context",
)
load(
    "//dotnet/private:providers.bzl",
    "DotnetResourceListInfo",
)
load("@rules_dotnet_skylib//lib:paths.bzl", "paths")

def _resx_impl(ctx):
    """dotnet_resx_impl emits actions for compiling resx to resource."""
    dotnet = dotnet_context(ctx)
    name = ctx.label.name

    # Handle case of empty toolchain on linux and darwin
    if dotnet.resx == None:
        result = dotnet.declare_file(dotnet, path = "empty.resources")
        dotnet.actions.write(output = result, content = ".net not supported on this platform")
        empty = dotnet.new_resource(dotnet = dotnet, name = name, result = result)
        return [empty, DotnetResourceListInfo(result = [empty])]

    resource = dotnet.resx(
        dotnet,
        name = name,
        src = ctx.attr.src,
        identifier = ctx.attr.identifier,
        out = ctx.attr.out,
        customresgen = ctx.attr.simpleresgen,
    )
    return [
        resource,
        DotnetResourceListInfo(result = [resource]),
        DefaultInfo(
            files = depset([resource.result]),
        ),
    ]

def _resx_multi_impl(ctx):
    dotnet = dotnet_context(ctx)
    name = ctx.label.name

    if ctx.attr.identifierBase != "" and ctx.attr.fixedIdentifierBase != "":
        fail("Both identifierBase and fixedIdentifierBase cannot be specified")

    result = []
    for d in ctx.attr.srcs:
        for k in d.files.to_list():
            base = paths.dirname(ctx.build_file_path)
            if ctx.attr.identifierBase != "":
                identifier = k.path.replace(base, ctx.attr.identifierBase, 1)
                identifier = identifier.replace("/", ".")
                identifier = paths.replace_extension(identifier, ".resources")
            else:
                identifier = ctx.attr.fixedIdentifierBase + "." + paths.basename(k.path)
                identifier = paths.replace_extension(identifier, ".resources")

            resource = dotnet.resx(
                dotnet = dotnet,
                name = identifier,
                src = k,
                identifier = identifier,
                out = identifier,
                customresgen = ctx.attr.simpleresgen,
            )
            result.append(resource)

    return [
        DotnetResourceListInfo(result = result),
        DefaultInfo(
            files = depset([d.result for d in result]),
        ),
    ]

core_resx = rule(
    _resx_impl,
    attrs = {
        # source files for this target.
        "src": attr.label(allow_files = [".resx"], mandatory = True, doc = "The .resx source file that is transformed into .resources file."),
        "identifier": attr.string(doc = "The logical name for the resource; the name that is used to load the resource. The default is the basename of the file name (no subfolder)."),
        "out": attr.string(doc = "An alternative name of the output file"),
        "dotnet_context_data": attr.label(default = Label("@io_bazel_rules_dotnet//:core_context_data"), doc = "The reference to label created with [core_context_data rule](api.md#core_context_data). It points the SDK to be used for compiling given target."),
        "simpleresgen": attr.label(default = Label("@io_bazel_rules_dotnet//tools/simpleresgen:simpleresgen.exe"), doc = "An alternative tool for generating resources file."),
    },
    toolchains = ["@io_bazel_rules_dotnet//dotnet:toolchain_type_core"],
    executable = False,
    doc = "This builds a dotnet .resources file from a single .resx file. Uses a custom tool to convert text .resx file to .resources files because no standard tool is provided.",
)

core_resx_multi = rule(
    _resx_multi_impl,
    attrs = {
        # source files for this target.
        "srcs": attr.label_list(allow_files = True, mandatory = True, doc = "The source files to be built."),
        "identifierBase": attr.string(doc = "The logical name for given resource is constructred from identiferBase + \".\" + directory.repalce('/','.') + \".\" + basename + \".resources\". The resulting name should be used to load the resource. Either identifierBase of fixedIdentifierBase must be specified."),
        "fixedIdentifierBase": attr.string(doc = "The logical name for given resource is constructred from fixedIdentiferBase + \".\" + basename + \".resources\". The resulting name should be used to load the resource."),
        "dotnet_context_data": attr.label(default = Label("@io_bazel_rules_dotnet//:core_context_data"), doc = "The reference to label created with [core_context_data rule](api.md#core_context_data). It points the SDK to be used for compiling given target. Either identifierBase of fixedIdentifierBase must be specified."),
        "simpleresgen": attr.label(default = Label("@io_bazel_rules_dotnet//tools/simpleresgen:simpleresgen.exe"), doc = "An alternative tool for generating resources file."),
    },
    toolchains = ["@io_bazel_rules_dotnet//dotnet:toolchain_type_net"],
    executable = False,
    doc = "This builds a dotnet .resources files from multiple .resx file (one for each).",
)
