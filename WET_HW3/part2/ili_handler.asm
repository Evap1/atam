.globl my_ili_handler

.text
.align 4, 0x90
# this function is both caller (to what_to_do) and callee (by main)
# we dont know what calle registers what_to_do could override so we backup them all 
my_ili_handler:
  ####### backup callee registers #######
  pushq %rbx
  pushq %rsp
  pushq %rbp
  pushq %r12
  pushq %r13
  pushq %r14
  pushq %r15

  ####### 1. diagnose interupt #######
  # save the opcode in %rcx - error code is transferred where rsp is pointed in handler stack
  # assume the wrong opcode is at most 2 bytes - stored in cx
  xorq %rcx, %rcx
  movq 56(%rsp), %rcx
  movq (%rcx), %rcx

  # check if opcode is 1 or 2 bytes 
  cmpb $0x0f, %cl
  xorq %r11, %r11                   # r11 = 0 (one byte)
  je one_byte_HW3
  movq $1 , %r11                    # r11 = 1 (two bytes)

  ####### 2. call what_to_do  #######
# in case of two bytes - send the lsb byte
two_byte_HW3:
  movb 1(%rcx), %dil                # move the second byte of opcode to %dil (for %rdi)
  pushq %r11                        # caller backup
  pushq %rdi                        # caller backup
  pushq %rcx                        # caller backup
  call what_to_do
  jmp return_what_to_do_HW3

one_byte_HW3:
  movb %cl, %dil                    # move the only byte of opcode to %dil (for %rdi)
  pushq %r11                        # caller backup
  pushq %rdi                        # caller backup
  pushq %rcx                        # caller backup
  call what_to_do

  ####### 3. check return value of what_to_do and use the right handler  #######
return_what_to_do_HW3:
  popq %rcx                            # caller restore
  popq %rdi                          # caller restore
  popq %r11                         # caller restore
  testq %rax, %rax                  # check if return value is 0 
  je original_handler_HW3
  
new_handler_HW3:
# restore callee registers
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %rbp
  popq %rsp
  popq %rbx

# prepare to return from handler by cases:
  movq %rax, %rdi                  # store the return value at rdi
  cmpq $1, %r11                    # check if two bytes
  je two_byte_forward_HW3

one_byte_forward_HW3:
  addq $1, (%rsp)
  jmp end_HW3

two_byte_forward_HW3:
  addq $2, (%rsp)
  jmp end_HW3

original_handler_HW3: 
# restore callee registers
  popq %r15
  popq %r14
  popq %r13
  popq %r12
  popq %rbp
  popq %rsp
  popq %rbx

  jmp *old_ili_handler              # old_ili_handler is a pointer to the original handler
  jmp end_HW3

end_HW3:
  iretq
