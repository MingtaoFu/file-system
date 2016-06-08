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

command: db "                              "
jmp boot

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
        cmp byte [command], 'h'
        je exe_help
        cmp byte [command], 'f'
        je exe_format
        cmp byte [command], 'o'
        je exe_open
        cmp byte [command], 'r'
        je exe_read
        cmp byte [command], 'w'
        je exe_write
        cmp byte [command], 's'
        je exe_seek
        cmp byte [command], 'c'
        je exe_close
        cmp byte [command], 'm'
        je exe_mkdir
        cmp byte [command], 'd'
        je exe_deldir
        cmp byte [command], 'e'
        je exe_exist
        cmp byte [command], 'q'
        je exe_quit

    exe_help:
        ret

    exe_format:
        ret

    ; open 表示 cd + ls
    exe_open:
        seek_name command+2
        call cd
        ret

    exe_read:
        ret
    exe_write:
        ret
    exe_seek:
        ret
    exe_close:
        ret
    exe_mkdir:
        ret
    exe_deldir:
        ret
    exe_exist:
        ret
    exe_quit:
        ret

struc   file
    .dir_name   RESB    11
    .dir_attr   RESB    1
    .reserved   RESB    10
    .w_time     RESB    2
    .w_date     RESB    2
    .first_clus RESB    2
    .file_sizw  RESB    4
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
cd_name: db "DIR        "
cd:
    ;seek_name cd_name


    cmp al, 0
    je cd_blank
    mov ax, dx
    call workout
    IO_BIOS ch, dh, cl, 0x02, 1, oneSecFile, next_read

    ret

    cd_blank:
        mov al, "B"
        mov ah, 0x0e
        int 0x10

    ret

;------------cd end---------------


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
