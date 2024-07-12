.global _start
_start:
   movq $0, %r9                  # Initialize result to 0
    movq $0, %r8                  # Initialize index i to 0

check_next_node:
    cmpq $3, %r8                  # Check if i >= 3
    jge end_check                 # If so, exit loop

    movq nodes(, %r8, 8), %r10    # Load currentNode = nodes[i]
    movq %r10, %r11               # current = currentNode

    # Check left monotonicity
    movb $1, %al                  # Set leftMonotonic to true
check_left_monotonic:
    movq 0(%r11), %r12            # Load prev pointer
    cmpq $0, %r12                 # Check if prev is nullptr
    je check_right_monotonic      # If so, check right

    # Load data from currentNode and prev
    movl 8(%r11), %eax            # Load currentNode->data
    movl 8(%r12), %ebx            # Load prev->data
    cmpl %ebx, %eax               # Compare currentNode->data and prev->data
    jl not_left_monotonic         # If currentNode->data < prev->data, not monotonic
    movq %r12, %r11               # Move to the previous node
    jmp check_left_monotonic

not_left_monotonic:
    movb $0, %al                  # Set leftMonotonic to false

check_right_monotonic:
    movq 16(%r10), %r12           # Load next pointer
    cmpq $0, %r12                 # Check if next is nullptr
    je end_check_left_right       # If so, end check

    # Load data from currentNode and next
    movl 8(%r10), %eax            # Load currentNode->data
    movl 8(%r12), %ebx            # Load next->data
    cmpl %ebx, %eax               # Compare currentNode->data and next->data
    jg not_right_monotonic        # If currentNode->data > next->data, not monotonic

    # Continue checking right monotonicity
    movq %r12, %r10               # Move to the next node
    jmp check_right_monotonic

not_right_monotonic:
    movb $0, %bl                  # Set rightMonotonic to false

end_check_left_right:
    testb %al, %al                # If leftMonotonic
    testb %bl, %bl                # If rightMonotonic
    jz next_node                  # If either is not monotonic, skip

    incq %r9                      # Increment result if both are monotonic

next_node:
    incq %r8                      # Increment i
    jmp check_next_node

end_check:
    movq %r9, result(%rip)        # Store result


# Print "result="
    movq $1, %rax            # syscall number for sys_write
    movq $1, %rdi            # file descriptor (stdout)
    lea result_label(%rip), %rsi   # address of result_label
    movq $8, %rdx            # number of bytes to write (length of "result=")
    syscall                  # make the syscall to print "result="

    # Convert result to ASCII character
    movzbq result, %rax      # zero-extend result into %rax
    add $'0', %al            # convert result value to ASCII character
    movb %al, result_buf     # move ASCII character to result_buf

    # Print the value of 'result'
    movq $1, %rax            # syscall number for sys_write
    movq $1, %rdi            # file descriptor (stdout)
    lea result_buf(%rip), %rsi   # address of result_buf
    movq $1, %rdx            # number of bytes to write (1 byte for result value)
    syscall                  # make the syscall to print result

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
result_label:
    .asciz "result="
newline:
    .byte 10                 # ASCII code for newline ('\n')

.section .data
result_buf:
    .byte ' '                # initialize with a space character (' ')
