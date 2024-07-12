.global _start
_start:
    movq $0, %r9                  # result = 0
    movq $0, %r8                  # index i = 0

check_next_node:
    cmpq $3, %r8                  # if (i >= 3) break
    jge end_check

    movq nodes(%rip, %r8, 8), %r10  # currentNode = nodes[i]

    # Check left monotonicity
    movq %r10, %r11               # current = currentNode->prev
    movq -8(%r11), %r11
    movb $1, %r12                 # leftMonotonic = true

check_left_monotonic:
    cmpq $0, %r11                 # if (current == nullptr) break
    je end_check_left

    movq -8(%r11), %r13           # previous = current->prev
    cmpq $0, %r13                 # if (previous == nullptr) break
    je end_check_left

    movl 8(%r10), %eax            # currentNode->data
    movl 8(%r11), %ebx            # current->data
    movl 8(%r13), %ecx            # previous->data

    # Compare data values
    cmpl %ebx, %eax               # if (currentNode->data < current->data)
    jg left_monotonic_dec

    cmpl %ecx, %ebx               # if (current->data > previous->data) leftMonotonic = false
    jg not_left_monotonic

    jmp left_monotonic_continue

left_monotonic_dec:
    cmpl %ecx, %ebx               # if (current->data < previous->data) leftMonotonic = false
    jl not_left_monotonic

left_monotonic_continue:
    movq %r13, %r11               # current = previous
    jmp check_left_monotonic

not_left_monotonic:
    movb $0, %r12                 # leftMonotonic = false

end_check_left:

    # Check right monotonicity
    movq 8(%r10), %r11            # current = currentNode->next
    movb $1, %r13                 # rightMonotonic = true

check_right_monotonic:
    cmpq $0, %r11                 # if (current == nullptr) break
    je end_check_right

    movq 8(%r11), %r14            # next = current->next
    cmpq $0, %r14                 # if (next == nullptr) break
    je end_check_right

    movl 8(%r10), %eax            # currentNode->data
    movl 8(%r11), %ebx            # current->data
    movl 8(%r14), %ecx            # next->data

    # Compare data values
    cmpl %ebx, %eax               # if (currentNode->data < current->data)
    jg right_monotonic_dec

    cmpl %ecx, %ebx               # if (current->data > next->data) rightMonotonic = false
    jg not_right_monotonic

    jmp right_monotonic_continue

right_monotonic_dec:
    cmpl %ecx, %ebx               # if (current->data < next->data) rightMonotonic = false
    jl not_right_monotonic

right_monotonic_continue:
    movq %r14, %r11               # current = next
    jmp check_right_monotonic

not_right_monotonic:
    movb $0, %r13                 # rightMonotonic = false

end_check_right:

    # Check if both left and right are monotonic
    testb %r12, %r12              # if (leftMonotonic)
    jz next_node

    testb %r13, %r13              # if (rightMonotonic)
    jz next_node

    incq %r9                      # result++

next_node:
    incq %r8                      # i++
    jmp check_next_node

end_check:
    movq %r9, result(%rip)        # result = r9



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
