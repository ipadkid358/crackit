## crackit

Originating from the "brute force" bash script I wrote, crackit times how long it takes your CPU to count up to a number on a specified amount of threads

If a macOS SDK is available, `make MACOS=1` to build for macOS 32 and 64 bit

`./make-all.sh` will build for iOS and macOS, 32 and 64 bit, and create one FAT (universal) binary

```
Usage: ./crackit <possibilities> [threads]
    'threads' defaults to the amount of machine cores
```
