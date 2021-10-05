To compile and test under mingw on Fedora, start with:

https://fedoraproject.org/wiki/MinGW/Tutorial

On Fedora, we only use mingw64

```
sudo yum install mingw32-libgcrypt-static mingw64-libgcrypt-static  mingw32-zlib-static mingw64-zlib-static mingw32-expat-static mingw64-expat-static
export WINEPATH=/usr/x86_64-w64-mingw32/sys-root/mingw/bin/
sh bootstrap.sh
mingw64-configure --quiet --enable-silent-rules
make testapp_catch2.exe
wine testapp_catch2.exe
```
To compile under ubuntu:
```
./configure --host=i686-w64-mingw32 --quiet --enable-silent-rules
```
