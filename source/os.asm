; haribote-os
; TAB=4

ORG     0x8200
;section .data

%macro judge_char 1
    xor ax, ax
%%isNumber:
    cmp %1, 48
    jnge %%isLetter_B       ;小于48，则不是数字，判断是否为字母
    cmp %1, 57
    jng %%end            ;小于57，为数字，直接结束
%%isLetter_B:
    cmp %1, 65
    jnge %%isLetter_S        ;小于65，不是大写字母,判断是否为小写
    cmp %1, 90
    jng %%end            ;小于90，是大写字母，直接结束
%%isLetter_S:
    cmp %1, 97
    jnge %%isBlank        ;小于97，不是小写字母,判断是否为空格
    cmp %1, 122
    jng %%end            ;小于122，是小写字母，直接结束
%%isBlank:
    cmp %1, 0x20
    je %%end
%%isDot:
    cmp %1, 0x2E
    je %%end
mov ax, 1

%%end:
%endmacro
;------------seek file-------
%macro seek_name 1
; %1 为输入的文件名的地址

mov si, 0
mov bx, oneSecFile
%%seek_name_loop:
    xor cx, cx
    %%loop_compare_char:
        mov di, cx

        mov ah, [%1+di]
        cmp ah, [bx+di]

        jne %%not_match

        inc cx
        cmp cx, 11
        jne %%loop_compare_char

    ;important
    mov dx, [bx+file.first_clus]

    ;回车换行
    mov al, 0x0d
    mov ah, 0x0e
    int 0x10
    mov al, 0x0a
    mov ah, 0x0e
    int 0x10
    jmp %%found

    %%not_match:

        add bx, 32

    add si, 1
    cmp si, 16

    jl %%seek_name_loop

    ;mov al, 'N'
    ;mov ah, 0x0e
    ;int 0x10
    mov al, 0
    jmp %%end
%%found:
    mov ax, [bx+file.file_size]
    mov [fileSize], ax
    ;mov al, 'Y'
    ;mov ah, 0x0e
    ;int 0x10
    mov al, 1
%%end:

%endmacro
;------------seek file end---



; ch: %1, dh: %2, cl: %3, ah: %4, al: %5, mem: %6,  next: %7
%macro IO_BIOS 7
mov si, 0
%%retry_IO:
    mov ax, 0
    mov es, ax
    mov ch, %1
    mov dh, %2
    mov cl, %3       ;初始扇区是cl=1 而不是0

    mov ah, %4
    mov al, %5

    mov bx, %6
    mov dl, 0x01
    int 0x13
    jnc %7

    add si, 1
    cmp si, 5

    jae %%error_IO

    MOV AH,0x00
    MOV DL,0x01; A驱动器
    INT 0x13; 重置驱动器

    jmp %%retry_IO

%%error_IO:
    mov al, ah
    MOV AH,0x0e
    int 0x10

    mov ah, 0x0e
    mov al, ' '
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, ' '
    int 0x10

%endmacro

;-----------------first sector content------
fatContent:
    DB      0xeb, 0x4e, 0x90
    DB      "HUSTSOFT"      ; 启动区的名称可以是任意字符串（8字节）
    DW      512             ; 每个扇区的大小（必须为512字节）
    DB      1               ; 簇的大小（必须为1扇区）
    DW      1               ; FAT的起始位置（一般从第一个扇区开始）
    DB      2               ; FAT的个数（必须为2）
    DW      224             ; 根目录大小（一般设成224项）
    DW      2880            ; 该磁盘的大小（必须是2880扇区）
    DB      0xf0            ; 磁盘的种类（必须是0xf0）
    DW      9               ; FAT的长度（必须是9扇区）
    DW      18              ; 1个磁道的扇区数（必须是18）
    DW      2               ; 磁头数（必须是2）
    DD      0               ; 不使用分区（必须是0）
    DD      2880            ; 重写一次磁盘大小
    DB      0,0,0x29        ; 意义不明，固定
    DD      0xffffffff      ; 卷标号码
    DB      "HUSTSOFTOS "   ; 磁盘名称（11字节）
    DB      "FAT12   "      ; 磁盘格式名称（8字节）
