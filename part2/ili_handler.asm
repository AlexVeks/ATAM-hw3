.globl my_ili_handler
.extern old_ili_handler

.text
.align 4, 0x90
my_ili_handler:                  
  #save the registers
  pushq %rax        # Save RAX
  pushq %rbx        # Save RBX
  pushq %rcx        # Save RCX
  pushq %rdx        # Save RDX
  pushq %rsi        # Save RSI
  pushq %rbp        # Save RBP
  pushq %rsp        # Save RSP
  pushq %r8         # Save R8
  pushq %r9         # Save R9
  pushq %r10        # Save R10
  pushq %r11        # Save R11
  pushq %r12        # Save R12
  pushq %r13        # Save R13
  pushq %r14        # Save R14
  pushq %r15        # Save R15
  # Find the last byte and put it in RDI #
  movq 120(%rsp), %rcx      # Load the relevant value (opcode) into RCX
  movq (%rcx),%rax
  movq $0, %rdi
  cmpb $0x0F, %al           # Compare the lower byte (AL) with 0x0F
  jne .L2                   # If not equal, jump to .L2
  movb %ah, %al   

.L2:
  movb %al, %dil             # Move the low byte (AL) into RDI, zero-extend
  call what_to_do           # Call the function with RDI as the parameter

  # RAX holds the return value #
  testq %rax, %rax          # Test if RAX is zero
  jne back_to_code                  # If not zero, return to the code
  popq %r15        # Restore R15
  popq %r14        # Restore R14
  popq %r13        # Restore R13
  popq %r12        # Restore R12
  popq %r11        # Restore R11
  popq %r10        # Restore R10
  popq %r9         # Restore R9
  popq %r8         # Restore R8
  popq %rsp        # Restore RSP
  popq %rbp        # Restore RBP
  popq %rsi        # Restore RSI
  popq %rdx        # Restore RDX
  popq %rcx        # Restore RCX
  popq %rbx        # Restore RBX
  popq %rax        # Restore RAX
  movq old_ili_handler, %rax 
  jmp *%rax  
back_to_code:
  movq %rax,%rdi
  movq 120(%rsp), %rcx      # Load the relevant value (opcode) into RCX
  movq (%rcx),%rax
  add $1, %rcx
  cmpb $0x0F, %al           # Compare the lower byte (AL) with 0x0F 
  jne .L3
  add $1,%rcx
.L3:
  movq %rcx, 120(%rsp)
  popq %r15        # Restore R15
  popq %r14        # Restore R14
  popq %r13        # Restore R13
  popq %r12        # Restore R12
  popq %r11        # Restore R11
  popq %r10        # Restore R10
  popq %r9         # Restore R9
  popq %r8         # Restore R8
  popq %rsp        # Restore RSP
  popq %rbp        # Restore RBP
  popq %rsi        # Restore RSI
  popq %rdx        # Restore RDX
  popq %rcx        # Restore RCX
  popq %rbx        # Restore RBX
  popq %rax        # Restore RAX
  iretq                     # Return from interrupt
