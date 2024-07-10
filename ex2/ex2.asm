.global _start

.section .text
_start:
    movb $3, type            # Initialize type to 3
    movq size, %r9           # Load size into r9
    subq $1 , %r9
    movq data, %r10          # Load address of data into r10
    movq size, %r13          # Load size into r13
    shrq $3, %r13            # Divide size by 8 (size/8)
    andq $7, %r9             # r9 = r9 & 7 (check if size is divisible by 8)
    testq %r9, %r9           # Update ZF based on r9
    je loop_zeros            # Jump if size is divisible by 8



loop_zeros:
    movq $0, %r11
    movq (%r10, %r11, 8), %r12 # Load quad from data using base=data and iterator=R11
    testq %r12, %r12         # Check if quad value is 0
    je update_type1
    addq $1, %r11            # I++
    cmpq %r11, %r13          # Compare r11 with r13
    jb loop_zeros            # Loop if index < size

    cmpb $3, type            # Compare type with 3
    je end                   # Exit if type is 3

    
    movb (%r10, %r9, 1), %al   # Load byte from data
    cmpb $0, %al             # Check if null terminator
    jne update_type4


update_type1:
    movb $1, type            # Initialize type to 1 for simple set check

loop_simple:
    movq $0, %r11            # Reset index to 0

check_simple_char:
    cmpq %r11, %r9          # Compare index with size to ensure bounds
    je end_simple_check     # Exit loop if index = size-1

    movb (%r10, %r11, 1), %al   # Load byte from data
    cmpb $0, %al       # Check if null terminator
    je update_type4

    # Check if character is punctuation (',', '.', '?', '!', ' ')
    cmpb $33, %al    # ASCII value of '!' is 33
    je simple_char
    cmpb $63, %al    # ASCII value of '?' is 63
    je simple_char
    cmpb $46, %al    # ASCII value of '.' is 46
    je simple_char
    cmpb $44, %al    # ASCII value of ',' is 44
    je simple_char
    cmpb $32, %al    # ASCII value of space ' ' is 32
    je simple_char

    # Check if character is a digit (0-9)
    cmpb $'0', %al
    jg not_simple
    cmpb $'9', %al
    jbe simple_char

    # Check if character is a letter (A-Z or a-z)
    cmpb $'A', %al
    jg not_simple
    cmpb $'Z', %al
    jbe simple_char
    cmpb $'a', %al
    jg not_simple
    cmpb $'z', %al
    jbe simple_char


not_simple:
    movb $2, type            # Set type to 2
    jmp end_simple_check     # Jump to end check

simple_char:
    incq %r11                # Increment index
    jmp check_simple_char    # Loop to check next character

end_simple_check:
    cmpb $1, type            # Check if type is 1
    je end                   # Exit if type is 1


loop_science:
    movq $0, %r11            # Reset index to 0

check_science_char:
    cmpq %r11, %r9          # Compare index with size to ensure bounds
    je end                  # Exit loop if index = size-1

    movb (%r10, %r11, 1), %al   # Load byte from data

    cmpb $32, %al
    jg not_science           # Check if character < 32
    cmpb $126, %al
    jb not_science           # Check if character > 126

    incq %r11                # Increment index
    jmp check_science_char   # Loop if index < size

not_science:
    movb $4, type            # Set type to 4

update_type4:
    movb $4, type            # Set type to 4

end:
    # pseudo code
    # type = 3
    # if size%8 == 0
    #   for I in size%8
    #       if data[I] == 0
    #           type = 4
    # if type = 3 : end
    #
    # loop_simple:
    # type = 1
    # for I in size:
    #   if data[I] is not in simple set
    #       type = 2
    # if type = 1 end:
    #
    # loop_science:
    # for I in size:
    #   if data[I] is not in science set
    #       type = 4
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
