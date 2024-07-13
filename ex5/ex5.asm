.global _start


.section .text
_start:
  movl size, %ecx              
  subl $1, %ecx

  # check if size -1 < 3-1, if so, set seconddegree to 1 and exit
  cmpl $2, %ecx
  jl update_seconddegree_HW1

  # load the first three elements
  movl series, %r13d           # a1
  movl series + 4, %r14d       # a2
  movl series + 8, %r15d       # a3

  # 1. check if the difference series is arithmetic
  # calculate d1 = a3 + a1 - 2 * a2
  movl %r15d, %eax             # eax = a3
  addl %r13d, %eax             # eax = a3 + a1
  movl %r14d, %edx             # edx = a2
  shll $1, %edx                # edx = 2 * a2
  subl %edx, %eax              # eax = a3 + a1 - 2 * a2
  movl %eax, %r12d             # r12d = d1

  # loop to check if the difference series is arithmetic
  movl $2, %ebx                # index = 2
check_arithmetic_diff_HW1:
  cmpl %ecx, %ebx              # compare index with size
  jge update_seconddegree_HW1              # If index >= size, return true

  movl series(,%ebx,4), %r9d   # r9d = series[i]
  movl series+4(,%ebx,4), %r10d # r10d = series[i+1]
  movl series-4(,%ebx,4), %r11d # r11d = series[i-1]

  # calculate A(i+1) + A(i-1) - 2 * A(i)
  movl %r10d, %eax             # eax = A(i+1)
  addl %r11d, %eax             # eax = A(i+1) + A(i-1)
  movl %r9d, %edx              # edx = A(i)
  shll $1, %edx                # edx = 2 * A(i)
  subl %edx, %eax              # eax = A(i+1) + A(i-1) - 2 * A(i)

  # compare with d1
  cmpl %r12d, %eax
  jne check_geometric_diff_HW1     # if not equal, check geometric difference

  incl %ebx                   
  jmp check_arithmetic_diff_HW1

# 2. check if the difference series is geometric
check_geometric_diff_HW1:
  # Calculate q1 = (a3 - a2) / (a2 - a1)
  movl %r15d, %eax             # eax = a3
  subl %r14d, %eax             # eax = a3 - a2 eax is the divedend
  cdq                          # sign extansion
  movl %r14d, %r9d             # r9d = a2
  subl %r13d, %r9d             # r9d = a2 - a1 r9d is the devisor. it is not possible to devide by edx!
  idivl %r9d                   # eax = q1

  movl %eax, %r12d             # r12d = q1

  # loop to check if the difference series is geometric
  movl $2, %ebx                
check_geometric_diff_loop_HW1:
  cmpl %ecx, %ebx              # compare index with size
  jge update_seconddegree_HW1              # if index >= size, return true

  movl series(,%ebx,4), %r9d   # r9d = series[i]
  movl series+4(,%ebx,4), %r10d # r10d = series[i+1]
  movl series-4(,%ebx,4), %r11d # r11d = series[i-1]

  # calculate (A(i+1) - A(i)) / (A(i) - A(i-1))
  movl %r10d, %eax             # eax = A(i+1)
  subl %r9d, %eax              # eax = A(i+1) - A(i) eax is the divedend
  cdq                          # sign extansion
  #movl %r9d, %edx              # edx = A(i)
  subl %r11d, %r9d             # edx = A(i) - A(i-1) r9d is the devisor. it is not possible to devide by edx!
  idivl %r9d                   # eax = (A(i+1) - A(i)) / (A(i) - A(i-1))

  # compare with q1
  cmpl %r12d, %eax
  jne check_arithmetic_quot_HW1    # if not equal, check arithmetic quotient

  incl %ebx                   
  jmp check_geometric_diff_loop_HW1

# 3. check if the quotient series is arithmetic
check_arithmetic_quot_HW1:
  # Calculate d2 = a3 / a2 - a2 / a1
  movl %r15d, %eax             # eax = a3 eax is the divedend.
  cdq                          # sign extansion
  idivl %r14d                  # eax = a3 / a2
  movl %eax, %r12d             # r12d = a3 / a2

  movl %r14d, %eax             # eax = a2 eax is the divedend.
  cdq                          # sign extansion
  idivl %r13d                  # eax = a2 / a1
  subl %eax, %r12d             # r12d = a3 / a2 - a2 / a1

  # check if the quotient series is arithmetic
  movl $2, %ebx                # index = 2
check_arithmetic_quot_loop_HW1:
  cmpl %ecx, %ebx              # compare index with size
  jge update_seconddegree_HW1              # if index >= size, return true

  movl series(,%ebx,4), %r9d   # r9d = series[i]
  movl series+4(,%ebx,4), %r10d # r10d = series[i+1]
  movl series-4(,%ebx,4), %r11d # r11d = series[i-1]

  # calculate A(i+1) / A(i) - A(i) / A(i-1)
  movl %r10d, %eax             # eax = A(i+1) eax is the divedend.
  cdq                          # sign extansion
  idivl %r9d                   # eax = A(i+1) / A(i)
  movl %eax, %r8d              # r8d = A(i+1) / A(i)

  movl %r9d, %eax              # eax = A(i) eax is the divedend.
  cdq                          # sign extansion
  idivl %r11d                  # eax = A(i) / A(i-1)
  subl %eax, %r8d              # r8d = A(i+1) / A(i) - A(i) / A(i-1)

  # Compare with d2
  cmpl %r12d, %r8d
  jne check_geometric_quot_HW1     # if not equal, check geometric quotient

  incl %ebx                   
  jmp check_arithmetic_quot_loop_HW1

# 4. check if the quotient series is geometric
check_geometric_quot_HW1:
  # Calculate q2 = (a3 * a1) / (a2 * a2)
  movslq %r12d, %r12
  movslq %r13d, %r13
  movslq %r14d, %r14
  movslq %r15d, %r15
  movq %r14, %rax             # rax = a2
  imulq %r14, %rax            # rax = a2 * a2
  movq %rax, %r9
  movq %r15, %rax             # rax = a3
  imulq %r13, %rax            # rax = a3 * a1
  cqo
  idivq %r9                   # rax = (a3 * a1) / (a2 * a2)
  movq %rax, %r12             # r12 = q2

  # check if the quotient series is geometric
  movl $2, %ebx                
check_geometric_quot_loop_HW1:
  cmpl %ecx, %ebx              # compare index with size
  jge update_seconddegree_HW1              # if index >= size, return true

  movl series(,%ebx,4), %r9d   # r9d = series[i]
  movl series+4(,%ebx,4), %r10d # r10d = series[i+1]
  movl series-4(,%ebx,4), %r11d # r11d = series[i-1]

  # calculate (A(i+1) * A(i-1)) / (A(i) * A(i))
  movslq %r9d, %r9
  movslq %r10d, %r10
  movslq %r11d, %r11
  movq %r9, %rax              # rax = A(i)
  imulq %r9, %rax             # rax = A(i) * A(i)
  movq %rax, %r9
  movq %r10, %rax             # rax = A(i+1)
  imulq %r11, %rax            # rax = A(i+1) * A(i-1)
  cqo
  idivq %r9                   # rax = (A(i+1) * A(i-1)) / (A(i) * A(i)) r9d is the devisor. it is not possible to devide by edx!

  # Compare with q2
  cmpq %r12, %rax
  jne end                      # if not equal, go to end

  incl %ebx                   
  jmp check_geometric_quot_loop_HW1

update_seconddegree_HW1:
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
