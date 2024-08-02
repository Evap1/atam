.global _start

.section .text
count_above:
#prolog
    push %rbp
    mov %rsp, %rbp
# allocate space for local variables
    subq $128, %rsp

#FUNCTION ARGUMENTS
# char separator passed in lower byte of rdi -> dil -> -8(%rbp)
# long limit passed in 8 bytes of rsi -> -16(%rbp)
    movb %dil, -8(%rbp)
    movq %rsi, -16(%rbp)
    call get_path 			# return value - stored in rax - is the path to the file to read
    mov %rax, %rdi           # move the returned value to rdi for the following syscall (pathname argument)

# open the file
    movq $2, %rax
    movq $2, %rsi 		# allow read and write
    movq $0, %rdx
    syscall
    movq %rax, %rdi		# store the file descriptor for further use

    leaq -128(%rbp), %rsi		# prepare to read: send to read to buffer
    xor %r9, %r9 			# r9 = counter = 0

read_loop_HW3:
# read one byte from the open file
    movq $0, %rax
    movq $1, %rdx			# number of votes to read
    syscall

#  check if EOF and store indication that this is the last iteration.
    testq %rax, %rax			# rax = number of bytes read. If 0 then EOF.
    movq %rax, -24(%rbp)
    jz convert_str_num_HW3

# r8d = current read byte
    movb (%rsi), %r8b

# check if the read byte if the separator 
    cmpb -8(%rbp),  %r8b
    jne continue_reading_HW3

# prepare to convert, replace seperetor with \0 and backup 
convert_str_num_HW3:
    movb $0, (%rsi) 
    movq %r8, -32(%rbp)
    movq %r9, -40(%rbp)
    movq %rsi, -48(%rbp)
    movq %rdx, -56(%rbp)
    movq %rdi, -64(%rbp)

# pass pointer to start reading by rdi, call the function and store the return value at r10 with sign extension
    leaq -128(%rbp), %rdi
    call atam_atol
    movq %rax, %r10			# r10 = current number

# restore all values in backup
    movq  -32(%rbp), %r8
    movq  -40(%rbp), %r9
    movq  -48(%rbp), %rsi
    movq  -56(%rbp), %rdx
    movq  -64(%rbp), %rdi

# compare with sign the current number with limit and load indication to r11.
# -24(rbp) = indication for EOF
    movq -24(%rbp), %r11
    leaq -128(%rbp), %rsi 			# prepare for another iteration
    cmpq %r10, -16(%rbp)
    jl update_counter_HW3		# jumps if limit < current number (signed)
    jmp read_loop_HW3			# find the next number	

# r9 = counter
# r11 = EOF ?
update_counter_HW3:
    incq %r9
    testq %r11, %r11
    je end_count_above_HW3		# if EOF - end
    jmp read_loop_HW3			# find the next number	

continue_reading_HW3:
    incq %rsi
    jmp read_loop_HW3

# close file, set return value, restore callee backups and pop return address
end_count_above_HW3:
    movq $3, rax				#system code for close file
    syscall
    movq %r9, %rax
    addq $128, %rsp
    popq %rbp
    ret
