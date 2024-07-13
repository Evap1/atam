.global _start

.section .data
series: .int 2, 6, 18, 54, 162, 486
size: .int 6
seconddegree: .int 0

.section .text
_start:
  # Load the size of the series
  movl size, %ecx              # %ecx holds the size of the series

  # Check if size < 3, if so, set seconddegree to 1 and exit
  cmpl $3, %ecx
  jl return_true

  # Load the first three elements
  movl series, %r13d           # a1
  movl series + 4, %r14d       # a2
  movl series + 8, %r15d       # a3

  # 1. Check if the difference series is arithmetic
  # Calculate d1 = a3 + a1 - 2 * a2
  movl %r15d, %eax             # eax = a3
  addl %r13d, %eax             # eax = a3 + a1
  movl %r14d, %edx             # edx = a2
  shll $1, %edx                # edx = 2 * a2
  subl %edx, %eax              # eax = a3 + a1 - 2 * a2
  movl %eax, %r12d             # r12d = d1

  # Loop to check if the difference series is arithmetic
  movl $2, %ebx                # index = 2
check_arithmetic_diff:
  cmpl %ecx, %ebx              # Compare index with size
  jge return_true              # If index >= size, return true

  # Load series[i+1], series[i], series[i-1]
  movl series(,%ebx,4), %r9d   # r9d = series[i]
  movl series+4(,%ebx,4), %r10d # r10d = series[i+1]
  movl series-4(,%ebx,4), %r11d # r11d = series[i-1]

  # Calculate A(i+1) + A(i-1) - 2 * A(i)
  movl %r10d, %eax             # eax = A(i+1)
  addl %r11d, %eax             # eax = A(i+1) + A(i-1)
  movl %r9d, %edx              # edx = A(i)
  shll $1, %edx                # edx = 2 * A(i)
  subl %edx, %eax              # eax = A(i+1) + A(i-1) - 2 * A(i)

  # Compare with d1
  cmpl %r12d, %eax
  jne check_geometric_diff     # If not equal, check geometric difference

  incl %ebx                    # Increment index
  jmp check_arithmetic_diff

# 2. Check if the difference series is geometric
check_geometric_diff:
  # Calculate q1 = (a3 - a2) / (a2 - a1)
  movl %r15d, %eax             # eax = a3
  subl %r14d, %eax             # eax = a3 - a2
  movl %r14d, %edx             # edx = a2
  subl %r13d, %edx             # edx = a2 - a1
  idivl %edx                   # eax = q1

  movl %eax, %r12d             # r12d = q1

  # Loop to check if the difference series is geometric
  movl $2, %ebx                # index = 2
check_geometric_diff_loop:
  cmpl %ecx, %ebx              # Compare index with size
  jge return_true              # If index >= size, return true

  # Load series[i+1], series[i], series[i-1]
  movl series(,%ebx,4), %r9d   # r9d = series[i]
  movl series+4(,%ebx,4), %r10d # r10d = series[i+1]
  movl series-4(,%ebx,4), %r11d # r11d = series[i-1]

  # Calculate (A(i+1) - A(i)) / (A(i) - A(i-1))
  movl %r10d, %eax             # eax = A(i+1)
  subl %r9d, %eax              # eax = A(i+1) - A(i)
  movl %r9d, %edx              # edx = A(i)
  subl %r11d, %edx             # edx = A(i) - A(i-1)
  idivl %edx                   # eax = (A(i+1) - A(i)) / (A(i) - A(i-1))

  # Compare with q1
  cmpl %r12d, %eax
  jne check_arithmetic_quot    # If not equal, check arithmetic quotient

  incl %ebx                    # Increment index
  jmp check_geometric_diff_loop

# 3. Check if the quotient series is arithmetic
check_arithmetic_quot:
  # Calculate d2 = a3 / a2 - a2 / a1
  movl %r15d, %eax             # eax = a3
  idivl %r14d                  # eax = a3 / a2
  movl %eax, %r12d             # r12d = a3 / a2

  movl %r14d, %eax             # eax = a2
  idivl %r13d                  # eax = a2 / a1
  subl %eax, %r12d             # r12d = a3 / a2 - a2 / a1

  # Loop to check if the quotient series is arithmetic
  movl $2, %ebx                # index = 2
check_arithmetic_quot_loop:
  cmpl %ecx, %ebx              # Compare index with size
  jge return_true              # If index >= size, return true

  # Load series[i+1], series[i], series[i-1]
  movl series(,%ebx,4), %r9d   # r9d = series[i]
  movl series+4(,%ebx,4), %r10d # r10d = series[i+1]
  movl series-4(,%ebx,4), %r11d # r11d = series[i-1]

  # Calculate A(i+1) / A(i) - A(i) / A(i-1)
  movl %r10d, %eax             # eax = A(i+1)
  idivl %r9d                   # eax = A(i+1) / A(i)
  movl %eax, %r8d              # r8d = A(i+1) / A(i)

  movl %r9d, %eax              # eax = A(i)
  idivl %r11d                  # eax = A(i) / A(i-1)
  subl %eax, %r8d              # r8d = A(i+1) / A(i) - A(i) / A(i-1)

  # Compare with d2
  cmpl %r12d, %r8d
  jne check_geometric_quot     # If not equal, check geometric quotient

  incl %ebx                    # Increment index
  jmp check_arithmetic_quot_loop

# 4. Check if the quotient series is geometric
check_geometric_quot:
  # Calculate q2 = (a3 * a1) / (a2 * a2)
  movl %r15d, %eax             # eax = a3
  imull %r13d, %eax            # eax = a3 * a1
  movl %r14d, %edx             # edx = a2
  imull %edx                   # edx:eax = a3 * a1
  idivl %edx                   # eax = (a3 * a1) / (a2 * a2)

  movl %eax, %r12d             # r12d = q2

  # Loop to check if the quotient series is geometric
  movl $2, %ebx                # index = 2
check_geometric_quot_loop:
  cmpl %ecx, %ebx              # Compare index with size
  jge return_true              # If index >= size, return true

  # Load series[i+1], series[i], series[i-1]
  movl series(,%ebx,4), %r9d   # r9d = series[i]
  movl series+4(,%ebx,4), %r10d # r10d = series[i+1]
  movl series-4(,%ebx,4), %r11d # r11d = series[i-1]

  # Calculate (A(i+1) * A(i-1)) / (A(i) * A(i))
  movl %r10d, %eax             # eax = A(i+1)
  imull %r11d, %eax            # eax = A(i+1) * A(i-1)
  movl %r9d, %edx              # edx = A(i)
  imull %edx                   # edx:eax = A(i+1) * A(i-1)
  idivl %edx                   # eax = (A(i+1) * A(i-1)) / (A(i) * A(i))

  # Compare with q2
  cmpl %r12d, %eax
  jne end                      # If not equal, go to end

  incl %ebx                    # Increment index
  jmp check_geometric_quot_loop

return_true:
  movl $1, seconddegree

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
