.global _start

.section .text

_start:
    movq $0, %r9               # Initialize result to 0
    movq $0, %r8               # Initialize index i to 0

check_nodes_HW1:
    cmpq $3, %r8               # Compare i with 3
    jge end_check_HW1              # If i >= 3, exit loop

    movq nodes(, %r8, 8), %r10  # Load currentNode = nodes[i]

    movq 0(%r10), %r12          # Load prev pointer
    cmpq $0, %r12               # Check if prev is nullptr
    je right_check_HW1              # If so, skip left

    movq 0(%r12), %r13          # Load prev of prev pointer
    cmpq $0, %r13               # Check if prev of prev is nullptr
    je right_check_HW1              # If so, skip left

decide_tendency_left_HW1:
    movl 8(%r12), %eax          # Load prev->data
    movl 8(%r13), %ebx          # Load prev of prev->data
    cmp %eax, %ebx
    jg left_goes_down_HW1
    jl left_goes_up_HW1
    movq 0(%r13), %r13          # Load prev of prev pointer
    cmpq $0, %r13               # Check if prev of prev is nullptr
    je right_check_HW1              # If so, skip left
    movq 0(%r12), %r12
    jmp decide_tendency_left_HW1

left_goes_down_HW1:
    movq 0(%r13), %r13          # Move prev of prev to prev
    cmpq $0, %r13               # Check if prev is nullptr
    je right_check_HW1              # If so, skip left
    movq 0(%r12), %r12          # Move prev to prev of prev
    movl 8(%r12), %eax          # Load prev->data
    movl 8(%r13), %ebx          # Load prev of prev->data
    cmp %eax, %ebx
    jl not_monotonic_HW1           # If the data is not decreasing, it's not monotonic
    jmp left_goes_down_HW1

left_goes_up_HW1:
    movq 0(%r13), %r13          # Move prev of prev to prev
    cmpq $0, %r13               # Check if prev is nullptr
    je right_check_HW1              # If so, skip left
    movq 0(%r12), %r12          # Move prev to prev of prev
    movl 8(%r12), %eax          # Load prev->data
    movl 8(%r13), %ebx          # Load prev of prev->data
    cmp %eax, %ebx
    jg not_monotonic_HW1           # If the data is not increasing, it's not monotonic
    jmp left_goes_up_HW1


right_check_HW1:
    movq 12(%r10), %r12         # Load next pointer
    cmpq $0, %r12               # Check if next is nullptr
    je increment_result_HW1         # If so, skip right

    movq 12(%r12), %r13         # Load next of next pointer
    cmpq $0, %r13               # Check if next of next is nullptr
    je increment_result_HW1         # If so, skip right

decide_tendency_right:
    movl 8(%r12), %eax          # Load next->data
    movl 8(%r13), %ebx          # Load next of next->data
    cmp %eax, %ebx
    jg right_goes_down_HW1
    jl right_goes_up_HW1
    movq 12(%r13), %r13         # Load next of next pointer
    cmpq $0, %r13               # Check if next of next is nullptr
    je increment_result_HW1         # If so, skip right
    movq 12(%r12), %r12
    jmp decide_tendency_right

right_goes_down_HW1:
    movq 12(%r13), %r13         # Move next of next to next
    cmpq $0, %r13               # Check if next is nullptr
    je increment_result_HW1         # If so, skip right
    movq 12(%r12), %r12         # Move next to next of next
    movl 8(%r12), %eax          # Load next->data
    movl 8(%r13), %ebx          # Load next of next->data
    cmp %eax, %ebx
    jl not_monotonic_HW1           # If the data is not decreasing, it's not monotonic
    jmp right_goes_down_HW1

right_goes_up_HW1:
    movq 12(%r13), %r13         # Move next of next to next
    cmpq $0, %r13               # Check if next is nullptr
    je increment_result_HW1         # If so, skip right
    movq 12(%r12), %r12         # Move next to next of next
    movl 8(%r12), %eax          # Load next->data
    movl 8(%r13), %ebx          # Load next of next->data
    cmp %eax, %ebx
    jg not_monotonic_HW1           # If the data is not increasing, it's not monotonic
    jmp right_goes_up_HW1

increment_result_HW1:
    incq %r9                    # Increment result if monotonic
    incq %r8                    # Increment index i
    jmp check_nodes_HW1             # Repeat the loop

not_monotonic_HW1:
    incq %r8                    # Increment index i
    jmp check_nodes_HW1             # Jump to next node out of the 3

end_check_HW1:
    movq %r9, result            # Store the value of %r9 into the address of the label 'result'

end:

    # Print "result="
    movq $1, %rax               # syscall number for sys_write
    movq $1, %rdi               # file descriptor (stdout)
    lea result_label(%rip), %rsi # address of result_label
    movq $8, %rdx               # number of bytes to write (length of "result=")
    syscall                     # make the syscall to print "result="

    # Convert result to ASCII character
    movzbq result, %rax         # zero-extend result into %rax
    add $'0', %al               # convert result value to ASCII character
    movb %al, result_buf        # move ASCII character to result_buf

    # Print the value of 'result'
    movq $1, %rax               # syscall number for sys_write
    movq $1, %rdi               # file descriptor (stdout)
    lea result_buf(%rip), %rsi  # address of result_buf
    movq $1, %rdx               # number of bytes to write (1 byte for result value)
    syscall                     # make the syscall to print result

    # Print a newline
    movq $1, %rax               # syscall number for sys_write
    movq $1, %rdi               # file descriptor (stdout)
    lea newline(%rip), %rsi     # address of newline character
    movq $1, %rdx               # number of bytes to write (1 byte for newline)
    syscall                     # make the syscall to print newline

    # Exit the program
    movq $60, %rax              # syscall number for sys_exit
    xor %rdi, %rdi              # exit status (0 for success)
    syscall                     # make the syscall to exit the program

.section .rodata
result_label:
    .asciz "result="
newline:
    .byte 10                    # ASCII code for newline ('\n')

.section .data
result_buf:
    .byte ' '                   # initialize with a space character (' ')
