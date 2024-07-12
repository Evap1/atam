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

    # Check tendency
    cmp $0, %r11
    je continue_check           # If tendency is undecided, continue checking
    cmp $1, %r11
    jl check_down               # If tendency is down, check that the values are decreasing

check_up:
    cmp %ebx, %ecx
    jge not_monotonic
    jmp continue_check

check_down:
    cmp %ebx, %ecx
    jle not_monotonic
    jmp continue_check

continue_check:
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
    jg set_right_down            # If next > next of next, set tendency to down
    jl set_right_up              # If next < next of next, set tendency to up
    jmp check_next_right         # If equal, check next right

set_right_down:
    movq $-1, %r11               # Set tendency to down
    jmp check_next_right

set_right_up:
    movq $1, %r11                # Set tendency to up

check_next_right:
    movq 12(%r13), %r14          # Load next of next of next pointer
    cmpq $0, %r14               # Check if next of next of next is nullptr
    je increment_result          # If so, increment result and skip checks

    movl 8(%r14), %ecx          # Load next of next of next->data

    # Check tendency
    cmp $0, %r11
    je continue_check_right      # If tendency is undecided, continue checking
    cmp $1, %r11
    jl check_right_down          # If tendency is down, check that the values are decreasing

check_right_up:
    cmp %ebx, %ecx
    jge not_monotonic
    jmp continue_check_right

check_right_down:
    cmp %ebx, %ecx
    jle not_monotonic
    jmp continue_check_right

continue_check_right:
    movq %r13, %r12             # Move next of next to next
    movq %r14, %r13             # Move next of next of next to next of next
    jmp inner_right_check

increment_result:
    incq %r9                     # Increment result if mono
