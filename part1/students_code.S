.global get_element_from_matrix, inner_prod, matrix_multiplication

.section .text

get_element_from_matrix:
	pushq %rbp
	movq %rsp,%rbp

	; Paramenters passed by the caller:
    ; %rdi - matrix base address (int* matrix[])
    ; %rsi - number of columns (unsigned long n)
    ; %rdx - row index (unsigned long row)
    ; %rcx - column index (unsigned long col)

	movq %rdx,%rax 			; rax = row
	imulq %rsi,%rax			; rax = row * n
	addq %rcx,%rax			; rax = (row * n) + col
	shlq $2, %rax           ; rax = (row * n + col) * 4 (Elements are 32 Bit)
	addq %rdi, %rax         ; rax = matrix + (row * n + col) * 4
	movl (%rax), %eax       ; eax = matrix[row * n + col]

	popq %rbp
	ret						; Result returned in %eax

inner_prod:
	pushq %rbp
	movq %rsp,%rbp

	; Save callee-saved register that will be changed in inner_prod
    pushq %r12

	; Paramenters passed by the caller:
    ; %rdi 	- matrixA base address (int* matrixA[])
    ; %rsi 	- matrixB base address (int* matrixB[])
    ; %rdx 	- matrixA row  index (unsigned long row)
    ; %rcx 	- matrixB col index (unsigned long col)
	; %r8 	- matrixA number of columns (unsigned long n)
	; %r9 	- matrixB number of columns (unsigned long n)

	xorq %rax, %rax				; rax = 0 (result)
	xor %r10, %r10				; r10 = 0 (loopIndex)

	; Loop over the row of matrix A and the column of matrix B
	.loop:
		cmpq %r8, %r10          ; Compare loopIndex with matrix A number of columns
		jge .loop_end      		; If loopIndex >=  matrix A number of columns, exit loop

		; Caller save registers
		pushq %rsi				; matrixB base address
		pushq %rcx 				; matrixB col index

		; Get element from matrix A
		movq %rdi, %rdi         ; matrixA base address
		movq %r8, %rsi          ; number of columns in matrixA
		movq %rdx, %rdx         ; matrixA row  index
		movq %r10, %rcx         ; Loop index runing over matrixA columns
		call get_element_from_matrix
		movl %eax, %r11d        ; Store element in r11d

		; Restore caller save registers
		popq %rcx 				; matrixB col index
		popq %rsi				; matrixB base address

		; Caller save registers
		pushq %rsi				; matrixB base address
		pushq %rdx				; matrixA row  index

		; Get element from matrix B
		movq %rsi, %rdi         ; matrixB base address
		movq %r9, %rsi          ; number of columns in matrixB
		movq %r10, %rdx         ; Loop index runing over matrixB rows
		movq %rcx, %rcx         ; matrixB col index
		call get_element_from_matrix
		movl %eax, %r12d        ; Store element in r12d

		; Restore caller save register
		popq %rdx				; matrixA row  index
		popq %rsi				; matrixB base address
		
		; Multiply elements and add to result
		imul %r11d, %r12d       ; r12d = r11d * r12d
		addl %r12d, %eax        ; eax += r12d

		incq %r10               ; loopIndex++
		jmp .loop     			; Repeat loop

	.loop_end:
	; Restore callee-saved register that changed in inner_prod
    popq %r12

	pop %rbp
	ret

matrix_multiplication:
	ret

