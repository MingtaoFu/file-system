nasm ipl10.asm -o ipl10.img
nasm -f bin -o haribote.bin haribote.asm
mount ipl10.img U
cp haribote.bin U
umount U
