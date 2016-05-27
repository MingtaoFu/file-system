; haribote-ipl
; TAB=4

CYLS	EQU		10				; Ç±ÜÅÇÝÞ©

		ORG		0x7c00			; 指明程序的装载地址

; 一下这段是标准FAT12格式软盘专用的代码

		JMP		entry
		DB		0x90
		DB		"HUSTSOFT"		; 启动区的名称可以是任意字符串（8字节）
		DW		512				; 每个扇区的大小（必须为512字节）
		DB		1				; 簇的大小（必须为1字节）
		DW		1				; FAT的起始位置（一般从第一个扇区开始）
		DB		2				; FAT的个数（必须为2）
		DW		224				; 根目录大小（一般设成224项）
		DW		2880			; 该磁盘的大小（必须是2880扇区）
		DB		0xf0			; 磁盘的种类（必须是0xf0）
		DW		9				; FAT的长度（必须是9扇区）
		DW		18				; 1个磁道的扇区数（必须是18）
		DW		2				; 磁头数（必须是2）
		DD		0				; 不使用分区（必须是0）
		DD		2880			; 重写一次磁盘大小
		DB		0,0,0x29		; 意义不明，固定
		DD		0xffffffff		; 卷标号码
		DB		"HUSTSOFTOS "	; 磁盘名称（11字节）
		DB		"FAT12   "		; 磁盘格式名称（8字节）
		RESB	18				; 先空出18字节

; 程序核心

entry:
		MOV		AX,0			; 初始化寄存器
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; 读盘

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0
		MOV		CL,2			; 扇区2
readloop:
		MOV		SI,0			; 记录失败次数的寄存器
retry:
		MOV		AH,0x02			; AH=0x02 : 读盘
		MOV		AL,1			; 1个扇区
		MOV		BX,0
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 调用磁盘BIOS
		JNC		next			; 没出错时跳转到next
		ADD		SI,1			; SI加1
		CMP		SI,5			; 比较SI与5
		JAE		error			; SI >= 5 时跳转到error
		MOV		AH,0x00
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 重置驱动器
		JMP		retry
next:
		MOV		AX,ES			; 把内存地址后移0x200
		ADD		AX,0x0020
		MOV		ES,AX			; 因为没有 ADD ES,0x020 命令，所以绕个弯
		ADD		CL,1			; CL加1
		CMP		CL,18			; 比较CL与18
		JBE		readloop		; 如果 CL <= 18 跳转至 readloop
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; 如果 DH < 2 跳转至 readloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; 如果 DH < 2 跳转至 readloop

; ÇÝIíÁœÌÅharibote.sysðÀsŸI

		MOV		[0x0ff0],CH		; 注意IPL是我读到的地方
		JMP		0x8200

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; SIÉ1ð«·
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; ê¶\Št@NV
		MOV		BX,15			; J[R[h
		INT		0x10			; rfIBIOSÄÑoµ
		JMP		putloop
fin:
		HLT						; œ© éÜÅCPUðâ~³¹é
		JMP		fin				; ³À[v
msg:
		DB		0x0a, 0x0a		; 换行两次
		DB		"load error"
		DB		0x0a			; 换行
		DB		0

		RESB	0x7dfe-($-$$)		; 0x7dfeÜÅð0x00Åßéœß

		DB		0x55, 0xaa
