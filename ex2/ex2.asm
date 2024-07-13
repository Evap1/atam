.global _start

.section .text
_start:
    movb $3, type            # Initialize type to 3
    movq size, %r9           # Load size into r9 V		
    leaq data, %r10          # Load address of data into r10 (movq loads the first quad in 
    movq size, %r13          # Load size into r13 V
    shrq $3, %r13           # Divide size by 8 (size/8)
    andq $7, %r9             # r9 = r9 & 7 (check if size is divisible by 8)
    testq %r9, %r9           # Update ZF based on r9
    jne update_type1_HW1            # if not divisible jump to check simple condition

loop_zeros_HW1:
    movq $0, %r11
    movq 0(%r10, %r11, 8), %r12 # Load quad from data using base=data and iterator=R11
    testq %r12, %r12         # Check if quad value is 0
    je update_type1_HW1
    addq $8, %r11            # I++
    cmpq %r11, %r13          # Compare r11 with r13
    jb loop_zeros_HW1            # Loop if index < size

    cmpb $3, type            # Compare type with 3
    je end                   # Exit if type is 3


update_type1_HW1:
    movb $1, type            # Initialize type to 1 for simple set check
    movq size, %r9           # reset size value into r9 
    subq $1 , %r9 
    movb (%r10, %r9, 1), %al   # Load byte from data
    cmpb $0, %al             # Check if null terminator
    jne update_type4_HW1
    subq $1 , %r9


loop_simple_HW1:
    movq $0, %r11            # Reset index to 0

check_simple_char_HW1:
    cmpq %r11, %r9          # Compare index with size to ensure bounds
    je end_simple_check_HW1     # Exit loop if index = size-1
 
    movb (%r10, %r11, 1), %al   # Load byte from data
    cmpb $0, %al       # Check if null terminator
    je update_type4_HW1

    # Check if character is punctuation (',', '.', '?', '!', ' ')
    cmpb $33, %al    # ASCII value of '!' is 33
    je simple_char_HW1
    cmpb $63, %al    # ASCII value of '?' is 63
    je simple_char_HW1
    cmpb $46, %al    # ASCII value of '.' is 46
    je simple_char_HW1
    cmpb $44, %al    # ASCII value of ',' is 44
    je simple_char_HW1
    cmpb $32, %al    # ASCII value of space ' ' is 32
    je simple_char_HW1

    # Check if character is a digit (0-9)
    cmpb $'0', %al     		# if ‘0’ > char then its not simple.
    jb not_simple_HW1
    cmpb $'9', %al
    jbe simple_char_HW1		# if ‘9’ > char then its simple. ( 0 < char < 9)

    # Check if character is a letter (A-Z or a-z)
    cmpb $'A', %al			# if ‘A’ > char then its not simple.
    jb not_simple_HW1
    cmpb $'Z', %al			# if ‘Z’ > char then its simple. ( ‘A’ < char < ‘Z’)
    jbe simple_char_HW1
    cmpb $'a', %al			# if ‘a’ > char then its not simple.
    jb not_simple_HW1
    cmpb $'z', %al			# if ‘a’ > char then its simple. ( ‘a’ < char < ‘a’)
    jbe simple_char_HW1


not_simple_HW1:
    movb $2, type            # Set type to 2
    jmp end_simple_check_HW1     # Jump to end check

simple_char_HW1:
    incq %r11                # Increment index
    jmp check_simple_char_HW1    # Loop to check next character

end_simple_check_HW1:
    cmpb $1, type            # Check if type is 1
    je end                   # Exit if type is 1


loop_science_HW1:
    movq $0, %r11            # Reset index to 0

check_science_char_HW1:
    cmpq %r11, %r9          # Compare index with size to ensure bounds
    je end                  # Exit loop if index = size-1

    movb (%r10, %r11, 1), %al   # Load byte from data

    cmpb $32, %al
    jb not_science_HW1           # Check if character < 32
    cmpb $126, %al
    jg not_science_HW1           # Check if character > 126

    incq %r11                # Increment index
    jmp check_science_char_HW1   # Loop if index < size

not_science_HW1:
    movb $4, type            # Set type to 4

update_type4_HW1:
    movb $4, type            # Set type to 4
