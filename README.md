# LuaJIT Android NDK Build Scripts

Building LuaJIT for use on Android is a complicated matter, especially in the light of the Android
NDK constantly evolving and supporting new platforms. This repository offers a set of Bash scripts
that automatically finds an installed NDK, selects some NDK ABI level, and generates makefiles for
building LuaJIT for all platforms the selected ABI level supports.

## Installation

Simply clone this repository to a folder of your choice and make sure you have Android NDK version
11+ installed on your system.

## Useage

Using the scripts should in most cases not be more difficult than running the below command via a
terminal from the repository root folder.

```bash
$ make
```

This will find your NDK installation, as long as its located somewhere below either `$HOME` or
`/opt`, select some suitable ABI level, and generate makefiles. If no errors are reported, you
should be able to build for the ARM 32-bit target via the following command.

```bash
$ make ndk-arm
```

The build output will end up in the `out/ndk-arm` folder.

### Providing a Custom ABI Level

By defining the `$NDK_ABI` environment variable before calling `make`, the target ABI may be
selected explicitly.

```bash
$ NDK_ABI=9 make
```

### Providing a Custom NDK Location

In the case of your NDK not being located somewhere it can be found, its location can be provided
explicitly by defining `$NDK_PATH`.

```bash
$ NDK_PATH=/path/to/ndk-bundle make
```

## Supported Platforms

The scripts have been verified to run on Ubuntu 14.04 and OS X 10.10, and should work on any UNIX
system that provides Bash.

## Important Considerations

It may be the case that the NDK supports more targets than LuaJIT can generate assembly for. As an
example, LuaJIT 2.0.4 lacks support for the 64-bit MIPS architecture, while being a valid Android
NDK target platform.

## Contributing

If anything wouldn't work, don't hesitate to try and fix it and make a pull request. If you don't
have time or don't know how to fix it, write an issue and I might consider fixing it at some point.
