KERNEL:

NOP

;保存用户程序寄存器的地址 
;0xBF10  0xBF11 BF12 0xBF13 BF14 0xBF15
; R0    R1   R2   R3   R4   R5  

B START
NOP

DELINT:   ;中断处理程序
	NOP
	NOP
	NOP
	;保存用户程序现场
	LI R6 0xBF
	SLL R6 R6 8
	ADDIU R6 0x10					;R6=0xBF10
	SW R6 R0 0x0000
	SW R6 R1 0x0001
	SW R6 R2 0x0002
	

	

	
	;R1=中断号
	LW_SP R1 0x0000
	ADDSP 0x0001
	LI R0 0x00FF
	AND R1 R0
	
	;R2=应用程序的pc
	LW_SP R2 0x0000
	ADDSP 0x0001
	
	;保存r3
	ADDSP -1
	SW_SP R3 0x0000


	
	;保存用户程序返回地址
	ADDSP -1
	SW_SP R7 0x0000
	
	;提示终端，进入中断处理
	LI R3 0x000F
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00
	SW R6 R3 0x0000
	NOP
	;输出中断号
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00 
	SW R6 R1 0x0000
	NOP
	
	;提示终端，中断处理结束
	LI R3 0x000F
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00 
	SW R6 R3 0x0000
	NOP
	
	;R6保存返回地址
	ADDIU3 R2 R6 0x0000
	
	;用r3=IH（高位变成1）
	MFIH R3
	LI R0 0x0080
	SLL R0 R0 8
	OR R3 R0
	
	;恢复现场
	LI R7 0xBF
	SLL R7 R7 8
	ADDIU R7 0x10					;R7=0xBF10
	LW R7 R0 0x0000
	LW R7 R1 0x0001
	LW R7 R2 0x0002
	
	;r7=用户程序返回地址
	LW_SP R7 0x0000
	
	ADDSP 0x0001
	ADDSP 0x0001
	NOP
	MTIH R3;
	JR R6
	LW_SP R3 -1
	
	NOP	


;init  0x8251
START:
	;初始化IH寄存器，最高位为1时，允许中断，为0时不允许。初始化为0，kernel不允许中断
	LI R0 0x07
	MTIH R0
	;初始化栈地址
	li r0, 0xc000
	MTSP R0
	NOP
	
	;用户寄存器值初始化
	LI R6 0x00BF 
	SLL R6 R6 8
	ADDIU R6 0x10					;R6=0xBF10 
	LI R0 0x0000
	SW R6 R0 0x0000
	SW R6 R0 0x0001
	SW R6 R0 0x0002
	SW R6 R0 0x0003
	SW R6 R0 0x0004
	SW R6 R0 0x0005
		
	;WELCOME
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	LI R6 0x00BF 
	SLL R6 R6 8 
	LI R0 0x004F
	SW R6 R0 0x0000
	NOP
	
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	LI R6 0x00BF 
	SLL R6 R6 8 
	LI R0 0x004B
	SW R6 R0 0x0000
	NOP
	
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	LI R6 0x00BF 
	SLL R6 R6 8 
	LI R0 0x000A
	SW R6 R0 0x0000
	NOP
	
	MFPC R7 
	ADDIU R7 0x0003  
	NOP
	B TESTW 	
	LI R6 0x00BF 
	SLL R6 R6 8 
	LI R0 0x000D
	SW R6 R0 0x0000
	NOP
	

	

	

	
BEGIN:          ;检测命令
	;接收字符，保存到r1
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R1 0x0000
	LI R6 0x00ff 
  AND R1 R6 
	NOP	
	

	;检测是否为R命令		
	LI R0 0x0052
	CMP R0 R1
	BTEQZ SHOWREGS	
	NOP	
	;检测是否为D命令
	LI R0 0x0044
	CMP R0 R1
	BTEQZ SHOWMEM
	NOP	
	
	;检测是否为A命令
	LI R0 0x0041
	CMP R0 R1
	BTEQZ GOTOASM
	NOP	
	
	;检测是否为U命令
	LI R0 0x0055
	CMP R0 R1
	BTEQZ GOTOUASM
	NOP	
	;检测是否为G命令
	LI R0 0x0047
	CMP R0 R1
	BTEQZ GOTOCOMPILE
	NOP		
	
	B BEGIN
	NOP

;各处理块的入口
GOTOUASM:
	NOP
	B UASM
	NOP
GOTOASM:
	NOP
	B ASM
	NOP
	
GOTOCOMPILE:
	NOP
	B COMPILE
	NOP
  
	
;测试8251是否能写
TESTW:	
	NOP	 		
	LI R6 0x00BF 
	SLL R6 R6 8 
	ADDIU R6 0x0001 
	LW R6 R0 0x0000 
	LI R6 0x0001 
	AND R0 R6 
	BEQZ R0 TESTW     ;BF01&1=0 则等待	
	NOP		
	JR R7
	NOP 
	

	
;测试8251是否能读
TESTR:	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 
	ADDIU R6 0x0001 
	LW R6 R0 0x0000 
	LI R6 0x0002
	AND R0 R6 
	BEQZ R0 TESTR   ;BF01&2=0  则等待	
	NOP	
	JR R7
	NOP 		
	
	
SHOWREGS:    ;R命令，打印R0-R5
	LI R1 0x0006  ;R1递减  
	LI R2 0x0006   ;R2不变
	
