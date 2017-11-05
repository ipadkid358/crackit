## crackit

Originating from the "brute force" bash script I wrote, crackit times how long it takes your CPU to count up to a number on a specified amount of threads

Implementation of [BJThreadedCounting](https://github.com/ipadkid358/BJThreadedCounting) (didn’t feel like re-compiling the C library to include)

```
Usage: ./crackit <possibilities> [threads]
    'threads' defaults to the amount of machine cores
```

[Binary](http://ipadkid.cf/scripts/crackit) (compiled tool) available on my website
