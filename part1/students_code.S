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
	ret

matrix_multiplication:
	ret

