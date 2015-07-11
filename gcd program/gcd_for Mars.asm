entry_vector:
	j main
timer_interrupt_vector:
	j timer_interrupt_main
exception_vector:
	j exception_main
uart_send_interrupt_vector:
	j uart_send_interrupt_main
uart_recv_interrupt_vector:
	j uart_recv_interrupt_main
	

timer_interrupt_main:
	lui $t0, 0x4000
	addi $t0, $t0, 0x0008
	lw $t1, 0($t0)
	andi $t1, $t1, 0xfff9
	sw $t1, 0($t0)				#中断禁止，清�?

ti_getenable:
	addi $t7, $zero, 0x00fc
	lw $t2, 0($t7)				#从ROM0x000000fc取数据，�?16位有�?
	lw $t3, 12($t0)				#取得七段数码�?
	srl $t3, $t3, 8				#取得七段数码管使能信�?
	andi $t4, $t3, 0x0001		#�?低位
	sll $t4, $t4, 3
	srl $t3, $t3, 1
	or $t3, $t3, $t4			#下一轮使能信�?
	add $t4, $t3, $zero			#$t4 = $t3

ti_right_shift_loop:
	andi $t5, $t4, 0x0008		#AN0控制�?高位，以此类�?
	beq $t5, $zero, ti_getnum	#低电平使能，遇到等于零才取信�?
	sll $t5, $t5, 1
	srl $t2, $t2, 4
	j ti_right_shift_loop
	
ti_getnum:
	andi $t2, $t2, 0x000f		#显示的数�?
	sll $t3, $t3, 8				#使能信号
	addi $t6, $zero, 0x0 
	beq $t2, $t6, ti_n0
	addi $t6, $zero, 0x1 
	beq $t2, $t6, ti_n1	
	addi $t6, $zero, 0x2 
	beq $t2, $t6, ti_n2	
	addi $t6, $zero, 0x3 
	beq $t2, $t6, ti_n3	
	addi $t6, $zero, 0x4 
	beq $t2, $t6, ti_n4	
	addi $t6, $zero, 0x5 
	beq $t2, $t6, ti_n5	
	addi $t6, $zero, 0x6 
	beq $t2, $t6, ti_n6	
	addi $t6, $zero, 0x7 
	beq $t2, $t6, ti_n7	
	addi $t6, $zero, 0x8 
	beq $t2, $t6, ti_n8	
	addi $t6, $zero, 0x9 
	beq $t2, $t6, ti_n9	
	addi $t6, $zero, 0xa 
	beq $t2, $t6, ti_na	
	addi $t6, $zero, 0xb 
	beq $t2, $t6, ti_nb	
	addi $t6, $zero, 0xc
	beq $t2, $t6, ti_nc	
	addi $t6, $zero, 0xd 
	beq $t2, $t6, ti_nd	
	addi $t6, $zero, 0xe 
	beq $t2, $t6, ti_ne	
	#addi $t6, $zero, 0xf 
	#beq $t2, $t6, ti_nf
	j ti_nf
ti_n0:
	addi $t3, $t3, 0x00fc
	j ti_display
ti_n1:
	addi $t3, $t3, 0x0060
	j ti_display
ti_n2:
	addi $t3, $t3, 0x00da
	j ti_display
ti_n3:
	addi $t3, $t3, 0x00f2
	j ti_display
ti_n4:
	addi $t3, $t3, 0x0066
	j ti_display
ti_n5:
	addi $t3, $t3, 0x00b6
	j ti_display
ti_n6:
	addi $t3, $t3, 0x00be
	j ti_display
ti_n7:
	addi $t3, $t3, 0x00e0
	j ti_display
ti_n8:
	addi $t3, $t3, 0x00fe
	j ti_display
ti_n9:
	addi $t3, $t3, 0x00f6
	j ti_display
ti_na:
	addi $t3, $t3, 0x00ee
	j ti_display
ti_nb:
	addi $t3, $t3, 0x00ff
	j ti_display
ti_nc:
	addi $t3, $t3, 0x009c
	j ti_display
ti_nd:
	addi $t3, $t3, 0x00fd
	j ti_display
ti_ne:
	addi $t3, $t3, 0x009e
	j ti_display
ti_nf:
	addi $t3, $t3, 0x008e
	j ti_display
	
ti_display:
	sw $t3, 12($t0)
	addi $t1, $t1, 2
	sw $t1, 0($t0)
	jr $26
	
	
exception_main:
	lui $t0, 0x4000
	addi $t0, $t0, 0x0018
	addi $t1, $zero, 0x00ff		#出错标识
	sw $t1, 0($t0)				#串口发�??
	jr $26

	
uart_send_interrupt_main:
	lui $t0, 0x4000
	addi $t0, $t0, 0x0018
	lw $t1, 0($t0) 				#read
	jr $26

	
uart_recv_interrupt_main:		
	lui $t0, 0x4000
	addi $t0, $t0, 0x001c
	lw $t1, 0($t0)				#接收数据
	
	addi $t2, $zero, 0x00fc 	#0x0000_00fc is used for storing RX, 
								#0x000SDDDD, S is status, D is data，S =0, no data, S=1, 1data
	lw $t3, 0($t2)
	srl $t4, $t3, 16
	bne $t4, $zero, ur_gcd_start
	lui $t3, 0x0001
	add $t3, $t3, $t1
	sw $t3, 0($t2)
	jr $26

ur_gcd_start:
	sll $t1, $t1, 8
	add $t3, $t3, $t1	
	sll $t3, $t3, 16
	srl $t3, $t3, 16
	sw $t3, 0($t2)
	andi $t6, $t3, 0x00ff
	andi $t7, $t3, 0xff00
	srl $t7, $t7, 8
	
ur_gcd_main:
	beq $t7, $zero, ur_gcd_end
	sub $t5, $t7, $t6
	bgtz $t5, ur_gcd_main_swap
	sub $t6, $t6, $t7
ur_gcd_main_swap:
	add $t5, $zero, $t6
	add $t6, $zero, $t7
	add $t7, $zero, $t5
	j ur_gcd_main
	
ur_gcd_end:
	lui $t0, 0x4000
	addi $t0, $t0, 0x000c
	sw $t6, 0($t0)				#LED显示	
	sw $t6, 12($t0)				#串口发�??
	jr $26

	
main:
main_init:
	lui $t0, 0x4000
	addi $t1, $zero, 0x08ff
	sw $t1, 0x14($t0)			#数码管初始化
	sw $zero, 0x0c($t0)			#外部LED初始�?
	lui $t1, 0xfffe
	addi $t1, $zero, 0x795f
	sw $t1, 0($t0)				#定时器初始化
	nor $t1, $0, $0
	sw $t1, 0x04($t0)
	addi $t1, $zero, 0x0003
	sw $t1, 0x08($t0)			#定时器使�?
	addi $t1, $zero, 0x0002
	sw $t1, 0x20($t1)			#串口接收中断使能
	addi $t2, $zero, 0x0254
	jr $t2
main_loop:
	j main_loop
	
	
	