LOOP:
	LI R0  0x00BF
	SLL R0 R0 8
	ADDIU R0 0x0010
	SUBU R2 R1 R3   ;R2=0,1,2,3
	ADDU R0 R3 R0   ;R0=BF10...
	LW R0 R3 0x0000    ;R3=用户程序的 R0,R1,R2	

	;发送低八位
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=BF00	
	SW R6 R3 0x0000	
	;发送高八位
	SRA R3 R3 8
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R3 0x0000	
	
	ADDIU R1 -1
	NOP
	BNEZ R1 LOOP
	NOP	
	B BEGIN
	NOP
	

	
	

	
	
	
SHOWMEM:  ;查看内存	
;D读取地址低位到r5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000	
	LI R6 0x00FF
	AND R5 R6
	NOP	
	
	;读取地址高位到r1
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R1 0x0000
	LI R6 0x00FF
	AND R1 R6
	NOP	
	
	
	
	;R1存储地址
	SLL R1 R1 8
	OR R1 R5
	
	;读取显示次数低位到R5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	;读取显示次数高位到R2
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R2 0x0000
	LI R6 0x00FF
	AND R2 R6
	NOP	
	;R2保存内存个数
	SLL R2 R2 8
	OR R2 R5

	
		;循环发出	
	
MEMLOOP:		
	
	LW R1 R3 0x0000    ;R3为内存数据	

	;发送低八位
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R3 0x0000	
	;发送高八位

	SRA R3 R3 8
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R3 0x0000	
	
	ADDIU R1 0x0001   ;R1=地址加加加
	ADDIU R2 -1
	NOP
	BNEZ R2 MEMLOOP
	NOP	

	B BEGIN
	NOP		


 ;汇编	
ASM:  
	;A命令读取地址低位到r5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	;读取地址高位到r1
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R1 0x0000
	LI R6 0x00FF
	AND R1 R6
	NOP	
	
	;R1存储地址
	SLL R1 R1 8
	OR R1 R5
	
	
	
	
	;检测地址是否合法
	LI R0 0x0000
	CMP R0 R1      
  BTEQZ GOTOBEGIN
	NOP	
	
 
	;读取数据低位到R5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	

	;读取数据高位到R2
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R2 0x0000
	LI R6 0x00FF
	AND R2 R6
	NOP	
	;R2保存数据
	SLL R2 R2 8
	OR R2 R5
			
	SW R1 R2 0x0000	
	NOP
	
	B ASM
	NOP
	
GOTOBEGIN:
	NOP
	B BEGIN
	NOP
	
	
	
	
;反汇编：将需要反汇编的地址处的值发给终端处理	
UASM:
;读取地址低位到r5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	;读取地址高位到r1
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R1 0x0000
	LI R6 0x00FF
	AND R1 R6
	NOP	
	
	
	
	;R1存储地址
	SLL R1 R1 8
	OR R1 R5
	
	;读取显示次数低位到R5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	;读取显示次数高位到R2
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R2 0x0000
	LI R6 0x00FF
	AND R2 R6
	NOP	
	;R2保存内存个数
	SLL R2 R2 8
	OR R2 R5

	
		;循环发出	
	
UASMLOOP:		
	
	LW R1 R3 0x0000    ;R3为内存数据	

	;发送低八位
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R3 0x0000	
	;发送高八位

	SRA R3 R3 8
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R3 0x0000	
	
	ADDIU R1 0x0001   ;R1=地址加加加
	ADDIU R2 -1
	NOP
	BNEZ R2 UASMLOOP
	NOP	

	B BEGIN
	NOP			
	
;连续执行
COMPILE:
	;读取地址低位到R5
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R5 0x0000
	LI R6 0x00FF
	AND R5 R6
	NOP	
	;读取内存高位到R2
	MFPC R7
	ADDIU R7 0x0003	
	NOP	
	B TESTR	
	NOP
	LI R6 0x00BF 
	SLL R6 R6 8 
	LW R6 R2 0x0000
	LI R6 0x00FF
	AND R2 R6
	NOP	
	;R2保存内存地址  传给r6
	SLL R2 R2 8
	OR R2 R5
	ADDIU3 R2 R6 0x0000
	
	
	LI R7 0x00BF
	SLL R7 R7 8
	ADDIU R7 0x0010
	
	LW R7 R5 0x0005
	ADDSP -1
	SW_SP R5 0x0000
	
	
	;中断保存在R5中
	MFIH R5
	LI R1 0x0080
	SLL R1 R1 8
	OR R5 R1
	
	
	
	;恢复现场
	LW R7 R0 0x0000
	LW R7 R1 0x0001
	LW R7 R2 0x0002
	LW R7 R3 0x0003
	LW R7 R4 0x0004
	
	
	
	MFPC R7
	ADDIU R7 0x0004
	MTIH R5    ;IH高位赋1	
	JR R6
	LW_SP R5 0x0000  ;R5恢复现场
	
	;用户程序执行完毕，返回kernel，保存现场
	NOP
	NOP
	ADDSP 0x0001
	LI R7 0x00BF
	SLL R7 R7 8
	ADDIU R7 0x0010
	
	SW R7 R0 0x0000
	SW R7 R1 0x0001
	SW R7 R2 0x0002
	SW R7 R3 0x0003
	SW R7 R4 0x0004
	SW R7 R5 0x0005
	
	;IH高位赋0
	MFIH R0
	LI R1 0x007F
	SLL R1 R1 8
	LI R2 0x00FF
	OR R1 R2	
	AND R0 R1
	MTIH R0
	
	;给终端发送结束用户程序提示
	LI R1 0x0007
	MFPC R7
	ADDIU R7 0x0003	
	NOP
	B TESTW	
	NOP	
	LI R6 0x00BF 
	SLL R6 R6 8 ;R6=0xBF00	
	SW R6 R1 0x0000		
	B BEGIN
	NOP	
		
	
	




	