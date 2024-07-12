.global _start
_start:
    movq $0, %r9               # Initialize result to 0
    movq $0, %r8               # Initialize index i to 0

check_nodes:
    cmpq $3, %r8               # Compare i with 3
    jge end_check              # If i >= 3, exit loop

    movq nodes(, %r8, 8), %r10  # Load currentNode = nodes[i]
    
    # Initialize tendency
    movq $0, %r11               # 0 = undecided, 1 = up, -1 = down
    movq 0(%r10), %r12          # Load prev pointer
    cmpq $0, %r12               # Check if prev is nullptr
    je right_check              # If so, skip left

    movq 0(%r12), %r13          # Load prev of prev pointer
    cmpq $0, %r13               # Check if prev of prev is nullptr
    je right_check              # If so, skip left

inner_left_check:
    movl 8(%r12), %eax          # Load prev->data
    movl 8(%r13), %ebx          # Load prev of prev->data

    # Determine tendency
    cmp %eax, %ebx
    jg set_down                 # If prev > prev of prev, set tendency to down
    jl set_up                   # If prev < prev of prev, set tendency to up
    jmp check_next_left         # If equal, check next left

set_down:
    movq $-1, %r11              # Set tendency to down
    jmp check_next_left

set_up:
    movq $1, %r11               # Set tendency to up

check_next_left:
    movq 0(%r13), %r14          # Load prev of prev of prev pointer
    cmpq $0, %r14               # Check if prev of prev of prev is nullptr
    je right_check              # If so, skip left

    movl 8(%r14), %ecx          # Load prev of prev of prev->data

    # Check if the tendency is maintained
    cmp %r11, $1                 # Check if tendency is up
    je check_up
    cmp %r11, $-1                # Check if tendency is down
    je check_down

check_up:
    cmp %ebx, %ecx               # Compare prev of prev with prev of prev of prev
    jge not_monotonic            # If not maintaining tendency, it's not monotonic
    jmp next_iteration_left

check_down:
    cmp %ebx, %ecx               # Compare prev of prev with prev of prev of prev
    jle not_monotonic            # If not maintaining tendency, it's not monotonic

next_iteration_left:
    movq %r13, %r12             # Move prev of prev to prev
    movq %r14, %r13             # Move prev of prev of prev to prev of prev
    jmp inner_left_check

right_check:
    # Check if there are at least 3 elements to the right
    movq 12(%r10), %r12          # Load next pointer
    cmpq $0, %r12               # Check if next is nullptr
    je increment_result          # If so, increment result and skip checks

    movq 12(%r12), %r13          # Load next of next pointer
    cmpq $0, %r13               # Check if next of next is nullptr
    je increment_result          # If so, increment result and skip checks

inner_right_check:
    movq 12(%r13), %r14          # Load next of next of next pointer
    cmpq $0, %r14               # Check if next of next of next is nullptr
    je increment_result          # If so, increment result and skip checks

    movl 8(%r12), %eax          # Load next->data
    movl 8(%r13), %ebx          # Load next of next->data

    # Determine tendency
    cmp %eax, %ebx
    jg set_right_down           # If next > next of next, set tendency to down
    jl set_right_up             # If next < next of next, set tendency to up
    jmp check_next_right        # If equal, check next right

set_right_down:
    movq $-1, %r11              # Set tendency to down
    jmp check_next_right

set_right_up:
    movq $1, %r11               # Set tendency to up

check_next_right:
    movq 12(%r13), %r14          # Load next of next of next pointer
    cmpq $0, %r14               # Check if next of next of next is nullptr
    je increment_result          # If so, increment result and skip checks

    movl 8(%r14), %ecx          # Load next of next of next->data

    # Check if the tendency is maintained
    cmp %r11, $1                 # Check if tendency is up
    je check_right_up
    cmp %r11, $-1                # Check if tendency is down
    je check_right_down

check_right_up:
    cmp %ebx, %ecx               # Compare next of next with next of next of next
    jge not_monotonic            # If not maintaining tendency, it's not monotonic
    jmp next_iteration_right

check_right_down:
    cmp %ebx, %ecx               # Compare next of next with next of next of next
    jle not_monotonic            # If not maintaining tendency, it's not monotonic

next_iteration_right:
    movq %r13, %r12             # Move next of next to next
    movq %r14, %r13             # Move next of next of next to next of next
    jmp inner_right_check

increment_result:
    incq %r9                     # Increment result if monotonic
    incq %r8                     # Increment index i
    jmp check_nodes              # Repeat the loop

not_monotonic:
    incq %r8                     # Increment index i
    jmp check_nodes              # Jump to next node out of the 3

end_check:
    movq %r9, result             # Store the value of %r9 into the address of the label 'result'


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
