PATH="$PATH:$HOME/.nimble/bin" # too lazy to do it normally so
nimxc c --target windows-amd64 --outdir:build snektool.nim && wine ./build/snektool.exe
# nim c --outdir:build snektool.nim && ./build/snektool