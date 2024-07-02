.global _start

.section .text
_start:
movw $3, type
movq size, %r9
movq data, %r10 
movq size, %r13
Shrq $3 , %r13 # size/8
andq $7 , %r9
testq %r9, %r9  #bitwise and with itself - update ZF
je loop_zeros




loop_zeros:
movq %0, %r11
movq (%r10, %r11, 8), %r12 #iterartes data using base=data and iterator=R11
testq %r12, %r12 # check if quad value is 0
je update_type4
Addq $1 , %r11	# I++
Cmpq %r11 , %r13 # r11 - r13
Jb loop_zeros #  index < size




update_type4:
Movq $4 , type





# pseudo code
# type = 3
# if size%8 == 0
#	for I in size%8
#		if data[I] == 0
#			type = 4
# if type = 3 : end
#
# loop_simple:
# type = 1
# for I in size:
# 	if data[I] is not in simple set
#		type = 2
# if type = 1 end:
#
# loop_science:
# for I in size:
#	if data[I] is not in science set
#		type = 4
# end:






# Print "type="
    movq $1, %rax            # syscall number for sys_write
    movq $1, %rdi            # file descriptor (stdout)
    lea type_label(%rip), %rsi   # address of type_label
    movq $5, %rdx            # number of bytes to write (length of "type=")
    syscall                  # make the syscall to print "type="

    # Convert the value of 'type' to a string
    movl type(%rip), %eax    # move the value of type into %eax
    movq $type_buf + 12, %rsi # point to the end of the buffer
    movb $0, (%rsi)          # null-terminate the string

convert_type_to_str:
    dec %rsi                 # move pointer backwards
    movl $10, %ecx           # base 10
    xor %edx, %edx           # clear %edx for division
    div %ecx                 # divide %eax by 10
    addb $'0', %dl           # convert remainder to ASCII
    movb %dl, (%rsi)         # store character in buffer
    test %eax, %eax          # check if quotient is zero
    jnz convert_type_to_str  # loop if quotient is not zero

    # Print the string representation of 'type'
    movq $1, %rax            # syscall number for sys_write
    movq $1, %rdi            # file descriptor (stdout)
    movq %rsi, %rdx          # length of the string
    movq $type_buf + 12, %rcx
    sub %rsi, %rcx           # calculate the string length
    movq %rsi, %rsi          # address of the string
    movq %rcx, %rdx          # number of bytes to write
    syscall                  # make the syscall to print type

    # Print a newline
    movq $1, %rax            # syscall number for sys_write
    movq $1, %rdi            # file descriptor (stdout)
    lea newline(%rip), %rsi  # address of newline character
    movq $1, %rdx            # number of bytes to write (1 byte for newline)
    syscall                  # make the syscall to print newline

    # Exit the program
    movq $60, %rax           # syscall number for sys_exit
    xor %rdi, %rdi           # exit status (0 for success)
    syscall                  # make the syscall to exit the program

.section .rodata
type_label:
    .asciz "type="
newline:
    .byte 10                 # ASCII code for newline ('\n')

.section .bss
    .lcomm type_buf, 13      # buffer to hold string representation of type