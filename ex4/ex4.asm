.global _start
_start:
   movq $0, %r9                  # Initialize result to 0
    movq $0, %r8                  # Initialize index i to 0

check_next_node:
    cmpq $3, %r8                  # Check if i >= 3
    jge end_check                 # If so, exit loop

    movq nodes(, %r8, 8), %r10    # Load currentNode = nodes[i]

    # Initialize flags
    movb $1, %al                  # Set hasMonotonicSeries to true
    movq 0(%r10), %r12            # Load prev pointer
    cmpq $0, %r12                 # Check if prev is nullptr
    je end_check_left             # If so, end check

    movl 8(%r12), %eax            # Load previousValue
    movl 8(%r10), %ebx            # Load currentValue

check_left_monotonic:
    movq 0(%r12), %r13            # Load next prev pointer
    cmpq $0, %r13                 # Check if next prev is nullptr
    je end_check_left             # If so, end check

    movl 8(%r13), %ecx            # Load nextValue
    
    # Check if the current value is a peak or trough
    cmp %ebx, %eax                # Compare currentValue and previousValue
    jg check_trough               # If currentValue > previousValue, check trough
    jl check_peak                  # If currentValue < previousValue, check peak

next_iteration:
    movq %r12, %r13                # Move to the previous node
    movq %r13, %r12                # Load new prev pointer
    movl 8(%r12), %eax            # Load new previousValue
    movl 8(%r10), %ebx            # Load new currentValue
    jmp check_left_monotonic

check_peak:
    cmp %eax, %ecx                # Compare previousValue and nextValue
    jg not_monotonic              # If previousValue > nextValue, it's not monotonic
    jmp next_iteration

check_trough:
    cmp %eax, %ecx                # Compare previousValue and nextValue
    jl not_monotonic              # If previousValue < nextValue, it's not monotonic
    jmp next_iteration

not_monotonic:
    movb $0, %al                  # Set hasMonotonicSeries to false
    jmp end_check_left

end_check_left:
    # Check if left is monotonic
    testb %al, %al                # If hasMonotonicSeries
    jz skip_increment              # If not, skip increment

    incq %r9                      # Increment result if left is monotonic

skip_increment:
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
