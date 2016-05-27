nasm -f bin -o ./.tmp/os.bin ./source/os.asm
nasm ./source/boot.asm -o ./.tmp/file-system.img
./tools/write_os ./.tmp/os.bin ./.tmp/file-system.img
cp ./.tmp/file-system.img ./bin
