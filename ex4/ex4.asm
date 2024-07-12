.global _start
_start:
  movq nodes, %r8             # Load address of nodes array
    xorq %r9, %r9               # Initialize sum to 0
    movq $3, %r10                # Set loop counter for 3 nodes

loop_nodes:
    dec %r10                     # Decrement node index
    jl end                       # Exit if index < 0

    movq (%r8, %r10, 8), %r11    # Load current node address
    movq 0(%r11), %r12           # Load prev pointer
    movl 8(%r11), %eax           # Load currentNode->data
    movq 16(%r11), %r13          # Load next pointer
    cmpq $0, %r12                # Check if prev is null
    je check_right               # If so, skip left check

check_left:
    # Check for monotonicity from left to current node
    cmpq $0, %r12                # Check if there is a previous node
    je check_right               # If no prev, skip left check

    movq %r12, %r12              # Load prev pointer into r12 for next check
    movl 8(%r12), %ebx           # Load prev node data
    cmp %ebx, %eax               # Compare with current node data
    jg not_monotonic             # If prev > current, not monotonic
    # If not less, continue checking

    jmp check_left               # Repeat for all previous nodes

check_right:
    cmpq $0, %r13                # Check if next is null
    je not_monotonic             # If so, skip right check

    # Load next node data
    movl 8(%r13), %ecx           # Load next node data
    cmp %ecx, %eax               # Compare with current node data
    jl not_monotonic             # If next < current, not monotonic

    # If both checks are good, increment sum
    incq %r9
    jmp loop_nodes               # Repeat for the next node

not_monotonic:
    jmp loop_nodes               # Go to the next node

end:
    # Store result in 'result'
    movq %r9, result             # Move the count of monotonic nodes to result

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
