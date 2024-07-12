.global _start

.section .text

_start:
    movq $0, %r9               # Initialize result to 0
    movq $0, %r8               # Initialize index i to 0

check_nodes:
    cmpq $3, %r8               # Compare i with 3
    jge end_check              # If i >= 3, exit loop

    movq nodes(, %r8, 8), %r10  # Load currentNode = nodes[i]

    # Initialize tendency
    movq $0, %r11               # 0 = undecided, 1 = up, -1 = down

    # Left check
    movq 0(%r10), %r12          # Load prev pointer
    cmpq $0, %r12               # Check if prev is nullptr
    je right_check              # If so, skip left

find_tendency_left:
    movl 8(%r12), %eax          # Load prev->data
    movq 0(%r12), %r13          # Load prev of prev pointer
    cmpq $0, %r13               # Check if prev of prev is nullptr
    je right_check              # If so, skip left

    movl 8(%r13), %ebx          # Load prev of prev->data
    cmp %eax, %ebx
    je equal_left

    # Determine tendency
    cmp %eax, %ebx
    jg set_left_down            # If prev > prev of prev, set tendency to down
    jl set_left_up              # If prev < prev of prev, set tendency to up

equal_left:
    movq %r13, %r12             # Move prev of prev to prev
    jmp find_tendency_left      # Continue checking

set_left_down:
    movq $-1, %r11              # Set tendency to down
    jmp check_left_tendency

set_left_up:
    movq $1, %r11               # Set tendency to up

check_left_tendency:
    cmpq $0, %r12               # Check if prev is nullptr
    je right_check              # If so, skip left

    movl 8(%r12), %ecx          # Load prev->data
    cmpq $1, %r11
    jl check_left_down          # If tendency is down, check that the values are decreasing

check_left_up:
    cmp %ebx, %ecx
    jge not_monotonic
    jmp continue_check_left

check_left_down:
    cmp %ebx, %ecx
    jle not_monotonic

continue_check_left:
    movq 0(%r12), %r12          # Load prev pointer
    jmp check_left_tendency

right_check:
    # Initialize tendency
    movq $0, %r11               # 0 = undecided, 1 = up, -1 = down
    movq 12(%r10), %r12         # Load next pointer
    cmpq $0, %r12               # Check if next is nullptr
    je increment_result         # If so, increment result and skip right

find_tendency_right:
    movl 8(%r12), %eax          # Load next->data
    movq 12(%r12), %r13         # Load next of next pointer
    cmpq $0, %r13               # Check if next of next is nullptr
    je increment_result         # If so, increment result and skip right

    movl 8(%r13), %ebx          # Load next of next->data
    cmp %eax, %ebx
    je equal_right

    # Determine tendency
    cmp %eax, %ebx
    jg set_right_down           # If next > next of next, set tendency to down
    jl set_right_up             # If next < next of next, set tendency to up

equal_right:
    movq %r13, %r12             # Move next of next to next
    jmp find_tendency_right     # Continue checking

set_right_down:
    movq $-1, %r11              # Set tendency to down
    jmp check_right_tendency

set_right_up:
    movq $1, %r11               # Set tendency to up

check_right_tendency:
    cmpq $0, %r12               # Check if next is nullptr
    je increment_result         # If so, skip right

    movl 8(%r12), %ecx          # Load next->data
    cmpq $1, %r11
    jl check_right_down         # If tendency is down, check that the values are decreasing

check_right_up:
    cmp %ebx, %ecx
    jge not_monotonic
    jmp continue_check_right

check_right_down:
    cmp %ebx, %ecx
    jle not_monotonic

continue_check_right:
    movq 12(%r12), %r12         # Load next pointer
    jmp check_right_tendency

increment_result:
    incq %r9                    # Increment result if monotonic
    jmp increment_index         # Move to next node

not_monotonic:
    jmp increment_index         # Move to the next node

increment_index:
    incq %r8                    # Increment index i
    jmp check_nodes             # Repeat the loop

end_check:
    movq %r9, result            # Store the value of %r9 into the address of the label 'result'

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
