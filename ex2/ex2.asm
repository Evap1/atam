.global _start

.section .text
_start:
    movb $3, type           
    movq size, %r9         
    leaq data, %r10         
    movq size, %r13      
    shrq $3, %r13           # divide size by 8 (size/8)
    andq $7, %r9             # check if size is divisible by 8
    testq %r9, %r9          
    jne update_type1_HW1     # if not divisible jump to check simple condition

loop_zeros_HW1:
    movq $0, %r11
    movq 0(%r10, %r11, 8), %r12 
    testq %r12, %r12         # check if quad value is 0
    je update_type1_HW1
    addq $1, %r11           
    cmpq %r11, %r13        
    jb loop_zeros_HW1        # loop if index < size

    cmpb $3, type            
    je end                


update_type1_HW1:
    movb $1, type            #  type = 1 for simple set check
    movq size, %r9        
    subq $1 , %r9 
    movb (%r10, %r9, 1), %al   
    cmpb $0, %al             # check if null terminator
    jne update_type4_HW1
    subq $1 , %r9


loop_simple_HW1:
    movq $0, %r11            #index = 0

check_simple_char_HW1:
    cmpq %r11, %r9          
    je end_simple_check_HW1   # exit loop if index = size-1
 
    movb (%r10, %r11, 1), %al   
    cmpb $0, %al              # check if null terminator
    je update_type4_HW1

    # Check if character is punctuation (',', '.', '?', '!', ' ')
    cmpb $33, %al    # '!' is 33
    je simple_char_HW1
    cmpb $63, %al    # '?' is 63
    je simple_char_HW1
    cmpb $46, %al    # '.' is 46
    je simple_char_HW1
    cmpb $44, %al    # ',' is 44
    je simple_char_HW1
    cmpb $32, %al    # ' ' is 32
    je simple_char_HW1

    # check if character is a digit (0-9)
    cmpb $'0', %al     		# if ‘0’ > char then its not simple.
    jb not_simple_HW1
    cmpb $'9', %al
    jbe simple_char_HW1		# if ‘9’ > char then its simple. ( 0 < char < 9)

    # check if character is a letter (A-Z or a-z)
    cmpb $'A', %al			# if ‘A’ > char then its not simple.
    jb not_simple_HW1
    cmpb $'Z', %al			# if ‘Z’ > char then its simple. ( ‘A’ < char < ‘Z’)
    jbe simple_char_HW1
    cmpb $'a', %al			# if ‘a’ > char then its not simple.
    jb not_simple_HW1
    cmpb $'z', %al			# if ‘a’ > char then its simple. ( ‘a’ < char < ‘a’)
    jbe simple_char_HW1


not_simple_HW1:
    movb $2, type            
    jmp end_simple_check_HW1    

simple_char_HW1:
    incq %r11               
    jmp check_simple_char_HW1    # next character

end_simple_check_HW1:
    cmpb $1, type            
    je end                   


loop_science_HW1:
    movq $0, %r11            # reset index to 0

check_science_char_HW1:
    cmpq %r11, %r9          
    je end                  # exit if index = size-1

    movb (%r10, %r11, 1), %al   

    cmpb $32, %al
    jb not_science_HW1           # check if character < 32
    cmpb $126, %al
    jg not_science_HW1           # check if character > 126

    incq %r11               
    jmp check_science_char_HW1   # if index < size

not_science_HW1:
    movb $4, type            

update_type4_HW1:
    movb $4, type           
end:
