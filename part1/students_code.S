.global get_element_from_matrix, inner_prod, matrix_multiplication

.section .text

get_element_from_matrix:
	pushq %rbp
	movq %rsp,%rbp

	# Paramenters passed by the caller:
    # %rdi - matrix base address
    # %rsi - number of columns
    # %rdx - row index
    # %rcx - column index


	movq %rdx,%rax 				# rax = row
	imulq %rsi,%rax				# rax = row * n
	addq %rcx,%rax				# rax = (row * n) + col
	shlq $2, %rax           	# rax = (row * n + col) * 4
	lea (%rdi,%rax) , %rax      # rax = matrix + (row * n + col) * 4
	movl (%rax), %eax       	# eax = matrix[row * n + col]

	popq %rbp
	ret							# Result returned in %eax



inner_prod:
	pushq %rbp
	movq %rsp,%rbp

	# Save callee-saved register that will be changed in inner_prod
    pushq %r12
	pushq %r13

	# Paramenters passed by the caller:
    # %rdi 	- matrixA base address
    # %rsi 	- matrixB base address
    # %rdx 	- matrixA row  index
    # %rcx 	- matrixB col index
	# %r8 	- matrixA number of columns
	# %r9 	- matrixB number of columns

	xorq %r10, %r10				# r10 = 0 (loopIndex)
	xorq %r13, %r13				# r13 = 0 (result)

	# Loop over the row of matrix A and the column of matrix B
	.inner_prod_loop:
		cmpq %r8, %r10          			# Compare loopIndex with matrix A number of columns
		jge .inner_prod_loop_end      		# If loopIndex >=  matrix A number of columns, exit loop

		# Caller save registers
		pushq %rax
		pushq %rsi				# matrixB base address
		pushq %rcx 				# matrixB col index

		# Get element from matrix A
		movq %rdi, %rdi         # matrixA base address
		movq %r8, %rsi          # number of columns in matrixA
		movq %rdx, %rdx         # matrixA row  index
		movq %r10, %rcx         # Loop index runing over matrixA columns
		call get_element_from_matrix
		movl %eax, %r11d        # Store element in r11d

		# Restore caller save registers
		popq %rcx 				# matrixB col index
		popq %rsi				# matrixB base address
		popq %rax

		# Caller save registers
		pushq %rax
		pushq %rsi				# matrixB base address
		pushq %rdx				# matrixA row  index
		pushq %rdi				# matrixA base address

		# Get element from matrix B
		movq %rsi, %rdi         # matrixB base address
		movq %r9, %rsi          # number of columns in matrixB
		movq %r10, %rdx         # Loop index runing over matrixB rows
		movq %rcx, %rcx         # matrixB col index
		call get_element_from_matrix
		movl %eax, %r12d        # Store element in r12d

		# Restore caller save register
		popq %rdi				# matrixA base address
		popq %rdx				# matrixA row  index
		popq %rsi				# matrixB base address
		popq %rax
		
		# Multiply elements and add to result
		imul %r11d, %r12d       # r12d = r11d * r12d
		addl %r12d, %r13d       # r13d += r12d

		incq %r10               # loopIndex++
		jmp .inner_prod_loop    # Repeat loop

	.inner_prod_loop_end:
		movl %r13d, %eax        # eax = result

		# Restore callee-saved register that changed in inner_prod
		popq %r13
    	popq %r12

		pop %rbp
		ret



matrix_multiplication:
	pushq %rbp
	movq %rsp,%rbp

	# Parameters passed by the caller:
    # %rdi - res base address
    # %rsi - mat_a base address
    # %rdx - mat_b base address
    # %rcx - m (number of rows in mat_a)
    # %r8  - n (number of columns in mat_a)
    # %r9  - w (number of rows in mat_b)
    # stack[16] - q (number of columns in mat_b)
    # stack[24] - p (modulu value)


	# Save callee-saved registers that can be changed in matrix_multiplication
	pushq %rbx
	pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

	# Parametrs that passed in the stack
	movq 16(%rbp), %r10  # q (number of columns in mat_b)
    movq 24(%rbp), %r11  # p (modulu value)

	# Check if the matrices are of the correct size for multiplication
    cmpq %r8, %r9        # Compare n with w
    jne .matrix_multiplication_error           # n != w: The multiplication not possible
	

	xorq %r12, %r12      # row index i = 0
    xorq %r13, %r13      # col index j = 0


	.matrix_multiplication_outer_loop:
    	cmpq %rcx, %r12      # Compare i with m (number of rows in mat_a)
    	jge .matrix_multiplication_done            # If i >= m, exit outer loop

    	xorq %r13, %r13      # Reset col index j = 0

	.matrix_multiplication_inner_loop:
    	cmpq %r10, %r13      # Compare j with q (number of columns in mat_b)
    	jge .matrix_multiplication_next_row        # If j >= q, go to next row

		# Save caller-saved registers before calling inner_prod
		pushq %rdi
    	pushq %rsi
    	pushq %rdx
    	pushq %rcx
    	pushq %r8
    	pushq %r9
		pushq %r10
		pushq %r11

    	# Call inner_prod to get the element at row i and col j in the result matrix
    	movq %rsi, %rdi      # mat_a - base address
    	movq %rdx, %rsi      # mat_b - base address
    	movq %r12, %rdx      # i row_a
    	movq %r13, %rcx      # j col_b
    	movq %r8, %r8        # n max_col_a
    	movq %r10, %r9       # w max_col_b
    	call inner_prod

		# Restore caller-saved registers
    	popq %r11
		popq %r10
    	popq %r9
    	popq %r8
    	popq %rcx
    	popq %rdx
    	popq %rsi
    	popq %rdi

    	# Compute result modulo p
    	cqo                  # Sign extend rax to rdx:rax
    	idivq %r11           # Divide rdx:rax by p, quotient in rax, remainder in rdx
    	movq %rdx, %rax      # Move remainder to rax

		# Save caller-saved registers before calling set_element_in_matrix
    	pushq %rdi
    	pushq %rsi
    	pushq %rdx
    	pushq %rcx
    	pushq %r8
    	pushq %r9
		pushq %r10
		pushq %r11

    	# Store the result in the res matrix
    	movq %rdi, %rdi      # res matrix base address
    	movq %r10, %rsi      # res matrix num_of_columns
    	movq %r12, %rdx      # res matrix row index i
    	movq %r13, %rcx      # res matrix col index j
    	movq %rax, %r8       # value result of inner_prod % p
    	call set_element_in_matrix

		# Restore caller-saved registers
		popq %r11
		popq %r10
    	popq %r9
    	popq %r8
    	popq %rcx
    	popq %rdx
    	popq %rsi
    	popq %rdi

		# Increment matrix B column index
    	incq %r13            # j++
    	jmp .matrix_multiplication_inner_loop

	.matrix_multiplication_next_row:
		# Increment matrix A row index
    	incq %r12            # i++
    	jmp .matrix_multiplication_outer_loop

	.matrix_multiplication_done:
    	# Restore callee-saved registers
    	popq %r15
    	popq %r14
    	popq %r13
    	popq %r12
		popq %rbx

    	movq $1, %rax       # %eax = 1 (success)
    	popq %rbp
    	ret					# Result returned in %eax


	.matrix_multiplication_error:
    	# Restore callee-saved registers
    	popq %r15
    	popq %r14
    	popq %r13
    	popq %r12
		popq %rbx

    	movq $0, %rax       # %eax = 0 (error)
    	popq %rbp
		ret					# Result returned in %eax