res:
    RESB    0x0014e-($-fatContent)
final:
    RESB    0xb0
    DB      0x55, 0xaa
;-----------------first sector content end------
;-----------------FAT------
FAT:
    RESB    0x200
;-----------------FAT end------
oneSecFile:
    RESB    0x200
fileContent:
    RESB    0x200
fileSize:
    RESB    2
command: db "                              "
jmp boot
touch_filename: db "           "
touch_fileContent:
    resb 0x200
filesize:
    resb 2
blank:
    resb 0x200


;--------------read FAT-------------------------
read_FAT:
    IO_BIOS 0, 0, 2, 0x02, 1, FAT, next_read_FAT
    next_read_FAT:
    ret
;--------------read FAT end-------------------------
;--------------select FAT-------------------------
oneFAT:
    resb 2
fatResult:
    resb 2
culNum:
    resb 2
readOneFAT:
    ;簇号位于cx中
    mov cx, [culNum]
    push cx
    mov ax, cx
    cwd
    mov cx, 2
    idiv cx

    pop cx
    add ax, cx      ;簇号×1.5
    mov bx, ax
    mov ax, [FAT+bx]
    mov [oneFAT], ax

    ; 进行移位操作
    cmp dx, 0
    je readOneFAT_odd

    ; 奇数时
    readOneFAT_even:
        sar ax, 4
        mov [fatResult], ax
        ret
    ; 偶数时
    readOneFAT_odd:
        ;sal ax, 4
        ;sar ax, 4
        and ax, 0x0fff
        mov [fatResult], ax
    ret
selectFAT:
    mov cx, 2
    loop_FAT:
        mov [culNum], cx
        call readOneFAT
        mov ax, [fatResult]
        cmp ax, 0
        je selectFATOn

        inc cx
        cmp cx, 340
        jl loop_FAT
    selectFATOn:

        mov ax, [oneFAT]
        cmp dx, 0
        je writeOneFAT_odd

        ; 奇数时
        writeOneFAT_even:
            xor ax, 0xfff0
            jmp afterWriteOneFatSa
        ; 偶数时
        writeOneFAT_odd:
            xor ax, 0x0fff
        afterWriteOneFatSa:
            mov [FAT+bx], ax
            IO_BIOS 0, 0, 2, 0x03, 1, FAT, afterWriteOneFat1
        afterWriteOneFat1:
            IO_BIOS 0, 0, 11, 0x03, 1, FAT, afterWriteOneFat2
        afterWriteOneFat2:
        ;结束时，簇号在cx中
    ret
;--------------select FAT end-------------------------
;--------------writeOneSecFile-------------------------
cul: resb 2
writeOneSecFile:
    mov ax, cx
    mov [cul], ax

    mov cx, 0
    mov bx, oneSecFile
    findPosWriteSecFile:
        cmp byte [bx], 0
        je foundPos

        add bx, 32
        inc cx
        cmp cx, 16
        jl findPosWriteSecFile
    foundPos:
        mov cx, 0
        movNameToSec:
            mov di, cx
            mov dl, [touch_filename+di]
            mov [bx+di], dl

            inc cx
            cmp cx, 11
            jl movNameToSec
        mov [bx+file.first_clus], ax    ;输入簇号
        mov ax, [filesize]
        mov [bx+file.file_size], ax     ;输入文件大小
    IO_BIOS byte [currentDirSector], byte [currentDirSector+1], byte [currentDirSector+2], 0x03, 1, oneSecFile, afterWriteOneFileSec
    afterWriteOneFileSec:

    ret
;--------------writeOneSecFile end-------------------------
;--------------writeContent-------------------------
writeContent:
    mov ax, [cul]
    call workout
    
    IO_BIOS ch, dh, cl, 0x03, 1, touch_fileContent, afterWriteContent
    afterWriteContent:

    ret
;--------------writeContent end-------------------------

