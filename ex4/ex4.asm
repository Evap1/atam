.global _start
_start:
    movq $0, %r9               # Initialize result to 0
    movq $0, %r8               # Initialize index i to 0

check_nodes:
    cmpq $3, %r8               # Compare i with 3
    jge end_check              # If i >= 3, exit loop

    movq nodes(, %r8, 8), %r10  # Load currentNode = nodes[i]
    
    # Check if there are at least 3 elements from the left
    movq 0(%r10), %r12          # Load prev pointer
    cmpq $0, %r12               # Check if prev is nullptr
    je right_check              # If so, skip left

    movq 0(%r12), %r13          # Load prev of prev pointer
    cmpq $0, %r13               # Check if prev of prev is nullptr
    je right_check              # If so, skip left

    movq 0(%r13), %r14          # Load prev of prev of prev pointer
inner_left_check:
    cmpq $0, %r14               # Check if prev of prev of prev is nullptr
    je right_check              # If so, skip left
  
    movl 8(%r12), %eax          # Load prev->data
    movl 8(%r13), %ebx          # Load prev of prev->data
    movl 8(%r14), %ecx          # Load prev of prev of prev->data

    # Check for maxima or minima conditions
    cmp %eax, %ebx              # Compare prev->data with prev of prev->data
    jg check_ecx_ebx            # If prev > prev of prev, check if prev of prev > prev of prev of prev
    jl check_ebx_ecx            # If prev < prev of prev, check if prev of prev < prev of prev of prev
    je equal_label_left         # If equal, continue checking

check_ebx_ecx:
    cmp %ebx, %ecx              # Compare prev of prev->data with prev of prev of prev->data
    jl not_monotonic            # If prev of prev < prev of prev of prev, it's not monotonic
    jge equal_label_left

check_ecx_ebx:
    cmp %ebx, %ecx              # Compare prev of prev->data with prev of prev of prev->data
    jg not_monotonic            # If prev of prev > prev of prev of prev, it's not monotonic

    # Move to the next previous node for continued checking
equal_label_left:
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

    movq 12(%r13), %r14          # Load next of next of next pointer
inner_right_check:
    cmpq $0, %r14               # Check if next of next of next is nullptr
    je increment_result          # If so, increment result and skip checks

    movl 8(%r12), %eax          # Load next->data
    movl 8(%r13), %ebx          # Load next of next->data
    movl 8(%r14), %ecx          # Load next of next of next->data

    # Check for maxima or minima conditions for the right side
    cmp %eax, %ebx              # Compare next->data with next of next->data
    jg check_ecx_right          # If next > next of next, check if next of next > next of next of next
    jl check_ebx_ecx_right      # If next < next of next, check if next of next < next of next of next
    je equal_label_right         # If equal, continue checking

check_ebx_ecx_right:
    cmp %ebx, %ecx              # Compare next of next->data with next of next of next->data
    jl not_monotonic            # If next of next < next of next of next, it's not monotonic
    jge equal_label_right

check_ecx_right:
    cmp %eax, %ecx              # Compare next->data with next of next of next->data
    jl not_monotonic            # If next < next of next of next, it's not monotonic

    # Move to the next next node for continued checking
equal_label_right:
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
