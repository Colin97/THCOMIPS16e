; 运算数据冲突的效率测试
; 从这一节起，假设正确处理了数据冲突，有数据冲突的地方不再加NOP。
; 结果：
; 9.005s @ 25.0000MHz, CPI=1.00
; failed @ 100.000MHz, CPI=----

; *** 程序说明：R4、R5为循环变量   ***
; ***     主要循环体0x05~0x0D，9条 ***
; ***     每条各执行25,000,000次   ***
; ***     共2.25亿条指令           ***

; --------------------------------------------
; |冲突：(5)ADDU后接(6)ADDU
; |　　　(5)ADDU、(6)ADDU后接(7)SUBU
; |　　　(7)SUBU后接(8)CMP
; |　　　(6)ADDU、(7)SUBU后接(9)ADDU
; |
; |行号从0开始，非主要循环体内的冲突不计
; --------------------------------------------

LI R1 55
LI R5 FF
SLL R5 R5 0
ADDIU R5 82
LI R4 60
ADDU R1 R1 R2
ADDU R2 R1 R3
SUBU R3 R2 R2
CMP R1 R2
ADDU R2 R3 R2
BEQZ R4 3
ADDIU R4 1
BTEQZ F8
NOP
ADDIU R5 1
BNEZ R5 F4
NOP
JR R7
NOP
