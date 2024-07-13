.global _start

.section .text

_start:
  movq $0, %r8                 # Initialize index i to 0
  movq size, %rcx              # Load size of series

  cmpq $3, %rcx                # Check if size < 3
  jle return_true              # If so, return 1

  # Load first three elements
  movl series, %eax            # a1
  movl series + 4, %ebx        # a2
  movl series + 8, %ecx        # a3

  # Calculate d = -2 * a2 + a1 + a3
  movl %ebx, %edx              # Move a2 into edx
  shll $1, %edx                 # Multiply by 2
  negl %edx                     # Negate to get -2 * a2
  addl %eax, %edx              # Add a1
  addl %ecx, %edx              # Add a3

  # Calculate q = a1 * a3 / (a2 * a2)
  imull %eax, %eax              # a1 * a3
  imull %ebx, %ebx              # a2 * a2
  idivl %ebx                     # q = a1 * a3 / (a2 * a2)

  # Initialize boolean flags in registers
  movb $1, %bl                  # arithmetic_diff
  movb $1, %bh                  # geometric_diff
  movb $1, %r10b                # arithmetic_quot
  movb $1, %r11b                # geometric_quot

  # Check subsequent elements
  movq $3, %r8                 # Start from a4
check_loop:
  cmpq %rcx, %r8                # Compare with size
  jge finish_check              # If i >= size, finish checking

  # Decrement index for previous element
  decq %r8
  movl series(, %r8, 4), %esi   # Load series[i-1]
  incq %r8                       # Increment back for current index
  movl series(, %r8, 4), %edi    # Load series[i]

  # Check differences for arithmetic and geometric
  subl %esi, %edi               # ai - a(i-1)
  cmp %edx, %eax                # Compare with d
  jne check_arithmetic_diff_false
  jmp check_geometric_diff

check_arithmetic_diff_false:
  movb $0, %bl                  # Set arithmetic_diff to false

check_geometric_diff:
  # Perform geometric check
  imull %esi                     # ai / a(i-1)
  cmp %ecx, %edx                # Compare with q
  jne check_geometric_diff_false
  jmp next_iteration

check_geometric_diff_false:
  movb $0, %bh                  # Set geometric_quot to false

next_iteration:
  incq %r8                       # Increment index i
  jmp check_loop                # Repeat for next element

finish_check:
  # Check if any flag is true
  movb $0, seconddegree         # Default to 0
  or %bl, seconddegree          # Check arithmetic_diff
  or %bh, seconddegree          # Check geometric_diff
  or %r10b, seconddegree        # Check arithmetic_quot
  or %r11b, seconddegree        # Check geometric_quot

return_true:
  movb $1, seconddegree         # Set seconddegree to 1 if size < 3
  jmp end                       # Exit

end:

# Print "seconddegree="
movq $1, %rax                # syscall number for sys_write
movq $1, %rdi                # file descriptor (stdout)
lea seconddegree_label(%rip), %rsi  # address of seconddegree_label
movq $13, %rdx               # number of bytes to write
syscall                      # print "seconddegree="

# Print the value of seconddegree
movzbl seconddegree, %eax   # move the value into %eax
movq $seconddegree_buf + 12, %rsi # point to the end of the buffer
movb $0, (%rsi)              # null-terminate the string

convert_seconddegree_to_str:
    dec %rsi                     # move pointer backwards
    movl $10, %ecx               # base 10
    xor %edx, %edx               # clear %edx for division
    div %ecx                     # divide %eax by 10
    addb $'0', %dl               # convert remainder to ASCII
    movb %dl, (%rsi)             # store character in buffer
    test %eax, %eax              # check if quotient is zero
    jnz convert_seconddegree_to_str # loop if quotient is not zero

# Print the string representation of 'seconddegree'
movq $1, %rax                # syscall number for sys_write
movq $1, %rdi                # file descriptor (stdout)
movq %rsi, %rdx              # address of the string
movq $seconddegree_buf + 12, %rcx
sub %rsi, %rcx               # calculate the string length
movq %rsi, %rsi              # address of the string
movq %rcx, %rdx              # number of bytes to write
syscall                      # print seconddegree

# Print a newline
movq $1, %rax                # syscall number for sys_write
movq $1, %rdi                # file descriptor (stdout)
lea newline(%rip), %rsi      # address of newline character
movq $1, %rdx                # number of bytes to write
syscall                      # print newline

