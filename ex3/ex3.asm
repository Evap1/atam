.global _start

.section .text
_start:
    movq $0, %r8 		# vertex_counter = 0
    movq $0, %r9 		# leaf_counter = 0
    leaq root, %r10 	# node_level1 = root_array[0]
    movb $0 , rich      

    # start traversal from root
    movq (%r10), %r11           # load the first son of the root

level1:
    cmpq $0, %r11               # if current son is 0, break level 1 loop
    je level1_end
    movq (%r11), %r12           # load the first son of level 1 node
    cmpq $0, %r12               # check if level 1 node is a leaf
    je level1_leaf

level2:
    cmpq $0, %r12               
    je level2_end
    movq (%r12), %r13          
    cmpq $0, %r13              
    je level2_leaf

level3:
    cmpq $0, %r13             
    je level3_end
    movq (%r13), %r14   
    cmpq $0, %r14        
    je level3_leaf

level4:
    cmpq $0, %r14        
    je level4_end
    movq (%r14), %r15       
    cmpq $0, %r15           
    je level4_leaf

level5:
    cmpq $0, %r15              
    je level5_end
    movq (%r15), %rax          
    cmpq $0, %rax            
    je level5_leaf

level6:
    cmpq $0, %rax            
    je level6_end
    incq %r8                   
    movq 8(%rax), %rax             
    jmp level6
level6_end:
    cmpq $0, %r15
    jne not_leaf5
    incq %r9                    # increment leaf_counter if level 5 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level5_continue
level5_leaf:
    incq %r9                    # increment leaf_counter if level 5 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level5_continue
not_leaf5:
    incq %r8                    # increment v_counter for level 5 node
level5_continue:
    addq $8, %r14
    movq (%r14), %r15               # move to the next son
    #movq 8(%r15), %r15               # move to the next son in level 5 array
    jmp level5
level5_end:
    cmpq $0, %r14
    jne not_leaf4
    incq %r9                    # increment leaf_counter if level 4 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level4_continue
level4_leaf:
    incq %r9                    # increment leaf_counter if level 4 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level4_continue
not_leaf4:
    incq %r8                    # increment v_counter for level 4 node
level4_continue:
    addq $8, %r13
    movq (%r13), %r14               # move to the next son
    #movq 8(%r14), %r14               # move to the next son in level 4 array
    jmp level4
level4_end:
    cmpq $0, %r13
    jne not_leaf3
    incq %r9                    # increment leaf_counter if level 3 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level3_continue
level3_leaf:
    incq %r9                    # increment leaf_counter if level 3 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level3_continue
not_leaf3:
    incq %r8                    # increment v_counter for level 3 node
level3_continue:
    addq $8, %r12
    movq (%r12), %r13               # move to the next son
    #movq 8(%r13), %r13               # move to the next son in level 3 array
    jmp level3
level3_end:
    cmpq $0, %r12
    jne not_leaf2
    incq %r9                    # increment leaf_counter if level 2 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level2_continue
level2_leaf:
    incq %r9                    # increment leaf_counter if level 2 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level2_continue
not_leaf2:
    incq %r8                    # increment v_counter for level 2 node
level2_continue:
    addq $8, %r11
    movq (%r11), %r12               # move to the next son
    #movq 8(%r12), %r12               # move to the next son in level 2 array
    jmp level2
level2_end:			
    cmpq $0, %r11		# if not equal then not leaf and no need to count as leaf
    jne not_leaf1
    incq %r9                    # increment leaf_counter if level 1 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level1_continue
level1_leaf:
    incq %r9                    # increment leaf_counter if level 1 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level2_continue
not_leaf1:
    incq %r8                    # increment v_counter for level 1 node
level1_continue:
    addq $8, %r10
    movq (%r10), %r11               # move to the next son in level 1 array
    jmp level1
level1_root:
    incq %r9
    jmp end_check
level1_end:
    cmpq $0, %r9                # check if it's the first leaf => root it the only vertex
    je level1_root
    incq %r8                    # count root itself as a vertex

end_check:
    # Check if leaf_counter / (v_counter - leaf_counter) <= 3
    incq %r8                    # any leaf is a vertex also
    imulq $3, %r9               # leaf_counter * 3
    cmpq %r8, %r9               # compare (leaf_counter * 3) with (v_counter - leaf_counter)
    jb not_rich
    movb $1, rich               # set rich to 1 if the condition is met
    jmp end
not_rich:
    movb $0, rich               # set rich to 0 if the condition is not met


end:



  # Print "rich="
movq $1, %rax            # syscall number for sys_write
movq $1, %rdi            # file descriptor (stdout)
lea rich_label(%rip), %rsi   # address of rich_label
movq $5, %rdx            # number of bytes to write (length of "rich=")
syscall                 # make the syscall to print "rich="

# Convert rich to string
movl rich, %eax          # move rich value to %eax
movq $rich_buf + 20, %rsi   # point to the end of the buffer
movb $0, (%rsi)          # null-terminate the string

convert_num_to_str:
    dec %rsi              # move pointer backwards
    movl $10, %ecx        # base 10
    xor %edx, %edx        # clear %edx for division
    div %ecx              # divide %eax by 10
    addb $'0', %dl        # convert remainder to ASCII
    movb %dl, (%rsi)      # store character in buffer
    test %eax, %eax       # check if quotient is zero
    jnz convert_num_to_str # loop if quotient is not zero

# Print the value of 'rich'
movq $1, %rax            # syscall number for sys_write
movq $1, %rdi            # file descriptor (stdout)
movq %rsi, %rsi          # address of the string
movq $rich_buf + 20, %rdx   # calculate the string length
sub %rsi, %rdx           # calculate the string length
syscall                 # make the syscall to print rich

# Print a newline
movq $1, %rax            # syscall number for sys_write
movq $1, %rdi            # file descriptor (stdout)
lea newline(%rip), %rsi  # address of newline character
movq $1, %rdx            # number of bytes to write (1 byte for newline)
syscall                  # make the syscall to print newline

# Exit the program
mov $60, %rax            # syscall number for sys_exit
xor %rdi, %rdi           # exit status (0 for success)
syscall                  # make the syscall to exit the program

.section .rodata
rich_label:
    .asciz "rich="
newline:
    .byte 10               # ASCII code for newline ('\n')

.section .data
rich_buf:
    .skip 20               # Allocate space for rich's ASCII representation


# IMPORTANT: the max depth of the tree is 6 including the root.

# pseudo
#v_counter = 0
#leaf_counter = 0
# node_level1 = root_array[0]
# // Go over root sons:
# while ( node_level1 != 0 ){
#	node_level2 = node_level1[0]	// set the first son
#
#	// Go one level deeper:
#	while (node_level2 != 0){  	// iterate over all sons	
#		go deeper ....
#	}
#	if ( node_level2 == 0 ){  	// has no sons- it's a leaf
#		leaf_counter++
#	}
# 	v_counter++ 			// count it self as a vertex
#	node_level1 = displace root_array by one cell
# }
# v_counter++ 				// count it self as a vertex


# each time we go down :1. Get the first son
#			2. if it's not 0, go deeper
#			3. If it's 0, count leaf
#			4. Count itself as vertex
#			5. Displace to next son
