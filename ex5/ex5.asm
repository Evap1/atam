.global _start

.section .text

_start:
  movq $0, %r8                 # Initialize index i to 0
  movq size, %rcx              # Load size of series

  cmpq $3, %rcx                # Check if size < 3
  jle return_true              # If so, return 1

# Load first three elements
leaq series(%rip), %r10
movl 0(%r10), %r13d        # a1
movl 4(%r10), %r14d        # a2
movl 8(%r10), %r15d        # a3

# Calculate q = a1 * a3 / (a2 * a2)
imulq %r15, %r13             # a1 * a3
movq %r14, %rdi              # Load a2 for multiplication
imulq %rdi                   # a2 * a2
xor %rdx, %rdx               # Clear rdx for division
divq %rdi                     # q = a1 * a3 / (a2 * a2)
movq %rax, %rbx              # Store result in rbx (q)

# Calculate d = -2 * a2 + a1 + a3
movq %r14, %rdx              # Move a2 into rdx
shlq $1, %rdx                 # Multiply by 2
negq %rdx                     # Negate to get -2 * a2
addq %r13, %rdx              # Add a1
addq %r15, %rdx              # Add a3
movq %rdx, %rax              # Store result in rax (d)


  # Initialize boolean flags in registers
  movb $1, %r9b                # arithmetic_diff
  movb $1, %r10b               # geometric_diff
  movb $1, %r11b               # arithmetic_quot
  movb $1, %r12b               # geometric_quot

  # Check subsequent elements
  movq $3, %r8                 # Start from a4
check_loop:
  cmpq %rcx, %r8                # Compare with size
  jge finish_check              # If i >= size, finish checking

  # Decrement index for previous element
  decq %r8
  movq series(, %r8, 8), %rsi   # Load series[i-1]
  incq %r8                       # Increment back for current index
  movq series(, %r8, 8), %rdi    # Load series[i]

  # Check differences for arithmetic and geometric
  subq %rsi, %rdi               # ai - a(i-1)
  cmp %rdx, %rax                # Compare with d
  jne check_arithmetic_diff_false
  jmp check_geometric_diff

check_arithmetic_diff_false:
  movb $0, %r9b                  # Set arithmetic_diff to false

check_geometric_diff:
  # Perform geometric check
  movq %rsi, %rdi                # ai / a(i-1)
  imulq %rsi                     # ai / a(i-1)
  cmp %rbx, %rdx                # Compare with q
  jne check_geometric_diff_false
  jmp next_iteration

check_geometric_diff_false:
  movb $0, %r10b                 # Set geometric_quot to false

next_iteration:
  incq %r8                       # Increment index i
  jmp check_loop                # Repeat for next element

finish_check:
  # Check if any flag is true
  movb $0, seconddegree         # Default to 0
  or %r9b, seconddegree         # Check arithmetic_diff
  or %r10b, seconddegree        # Check geometric_diff
  or %r11b, seconddegree        # Check arithmetic_quot
  or %r12b, seconddegree        # Check geometric_quot

return_true:
  movb $1, seconddegree         # Set seconddegree to 1 if size < 3
  jmp end                       # Exit

end:
  # Print "seconddegree="
  movq $1, %rax                # syscall number for sys_write
  movq $1, %rdi                # file descriptor (stdout)
  lea seconddegree_label(%rip), %rsi  # address of seconddegree_label
  movq $13, %rdx               # number of bytes to write (length of "seconddegree=")
  syscall                      # make the syscall to print "seconddegree="

  # Convert the value of 'seconddegree' to a string
  movzbl seconddegree(%rip), %rax  # move the value of seconddegree into %rax and zero-extend
  movq $seconddegree_buf + 12, %rsi # point to the end of the buffer
  movb $0, (%rsi)              # null-terminate the string

convert_seconddegree_to_str:
  dec %rsi                     # move pointer backwards
  movq $10, %rcx               # base 10
  xor %rdx, %rdx               # clear %rdx for division
  divq %rcx                     # divide %rax by 10
  addb $'0', %dl               # convert remainder to ASCII
  movb %dl, (%rsi)             # store character in buffer
  test %rax, %rax              # check if quotient is zero
  jnz convert_seconddegree_to_str # loop if quotient is not zero

  # Print the string representation of 'seconddegree'
  movq $1, %rax                # syscall number for sys_write
  movq $1, %rdi                # file descriptor (stdout)
  movq %rsi, %rdx              # length of the string
  movq $seconddegree_buf + 12, %rcx
  sub %rsi, %rcx               # calculate the string length
  movq %rsi, %rsi              # address of the string
  movq %rcx, %rdx              # number of bytes to write
  syscall                      # make the syscall to print seconddegree

  # Print a newline
  movq $1, %rax                # syscall number for sys_write
  movq $1, %rdi                # file descriptor (stdout)
  lea newline(%rip), %rsi      # address of newline character
  movq $1, %rdx                # number of bytes to write (1 byte for newline)
  syscall                      # make the syscall to print newline

  # Exit the program
  movq $60, %rax               # syscall number for sys_exit
  xor %rdi, %rdi               # exit status (0 for success)
  syscall                      # make the syscall to exit the program

.section .rodata
seconddegree_label:
  .asciz "seconddegree="
newline:
  .byte 10  # ASCII code for newline ('\n')

.section .bss
  .lcomm seconddegree_buf, 13  # buffer to hold string representation of seconddegree
