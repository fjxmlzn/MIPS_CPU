entry_vector:
	j entry_main
timer_interrupt_vector:
	j timer_interrupt_main
exception_vector:
	j exception_main
uart_send_interrupt_vector:
	j uart_send_interrupt_main
uart_recv_interrupt_vector:
	j uart_recv_interrupt_main
	
timer_interrupt_main:
	j timer_interrupt_main		#´ı²âÊÔ
exception_main:
	j exception_main			#´ı²âÊÔ
uart_send_interrupt_main:
	j uart_send_interrupt_main
uart_recv_interrupt_main:		
	j uart_recv_interrupt_main	#´ı²âÊÔ
entry_main:
	addi $t0, $zero, 10
	addi $t1, $zero, -138
	add $t2, $t1, $t0
	sub $t3, $t1, $t2
	addu $t4, $t1, $t0
	subu $t5, $t1, $t0
	addiu $t6, $t5, -1234
	addi $t7, $t5, -1234
	and $s0, $t2, $t5
	or $s1, $t2, $t5
	xor $s2, $t2, $t5
	nor $s3, $t2, $t5
	andi $s4, $t5, 0xFA25
jump2:
	sll $s5, $s2, 4
	srl $s6, $s2, 20
	sra $s7, $t7, 10
	slt $a0, $t1, $t0
	slti $a1, $t0, 10
	sltiu $a2, $t1, 10
	beq $a1, $zero, jump1
	and $s0, $t2, $t5
	or $s1, $t2, $t5
	xor $s2, $t2, $t5	
jump1:
	bne $zero, $zero, jump2
	blez $t1, jump3
	and $s0, $t2, $t5
	or $s1, $t2, $t5
	xor $s2, $t2, $t5	
jump3:
	bgtz $t1, jump1
	bgtz $zero, jump1
	bgtz $t0, jump4
	and $s0, $t2, $t5
	or $s1, $t2, $t5
	xor $s2, $t2, $t5
jump4:
	bgez $t1, jump3
	bgez $zero, jump5
	and $s0, $t2, $t5
	or $s1, $t2, $t5
	xor $s2, $t2, $t5	
jump5:
	jal jump6
	jal jump6
	jal jump7
	and $s0, $t2, $t5
	or $s1, $t2, $t5
	xor $s2, $t2, $t5
	j entry_main
jump6:
	jr $ra
jump7:
	jalr $ra, $ra
	and $s0, $t2, $t5
	or $s1, $t2, $t5
	xor $s2, $t2, $t5	
