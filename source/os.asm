; haribote-os
; TAB=4

		ORG		0x8200			; このプログラムがどこに読み込まれるのか


		;MOV		AL,0x13			; VGAグラフィックス、320x200x8bitカラー
		;MOV		AH,0x00
		;INT		0x10


;        MOV si, DIR
    MOV AH,0x0e
    mov al, 'H'
    INT 0x10
    mov al, 'U'
    INT 0x10
    mov al, 'S'
    INT 0x10
    mov al, 'T'
    INT 0x10

;DIR DB 'Please enter the NO.$'
fin:
		HLT
		JMP		fin