%macro touch 1
    ;清空以前的数据
    mov cx, 0
    mov bx, touch_filename
    %%clear_name:
        mov di, cx
        mov byte [bx+di], ' '
        inc cx
        cmp cx, 11
        jl %%clear_name
    mov cx, 0
    mov bx, touch_fileContent
    %%clear_file:
        mov di, cx
        mov byte [bx+di], 0
        inc cx
        cmp cx, 0x200
        jl %%clear_file

    ;将新数据存进去
    mov bx, touch_filename
    mov cx, 0
    %%movByte:
        mov di, cx
        cmp byte [%1+di], ' '
        je %%afterCopyName
        mov ax, [%1+di]
        mov [bx+di], ax
        inc cx
        jmp %%movByte
    %%afterCopyName:
        mov bx, touch_fileContent
        inc cx
        mov si, 0
    %%movContent:
        mov di, cx
        cmp byte [%1+di], ' '
        je %%afterCopyContent

        mov ax, [%1+di]
        mov [bx+si], ax
        inc cx
        inc si
        jmp %%movContent
    %%afterCopyContent:
    mov [filesize], si

    call selectFAT
    call writeOneSecFile
    call writeContent

%endmacro

input:
    mov cx, 0

    clear_command:
    mov di, cx
    mov byte [command+di], ' '
    inc cx
    cmp cx, 30
    jl clear_command

    mov bx, 0
get_key:
    mov ah, 0x00
    int 0x16
    

    ;判断回车
    cmp al, 0x0d
    je exe_command

    MOV AH,0x0e
    int 0x10
    ;存入命令缓冲区
    mov [command+bx], al
    inc bx

    jmp get_key

    exe_command:
        cmp byte [command], 'f'
        je exe_format
        cmp byte [command], 'o'
        je exe_open
        cmp byte [command], 'r'
        je exe_read
        cmp byte [command], 'w'
        je exe_write


    exe_format:
        IO_BIOS 0, 0, 1, 0x03, 1, fatContent, writeRoot
        writeRoot:
        IO_BIOS 0, 1, 2, 0x03, 1, blank, next_format
        next_format:
        call read
        ;回车换行
        mov al, 0x0d
        mov ah, 0x0e
        int 0x10
        mov al, 0x0a
        mov ah, 0x0e
        int 0x10

        ret

    ; open 表示 cd + ls
    exe_open:
        seek_name command+2
        call cd
        ret

    exe_read:
        seek_name command+2
        call cat
        ret
    exe_write:
        touch command+2
        ;回车换行
        mov al, 0x0d
        mov ah, 0x0e
        int 0x10
        mov al, 0x0a
        mov ah, 0x0e
        int 0x10
        ret

struc   file
    .dir_name   RESB    11
    .dir_attr   RESB    1
    .reserved   RESB    10
    .w_time     RESB    2
    .w_date     RESB    2
    .first_clus RESB    2
    .file_size  RESB    4
    .size:
endstruc

;------------fill fat----------------
fill_fat:
mov si, 0
retry_fill_fat:
    mov ax, 0
    mov es, ax
    mov ch, 0
    mov dh, 0
    mov cl, 2       ;初始扇区是cl=1 而不是0

    mov ah, 0x02
    mov al, 1

    mov bx, FAT
    mov dl, 0x01
    int 0x13
    jnc next_fat

    add si, 1
    cmp si, 5

    jae error_fat

    MOV AH,0x00
    MOV DL,0x01; A驱动器
    INT 0x13; 重置驱动器

    jmp retry_fill_fat

error_fat:
    mov al, ah
    ;add al ,0x30
    MOV AH,0x0e
    int 0x10

    mov ah, 0x0e
    mov al, ' '
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, ' '
    int 0x10

next_fat:
    ret
;------------fill fat end----------------
;------------work out position in disk---
; 33: 2        sector = cluster + 31
; cluster in ax
workout:
    add ax, 31      ;扇区号放在ax中
    cwd
    mov cx, 36
    idiv cx
    ;商在ax，余数在dx
    ;ax为得到的柱面号
    mov ch, al
    inc dx
    cmp dx, 19
    mov dh, 0
    jl finish
    sub dl, 18
    mov dh ,1
    finish:
    mov cl, dl
    ret
;------------work out end---

;------------cd---------------
currentDirSector:
    resb 3
