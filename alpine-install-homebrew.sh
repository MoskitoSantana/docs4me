#!/bin/bash

# Fix for following error during installing homebrew on alpine:

#44 238.9 Warning: Running in non-interactive mode because `stdin` is not a TTY.
#44 239.0 musl libc (x86_64)
#44 239.0 Version 1.2.3
#44 239.0 Dynamic Program Loader
#44 239.0 Usage: /lib/ld-musl-x86_64.so.1 [options] [--] pathname
#44 239.0 Homebrew requires Ruby 2.6 which was not found on your system.
#44 239.0 Homebrew portable Ruby requires Glibc version 2.13 or newer,
#44 239.0 and your Glibc version is too old. See:
#44 239.0   https://docs.brew.sh/Homebrew-on-Linux#requirements
#44 239.0 Please install Ruby 2.6 and add its location to your PATH.


curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o install.sh && sed -i -e '/^test_ruby() {/,/^}/c\test_ruby() { local executable="$1"; if "$executable" --version 2>/dev/null | grep -q "ruby"; then return 0; else return 1; fi; }' install.sh && NONINTERACTIVE=1 /bin/bash ./install.sh && HOMEBREW_NO_ANALYTICS=1 brew install <!!!SOMTHING!!!>
