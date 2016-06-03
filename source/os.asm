; haribote-os
; TAB=4


ORG     0x8200
;section .data
fatContent:
    DB      0xeb, 0x4e, 0x90
    DB      "HUSTSOFT"      ; 启动区的名称可以是任意字符串（8字节）
    DW      512             ; 每个扇区的大小（必须为512字节）
    DB      1               ; 簇的大小（必须为1字节）
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
    RESB    0x0174-($-fatContent)
    ;RESB    0x1fe-($-$$)
    DB      0x55, 0xaa
xcz:
    RESB    0xa
    DB  "hahaha"

;section .text

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

    mov bx, es
    mov al, [0x8200]
    MOV AH,0x0e
    int 0x10
    mov al, [0x8400]
    MOV AH,0x0e
    int 0x10

    mov al, [0x8600]
    MOV AH,0x0e
    int 0x10

jmp boot

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
    call log

fin:
		HLT
		JMP		fin


