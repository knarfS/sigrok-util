This image conatins everything that is needed to cross compile smuview for Windows.
Available targets are x86_64-w64-mingw32.static.posix

Environment variables:
- `BASE_DIR="/opt"`
- `MXE_DIR="${BASE_DIR}/mxe"`

Building:
```
docker build --no-cache -f Dockerfile -t sigrok-mxe:latest
```

Notes:
- Add packets for pulseview: scons, sdcc
- Package doxygen is a dependency for libsigrok C++, but not available for
  MXE. The host doxygen is sufficient for building... Urgs!
