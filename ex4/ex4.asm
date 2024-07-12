.global _start
_start:
    movq $0, %r9                  # Initialize result to 0
    movq $0, %r8                  # Initialize index i to 0

check_next_node:
    cmpq $3, %r8                  # Check if i >= 3
    jge end_check                 # If so, exit loop

    movq nodes(, %r8, 8), %r10    # Load currentNode = nodes[i]

    # Check left monotonicity
    movq %r10, %r11               # current = currentNode
    movb $1, %al                  # Set leftMonotonic to true
    movb $1, %bl                  # Set leftMonotonicDecreasing to true

check_left_monotonic:
    movq 0(%r11), %r12            # Load prev pointer
    cmpq $0, %r12                 # Check if prev is nullptr
    je end_check_left             # If so, end check

    # Load data from currentNode and prev
    movl 8(%r11), %eax            # Load currentNode->data
    movl 8(%r12), %ebx            # Load prev->data

    # Compare data values for increasing
    cmpl %ebx, %eax               # Compare currentNode->data and prev->data
    jl not_left_monotonic_increasing
    jg not_left_monotonic_decreasing

    # Move to the previous node
    movq %r12, %r11               # Move to the previous node
    jmp check_left_monotonic

not_left_monotonic_increasing:
    movb $0, %al                  # Set leftMonotonic to false

not_left_monotonic_decreasing:
    movb $0, %bl                  # Set leftMonotonicDecreasing to false

end_check_left:

    # Reset for right-side check
    movq %r10, %r11               # Reset current to currentNode
    movb $1, %cl                  # Set rightMonotonic to true
    movb $1, %dl                  # Set rightMonotonicDecreasing to true

check_right_monotonic:
    movq 16(%r11), %r12           # Load next pointer
    cmpq $0, %r12                 # Check if next is nullptr
    je end_check_right            # If so, end check

    # Load data from currentNode and next
    movl 8(%r11), %eax            # Load currentNode->data
    movl 8(%r12), %ebx            # Load next->data

    # Compare data values for increasing
    cmpl %ebx, %eax               # Compare currentNode->data and next->data
    jl not_right_monotonic_increasing
    jg not_right_monotonic_decreasing

    # Move to the next node
    movq %r12, %r11               # Move to the next node
    jmp check_right_monotonic

not_right_monotonic_increasing:
    movb $0, %cl                  # Set rightMonotonic to false

not_right_monotonic_decreasing:
    movb $0, %dl                  # Set rightMonotonicDecreasing to false

end_check_right:

    # Increment result if both sides are monotonic
    testb %al, %al                # Check leftMonotonic
    jz check_left_decreasing

    testb %bl, %bl                # Check leftMonotonicDecreasing
    jz check_right

check_left_decreasing:
    testb %cl, %cl                # Check rightMonotonic
    jz check_right_decreasing

check_right:
    testb %dl, %dl                # Check rightMonotonicDecreasing
    jnz increment_result

check_right_decreasing:
    jmp end_check

increment_result:
    incq %r9                      # Increment result

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
