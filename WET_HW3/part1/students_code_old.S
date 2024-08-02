.global count_above

.section .text
count_above:
    # Prologue
    push %rbp
    mov %rsp, %rbp

    # Arguments
    mov %dil, %cl            # char separator (lower 8 bits of rdi)
    mov %rsi, %r8            # long limit (rsi)

    # Call get_path to get the file path
    call get_path
    mov %rax, %rdi           # Move the returned pointer from rax to rdi (pathname argument)

    # Open the file with read and write permissions
    mov $2, %rax             # syscall: open
    mov $2, %rsi             # flags: O_RDWR (read and write)
    mov $0, %rdx             # mode: 0 (not used)
    syscall
    mov %rax, %rbx           # Move the file descriptor from rax to rbx

    # Initialize registers
    mov %rdi, %r10           # start_ptr: Pointer to the start of the file
    mov %r10, %r11           # moving_ptr: Pointer to the current position in the file
    xor %r9d, %r9d           # counter: Initialize to 0

    # Allocate stack space for 20 bytes
    sub $20, %rsp            # Adjust stack pointer for local buffer
    mov %rsp, %r12           # r12 points to the local buffer

read_loop:
    # Read one byte
    mov $0, %rax             # syscall: read
    mov %rbx, %rdi           # file descriptor
    mov %r11, %rsi           # address for reading
    mov $1, %rdx             # count: read 1 byte
    syscall
    test %rax, %rax          # Check if end of file
    jz done_reading          # If zero, end of file

    # Compare byte with separator
    movb (%r11), %al         # Load byte from file to AL
    cmp %cl, %al
    je separator_found

    # Store byte in local buffer
    movb %al, (%r12)         # Store byte from AL to buffer
    add $1, %r12             # Move buffer pointer forward
    add $1, %r11             # Move moving_ptr forward
    jmp read_loop

separator_found:
    # Null-terminate the segment at the current position
    movb $0, (%r12)         # Null-terminate the segment (writing zero to buffer)

    # Call atam_atol
    lea (%rsp), %rdi        # Pass the address of the buffer (stack pointer)
    call atam_atol
    mov %rax, %rsi          # Move the returned value to rsi

    # Compare with limit
    cmp %r8, %rsi
    jle move_start_ptr      # If less than or equal, do not increment the counter

    # Increment counter
    inc %r9d

move_start_ptr:
    # Reset buffer pointer
    mov %rsp, %r12          # Reset buffer pointer to start of buffer

    # Update start_ptr to the current position
    mov %r11, %r10          # Update start_ptr to the new position
    jmp read_loop


done_reading:
    # Restore stack pointer and close the file
    add $20, %rsp            # Restore the stack pointer
    mov %rbx, %rdi          # Move the file descriptor to rdi
    mov $3, %rax            # syscall: close
    syscall

    # Move counter to return register
    mov %r9d, %eax

    # Epilogue
    pop %rbp
    ret
