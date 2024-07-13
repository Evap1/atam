.global _start

.section .text
_start:
    movq $0, %r8 		# vertex_counter = 0
    movq $0, %r9 		# leaf_counter = 0
    leaq root, %r10 	# node_level1 = root_array[0]
    movb $0 , rich      

    # start traversal from root
    movq (%r10), %r11           # load the first son of the root

level1_HW1:
    cmpq $0, %r11               # if current son is 0, break level 1 loop
    je level1_end_HW1
    movq (%r11), %r12           # load the first son of level 1 node
    cmpq $0, %r12               # check if level 1 node is a leaf
    je level1_leaf_HW1

level2_HW1:
    cmpq $0, %r12               
    je level2_end_HW1
    movq (%r12), %r13          
    cmpq $0, %r13              
    je level2_leaf_HW1

level3_HW1:
    cmpq $0, %r13             
    je level3_end_HW1
    movq (%r13), %r14   
    cmpq $0, %r14        
    je level3_leaf_HW1

level4_HW1:
    cmpq $0, %r14        
    je level4_end_HW1
    movq (%r14), %r15       
    cmpq $0, %r15           
    je level4_leaf_HW1

level5_HW1:
    cmpq $0, %r15              
    je level5_end_HW1
    movq (%r15), %rax          
    cmpq $0, %rax            
    je level5_leaf_HW1

level6_HW1:
    cmpq $0, %rax            
    je level6_end_HW1
    incq %r8                   
    movq 8(%rax), %rax             
    jmp level6_HW1
level6_end_HW1:
    cmpq $0, %r15
    jne not_leaf5_HW1
    incq %r9                    # increment leaf_counter if level 5 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level5_continue_HW1
level5_leaf_HW1:
    incq %r9                    # increment leaf_counter if level 5 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level5_continue_HW1
not_leaf5_HW1:
    incq %r8                    # increment v_counter for level 5 node
level5_continue_HW1:
    addq $8, %r14
    movq (%r14), %r15               # move to the next son
    #movq 8(%r15), %r15               # move to the next son in level 5 array
    jmp level5_HW1
level5_end_HW1:
    cmpq $0, %r14
    jne not_leaf4_HW1
    incq %r9                    # increment leaf_counter if level 4 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level4_continue_HW1
level4_leaf_HW1:
    incq %r9                    # increment leaf_counter if level 4 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level4_continue_HW1
not_leaf4_HW1:
    incq %r8                    # increment v_counter for level 4 node
level4_continue_HW1:
    addq $8, %r13
    movq (%r13), %r14               # move to the next son
    #movq 8(%r14), %r14               # move to the next son in level 4 array
    jmp level4_HW1
level4_end_HW1:
    cmpq $0, %r13
    jne not_leaf3_HW1
    incq %r9                    # increment leaf_counter if level 3 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level3_continue_HW1
level3_leaf_HW1:
    incq %r9                    # increment leaf_counter if level 3 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level3_continue_HW1
not_leaf3_HW1:
    incq %r8                    # increment v_counter for level 3 node
level3_continue_HW1:
    addq $8, %r12
    movq (%r12), %r13               # move to the next son
    #movq 8(%r13), %r13               # move to the next son in level 3 array
    jmp level3_HW1
level3_end_HW1:
    cmpq $0, %r12
    jne not_leaf2_HW1
    incq %r9                    # increment leaf_counter if level 2 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level2_continue_HW1
level2_leaf_HW1:
    incq %r9                    # increment leaf_counter if level 2 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level2_continue_HW1
not_leaf2_HW1:
    incq %r8                    # increment v_counter for level 2 node
level2_continue_HW1:
    addq $8, %r11
    movq (%r11), %r12               # move to the next son
    #movq 8(%r12), %r12               # move to the next son in level 2 array
    jmp level2_HW1
level2_end_HW1:			
    cmpq $0, %r11		# if not equal then not leaf and no need to count as leaf
    jne not_leaf1_HW1
    incq %r9                    # increment leaf_counter if level 1 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level1_continue_HW1
level1_leaf_HW1:
    incq %r9                    # increment leaf_counter if level 1 node is a leaf
    incq %r8                    # any leaf is a vertex also
    jmp level2_continue_HW1
not_leaf1_HW1:
    incq %r8                    # increment v_counter for level 1 node
level1_continue_HW1:
    addq $8, %r10
    movq (%r10), %r11               # move to the next son in level 1 array
    jmp level1_HW1
level1_root_HW1:
    incq %r9
    jmp end_check_HW1
level1_end_HW1:
    cmpq $0, %r9                # check if it's the first leaf => root it the only vertex
    je level1_root_HW1
    incq %r8                    # count root itself as a vertex

end_check_HW1:
    # check if leaf_counter / v_counter <= 3
    incq %r8                    # any leaf is a vertex also
    imulq $3, %r9               # leaf_counter * 3
    cmpq %r8, %r9               # compare (leaf_counter * 3) with (v_counter - leaf_counter)
    jb not_rich_HW1
    movb $1, rich               # set rich to 1 if the condition is met
    jmp end
not_rich_HW1:
    movb $0, rich               # set rich to 0 if the condition is not met

end:
