.globl my_ili_handler

.text
.align 4, 0x90
# this function is both caller (to what_to_do) meaning : can assume what_to_do will recover rbx,rsp,rbp,r12,r13,r14,r15 but rax, rdi,rsi,rdx,rcx,r8,r9,r10,r11 might be overriden.
# and callee (by main) meaning : can override rax, rdi,rsi,rdx,rcx,r8,r9,r10,r11 without backup.
my_ili_handler:
  ####### backup caller registers #######
  pushq %rax
  pushq %r11                        # caller backup
  pushq %rcx                        # caller backup


  ####### 1. diagnose interupt #######
  # save the opcode in %rcx - error code is transferred where rsp is pointed in handler stack
  # assume the wrong opcode is at most 2 bytes - stored in cx
  xorq %rcx, %rcx
  xorq %rdi, %rdi
  movq 24(%rsp), %rcx
  movq (%rcx), %rcx

  # check if opcode is 1 or 2 bytes 
  xorq %r11, %r11                   # r11 = 0 (one byte)
  cmpb $0x0f, %cl
  jne one_byte_HW3                  # if MSB byte is not 0f then it is only one byte
  movq $1 , %r11                    # r11 = 1 (two bytes)
  jmp two_byte_HW3

  ####### 2. call what_to_do  #######
# in case of two bytes - send the lsb byte
two_byte_HW3:
  movq 24(%rsp), %rcx
  movb 1(%rcx), %dil                # move the second byte of opcode to %dil (for %rdi)
  pushq %rdi                        # caller backup
  call what_to_do
  jmp return_what_to_do_HW3

one_byte_HW3:
  movb %cl, %dil                    # move the only byte of opcode to %dil (for %rdi)
  pushq %rdi                        # caller backup
  call what_to_do
  jmp return_what_to_do_HW3

  ####### 3. check return value of what_to_do and use the right handler  #######
return_what_to_do_HW3:
  popq %rdi                          # caller restore
  testq %rax, %rax                  # check if return value is 0 
  je original_handler_HW3
  
new_handler_HW3:
  movq %rax, %rdi                  # store the return value at rdi
# restore caller registers
  popq %rcx
  popq %r11
  popq %rax

# prepare to return from handler by cases:
  cmpq $1, %r11                    # check if two bytes
  je two_byte_forward_HW3

one_byte_forward_HW3:
  addq $1, (%rsp)
  jmp end_HW3

two_byte_forward_HW3:
  addq $2, (%rsp)
  jmp end_HW3

original_handler_HW3: 
# restore caller registers
  popq %rcx
  popq %r11
  popq %rax

  jmp *old_ili_handler              # old_ili_handler is a pointer to the original handler
  jmp end_HW3

end_HW3:
  iretq
