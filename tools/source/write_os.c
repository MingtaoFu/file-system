#include <unistd.h>
#include <fcntl.h>
int main(int argc,char **argv) {
    char buf[2048];
    int floppy_desc, file_desc;
    file_desc = open(argv[1], O_RDONLY);
    read(file_desc, buf, 2048);
    close(file_desc);

    floppy_desc = open(argv[2], O_RDWR);
    lseek(floppy_desc, 512, SEEK_SET);
    write(floppy_desc, buf, 2048);
    close(floppy_desc);
}
