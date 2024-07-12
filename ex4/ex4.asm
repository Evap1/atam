.global _start

_start:
.section .data
nodes:
    .quad Node2
    .quad Node1
    .quad Node3
result:
    .byte 0

Node1: 
    .quad 0
    .int 1
    .quad Node2
Node2: 
    .quad Node1
    .int 4
    .quad Node3
Node3: 
    .quad Node2
    .int 7
    .quad 0

.section .text
.global _start
_start:
    # Initialize result to 0
    movb $0, result

    # Initialize loop counter to 0
    movq $0, %rdi

check_next_node:
    # Check if loop counter is 3
    cmpq $3, %rdi
    je end_loop

    # Load the current node address
    movq nodes(, %rdi, 8), %r8  # %r8 = nodes[rdi]

    # Initialize left and right monotonicity flags
    movb $1, %r9b  # leftNonIncreasing
    movb $1, %r10b # leftNonDecreasing
    movb $1, %r11b # rightNonIncreasing
    movb $1, %r12b # rightNonDecreasing

    # Save the current node pointer
    movq %r8, %r13

    # Check left side
    movq (%r8), %r8 # %r8 = current->prev
check_left:
    testq %r8, %r8
    jz check_right   # If %r8 == NULL, jump to check_right

    movq (%r8), %r14 # %r14 = leftPtr->prev
    testq %r14, %r14
    jz check_right   # If %r14 == NULL, jump to check_right

    movl 8(%r8), %r15d  # %r15d = leftPtr->data
    movl 8(%r14), %edx  # %edx = leftPrev->data

    cmpq %r15, %rdx
    jl not_left_non_increasing
    cmpq %r15, %rdx
    jg not_left_non_decreasing

    movq %r14, %r8  # leftPtr = leftPrev
    jmp check_left

not_left_non_increasing:
    movb $0, %r9b
    jmp check_left

not_left_non_decreasing:
    movb $0, %r10b
    jmp check_left

check_right:
    # Restore the current node pointer
    movq %r13, %r8

    # Check right side
    movq 16(%r8), %r8 # %r8 = current->next
check_right_inner:
    testq %r8, %r8
    jz finalize_check   # If %r8 == NULL, jump to finalize_check

    movq 16(%r8), %r14 # %r14 = rightPtr->next
    testq %r14, %r14
    jz finalize_check   # If %r14 == NULL, jump to finalize_check

    movl 8(%r8), %r15d  # %r15d = rightPtr->data
    movl 8(%r14), %edx  # %edx = rightNext->data

    cmpq %r15, %rdx
    jl not_right_non_increasing
    cmpq %r15, %rdx
    jg not_right_non_decreasing

    movq %r14, %r8  # rightPtr = rightNext
    jmp check_right_inner

not_right_non_increasing:
    movb $0, %r11b
    jmp check_right_inner

not_right_non_decreasing:
    movb $0, %r12b
    jmp check_right_inner

finalize_check:
    # Check if both conditions are met
    testb %r9b, %r9b
    jz next_node
    testb %r10b, %r10b
    jz next_node
    testb %r11b, %r11b
    jz next_node
    testb %r12b, %r12b
    jz next_node

    # If both conditions are met, increment result
    incb result

next_node:
    # Increment loop counter and proceed to next node
    incq %rdi
    jmp check_next_node

end_loop:


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
