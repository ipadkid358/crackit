## crackit

Originating from the "brute force" bash script I wrote, crackit times how long it takes your CPU to count up to a number on a specified amount of threads

If a macOS SDK is available, `make MACOS=1` to build for macOS 32 and 64 bit

`./make-all.sh` will build for iOS and macOS, 32 and 64 bit, and create one FAT (universal) binary

```
Usage: ./crackit <possibilities> [threads]
    'threads' defaults to the amount of machine cores
```

## Compiling

`gcc -pthread -lm -O3 crackit.c -o crackit`

`gcc` is a popular C compiler, however this has been tested with `clang` as well

`-pthread` pthread family (POSIX threading, used for multi-threading)

`-lm` link against library "m" (required for `floor(double)`)

`-O3` optimization level 3, recommended, but not required

`-o crackit` name the output file "crackit"
