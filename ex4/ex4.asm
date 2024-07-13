.global _start

.section .text

_start:
    movq $0, %r9               #  result = 0
    movq $0, %r8               #  index i = 0

check_nodes_HW1:
    cmpq $3, %r8               
    jge end_check_HW1              # if i >= 3, exit loop

    movq nodes(, %r8, 8), %r10  # load currentNode = nodes[i]

    movq 0(%r10), %r12          # load prev pointer
    cmpq $0, %r12               # check if prev is nullptr
    je right_check_HW1          # if so, skip left

    movq 0(%r12), %r13          # load prev of prev pointer
    cmpq $0, %r13               # check if prev of prev is nullptr
    je right_check_HW1          # if yes, go left

decide_tendency_left_HW1:
    movl 8(%r12), %eax          # load prev->data
    movl 8(%r13), %ebx          # load prev of prev->data
    cmp %eax, %ebx
    jg left_goes_down_HW1
    jl left_goes_up_HW1
    movq 0(%r13), %r13          # load prev of prev pointer
    cmpq $0, %r13               # check if prev of prev is nullptr
    je right_check_HW1              # if yes, go left
    movq 0(%r12), %r12
    jmp decide_tendency_left_HW1

left_goes_down_HW1:
    movq 0(%r13), %r13          # move prev of prev to prev
    cmpq $0, %r13               # check if prev is nullptr
    je right_check_HW1          # if yes, go left
    movq 0(%r12), %r12          # move prev to prev of prev
    movl 8(%r12), %eax          # load prev->data
    movl 8(%r13), %ebx          # load prev of prev->data
    cmp %eax, %ebx
    jl not_monotonic_HW1        # if the data is not decreasing, it's not monotonic
    jmp left_goes_down_HW1

left_goes_up_HW1:
    movq 0(%r13), %r13          # move prev of prev to prev
    cmpq $0, %r13               # check if prev is nullptr
    je right_check_HW1          # if yes, go left
    movq 0(%r12), %r12          # move prev to prev of prev
    movl 8(%r12), %eax          # load prev->data
    movl 8(%r13), %ebx          # load prev of prev->data
    cmp %eax, %ebx
    jg not_monotonic_HW1        # if the data is not increasing, it's not monotonic
    jmp left_goes_up_HW1


right_check_HW1:
    movq 12(%r10), %r12         # load next pointer
    cmpq $0, %r12               # check if next is nullptr
    je increment_result_HW1     # If yes go right

    movq 12(%r12), %r13         # load next of next pointer
    cmpq $0, %r13               # check if next of next is nullptr
    je increment_result_HW1     # If yes go right

decide_tendency_right:
    movl 8(%r12), %eax          # load next->data
    movl 8(%r13), %ebx          # load next of next->data
    cmp %eax, %ebx
    jg right_goes_down_HW1
    jl right_goes_up_HW1
    movq 12(%r13), %r13         # load next of next pointer
    cmpq $0, %r13               # check if next of next is nullptr
    je increment_result_HW1     # if yes go right
    movq 12(%r12), %r12
    jmp decide_tendency_right

right_goes_down_HW1:
    movq 12(%r13), %r13         # move next of next to next
    cmpq $0, %r13               # check if next is nullptr
    je increment_result_HW1     # If yes go right
    movq 12(%r12), %r12         # move next to next of next
    movl 8(%r12), %eax          # load next->data
    movl 8(%r13), %ebx          # load next of next->data
    cmp %eax, %ebx
    jl not_monotonic_HW1        # if the data is not decreasing, it's not monotonic
    jmp right_goes_down_HW1

right_goes_up_HW1:
    movq 12(%r13), %r13         # move next of next to next
    cmpq $0, %r13               # check if next is nullptr
    je increment_result_HW1     # if so, skip right
    movq 12(%r12), %r12         # move next to next of next
    movl 8(%r12), %eax          # load next->data
    movl 8(%r13), %ebx          # load next of next->data
    cmp %eax, %ebx
    jg not_monotonic_HW1        # if the data is not increasing, it's not monotonic
    jmp right_goes_up_HW1

increment_result_HW1:
    incq %r9                    # increment result if monotonic
    incq %r8                    # increment index i
    jmp check_nodes_HW1             

not_monotonic_HW1:
    incq %r8                    # increment index i
    jmp check_nodes_HW1         # jump to next node out of the 3

end_check_HW1:
    movq %r9, result          

end:
