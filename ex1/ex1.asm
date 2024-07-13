.global _start

.section .text
_start:
    movq Adress, %r9
    cmpq $0, %r9
    je not_legal_HW1
    movslq length, %r10
    movslq Index, %r11
    cmpq %r10, %r11
    jae end
    movb $1 , Legal
    movq (%r9, %r11, 4), %r12
    movl %r12d, num
    jmp end
not_legal_HW1:
    movb $0, Legal
end:

 # Print "num: "
    movq $1, %rax         # syscall number for sys_write
    movq $1, %rdi         # file descriptor (stdout)
    lea num_label(%rip), %rsi # address of num label
    movq $6, %rdx         # number of bytes to write (length of "num: \n")
    syscall               # make the syscall to print num label

    # Convert num to string
    movl num, %eax        # move num to %eax
    movq $num_buf + 12, %rsi # point to the end of the buffer
    movb $0, (%rsi)       # null-terminate the string

convert_num_to_str:
    dec %rsi              # move pointer backwards
    movl $10, %ecx        # base 10
    xor %edx, %edx        # clear %edx for division
    div %ecx              # divide %eax by 10
    addb $'0', %dl        # convert remainder to ASCII
    movb %dl, (%rsi)      # store character in buffer
    test %eax, %eax       # check if quotient is zero
    jnz convert_num_to_str # loop if quotient is not zero

    # Print num
    movq $1, %rax         # syscall number for sys_write
    movq $1, %rdi         # file descriptor (stdout)
    movq %rsi, %rsi       # address of the string
    movq $num_buf + 12, %rdx
    sub %rsi, %rdx        # calculate the string length
    syscall               # make the syscall to print num

    # Print newline
    movq $1, %rax         # syscall number for sys_write
    movq $1, %rdi         # file descriptor (stdout)
    lea newline(%rip), %rsi # address of newline character
    movq $1, %rdx         # number of bytes to write
    syscall               # make the syscall to print newline

    # Print "Legal: "
    movq $1, %rax         # syscall number for sys_write
    movq $1, %rdi         # file descriptor (stdout)
    lea legal_label(%rip), %rsi # address of legal label
    movq $8, %rdx         # number of bytes to write (length of "Legal: \n")
    syscall               # make the syscall to print legal label

    # Convert Legal to string
    movzbl Legal, %eax    # move Legal to %eax and zero-extend
    addb $'0', %al        # convert to ASCII
    movb %al, legal_buf   # store in buffer
    movb $0, legal_buf+1  # null-terminate the string

    # Print Legal
    movq $1, %rax         # syscall number for sys_write
    movq $1, %rdi         # file descriptor (stdout)
    lea legal_buf(%rip), %rsi # address of Legal string
    movq $1, %rdx         # number of bytes to write
    syscall               # make the syscall to print Legal

    # Print newline
    movq $1, %rax         # syscall number for sys_write
    movq $1, %rdi         # file descriptor (stdout)
    lea newline(%rip), %rsi # address of newline character
    movq $1, %rdx         # number of bytes to write
    syscall               # make the syscall to print newline

    # Exit the program
    movq $60, %rax        # syscall number for sys_exit
    xorq %rdi, %rdi       # exit status (0 for success)
    syscall               # make the syscall to exit the program

.section .rodata
num_label:
    .asciz "num: \n"
legal_label:
    .asciz "Legal: \n"
newline:
    .asciz "\n"

.section .bss
    .lcomm num_buf, 13    # buffer to hold string representation of num
    .lcomm legal_buf, 2   # buffer to hold string representation of Legal
