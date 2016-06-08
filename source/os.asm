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
    ;mov al, 'x'
    ;mov ah, 0x0e
    ;int 0x10
    jnge %%end            ;小于57，为数字，直接结束
%%isLetter_B:
    cmp %1, 65
    jnge %%isLetter_S        ;小于65，不是大写字母,判断是否为小写
    cmp %1, 90
    jnge %%end            ;小于90，是大写字母，直接结束
%%isLetter_S:
    cmp %1, 97
    jnge %%isBlank        ;小于97，不是小写字母,判断是否为空格
    cmp %1, 122
    jnge %%end            ;小于122，是小写字母，直接结束
%%isBlank:
    cmp %1, 0x20
    je %%end
    ;mov al, 'y'
    ;mov ah, 0x0e
    ;int 0x10
;mov al, %1
    ;mov ah, 0x0e
    ;int 0x10
mov ax, 1

%%end: 
    
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

;section .text

jmp boot

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
;------------read----------------
read:
mov si, 0
retry_read:
    mov ax, 0
    mov es, ax
    mov ch, 0
    mov dh, 1
    mov cl, 2       ;初始扇区是cl=1 而不是0

    mov ah, 0x02
    mov al, 1

    mov bx, oneSecFile
    mov dl, 0x01
    int 0x13
    jnc next_read

    add si, 1
    cmp si, 5

    jae error_read

    MOV AH,0x00
    MOV DL,0x01; A驱动器
    INT 0x13; 重置驱动器

    jmp retry_read

error_read:
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

next_read:
    
mov si, 0
mov bx, oneSecFile
print_name:
    ;循环判断11个字符，看是不是非目标文件
    ;flag_invalid db 0


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

    ;打印
    ;mov ah, 0x0e
    ;mov al, [oneSecFile+64]
    ;int 0x10

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
    call fill_fat
    call read
    ;call format
    call log

fin:
		HLT
		JMP		fin
