## crackit

Originating from the "brute force" bash script I wrote, crackit times how long it takes your CPU to count up to a number on a specified amount of threads

```
Usage: ./crackit <possibilities> [threads]
'threads' defaults to the amount of machine cores
```

## Compiling

`make` will automatically compile using theos if Theos is setup, if not, the universal build be execute using gcc if the CC variable is not set

### Building with Theos

[Theos](https://github.com/theos/theos) is a cross platform build tool. It is used here to allow convenient use of SDKs

If a macOS SDK is available, `make MACOS=1` to build for macOS 32 and 64 bit

`./make-all.sh` will build for iOS and macOS, 32 and 64 bit, and create one FAT (universal) binary

### Building Universally

The following command is what I use to compile and test on Ubuntu 16.04

`gcc -pthread crackit.c -lm -o crackit`

`gcc` is a popular C compiler, however this has been tested with `clang` as well

`-pthread` pthread family (POSIX threading, used for multi-threading)

`-lm` link against the standard library (required for `floor()`)

`-o crackit` name the output file "crackit"