cd:
    cmp al, 0
    je cd_blank
    mov ax, dx
    call workout
    mov [currentDirSector], ch
    mov [currentDirSector+1], dh
    mov [currentDirSector+2], cl
    IO_BIOS ch, dh, cl, 0x02, 1, oneSecFile, next_read

    ret

    cd_blank:
        mov al, "B"
        mov ah, 0x0e
        int 0x10

    ret

;------------cd end---------------
;------------cat---------------
cat:
    cmp al, 0
    je cat_blank
    mov ax, dx
    call workout
    IO_BIOS ch, dh, cl, 0x02, 1, fileContent, read_file

    read_file:
        mov bx, 0
        rd_loop:
            mov al, [fileContent+bx]
            mov ah, 0x0e
            int 0x10

            inc bx
            cmp bx, [fileSize]
            jl rd_loop

        ;回车换行
        mov al, 0x0d
        mov ah, 0x0e
        int 0x10
        mov al, 0x0a
        mov ah, 0x0e
        int 0x10
        ret
        mov ah, 0x03
        mov bh, 1
        int 0x10

        mov cx, 0x10
        mov bp, fileContent
        mov ax, 0
        mov es, ax
        mov ah, 0x13
        mov al, 1
        int 0x10
    ret

    cat_blank:
        mov al, "B"
        mov ah, 0x0e
        int 0x10
    ret
;------------cat end---------------


;------------enter dir----------------
enter_dir:
    mov ax, 15
    call workout
    IO_BIOS ch, dh, cl, 0x02, 1, oneSecFile, next_read
;enter_dir_read:
    ret
;------------enter dir end----------------
;------------read----------------
; ch: %1, dh: %2, cl: %3, ah: %4, al: %5, mem: %6,  next: %7
read:
    mov byte [currentDirSector], 0
    mov byte [currentDirSector+1], 1
    mov byte [currentDirSector+2], 2
    IO_BIOS 0, 1, 2, 0x02, 1, oneSecFile, next_read

next_read:
    
mov si, 0
mov bx, oneSecFile
print_name:
    ;循环判断11个字符，看是不是非目标文件

    xor cx, cx
    loop_11:
        mov di, cx
        judge_char byte [bx+di]
        cmp ax, 1
        je not_print
        inc cx
        cmp cx, 11
        jne loop_11

    xor cx, cx
    loop_print_char:
        mov di, cx
        mov al, [bx+di]
        mov ah, 0x0e
        int 0x10
        inc cx
        cmp cx, 11
        jne loop_print_char

    cmp byte [bx+11], 16
    jne print_enter
    mov al, '.'
    mov ah, 0x0e
    int 0x10

    print_enter:
    ;回车换行
    mov al, 0x0d
    mov ah, 0x0e
    int 0x10
    mov al, 0x0a
    mov ah, 0x0e
    int 0x10

    not_print:
        add bx, 32

    add si, 1
    cmp si, 16

    jl print_name

    ret

;------------read end----------------

;------------format---------------
format:
mov si, 0
retry:
    mov ax, 0
    mov es, ax
    mov ch, 0
    mov dh, 0
    mov cl, 1       ;初始扇区是cl=1 而不是0

    mov ah, 0x03
    mov al, 1
    mov bx, fatContent
    mov dl, 0x01
    int 0x13
    jnc next


    add si, 1
    cmp si, 5

    jae error

    MOV AH,0x00
    MOV DL,0x01; A驱动器
    INT 0x13; 重置驱动器

    jmp retry

error:
    mov al, ah
    ;add al ,0x30
    MOV AH,0x0e
    int 0x10

    mov ah, 0x0e
    mov al, ' '
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, ' '
    int 0x10

next:

    ;mov bx, es
    ;mov al, [0x8200]
    ;MOV AH,0x0e
    ;int 0x10
    ;mov al, [0x8400]
    ;MOV AH,0x0e
    ;int 0x10

    ;mov al, [0x8600]
    ;MOV AH,0x0e
    ;int 0x10

    ret
;------------format end---------------

log:
    mov ah, 0x0e
    mov al, ' '
    int 0x10
    mov al, 'l'
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, 'g'
    int 0x10
    mov al, ' '
    int 0x10
    ret

boot:
    call read
main:
    call input
    jmp main

fin:
		HLT
		JMP		fin
