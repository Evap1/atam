# Print "seconddegree="
movq $1, %rax                # syscall number for sys_write
movq $1, %rdi                # file descriptor (stdout)
lea seconddegree_label(%rip), %rsi  # address of seconddegree_label
movq $13, %rdx               # number of bytes to write
syscall                      # print "seconddegree="

# Print the value of seconddegree
movzbl seconddegree(%rip), %eax  # move the value into %eax and zero-extend
movq $seconddegree_buf + 12, %rsi # point to the end of the buffer
movb $0, (%rsi)              # null-terminate the string

convert_seconddegree_to_str:
    dec %rsi                     # move pointer backwards
    movl $10, %ecx               # base 10
    xor %edx, %edx               # clear %edx for division
    div %ecx                     # divide %eax by 10
    addb $'0', %dl               # convert remainder to ASCII
    movb %dl, (%rsi)             # store character in buffer
    test %eax, %eax              # check if quotient is zero
    jnz convert_seconddegree_to_str # loop if quotient is not zero

# Print the string representation of 'seconddegree'
movq $1, %rax                # syscall number for sys_write
movq $1, %rdi                # file descriptor (stdout)
movq %rsi, %rdx              # address of the string
movq $seconddegree_buf + 12, %rcx
sub %rsi, %rcx               # calculate the string length
movq %rsi, %rsi              # address of the string
movq %rcx, %rdx              # number of bytes to write
syscall                      # print seconddegree

# Print a newline
movq $1, %rax                # syscall number for sys_write
movq $1, %rdi                # file descriptor (stdout)
lea newline(%rip), %rsi      # address of newline character
movq $1, %rdx                # number of bytes to write
syscall                      # print newline

# Exit the program
movq $60, %rax               # syscall number for sys_exit
xor %rdi, %rdi               # exit status (0 for success)
syscall
