.global _start

.section .text
_start:
    movq Adress, %r9
    cmpq $0, %r9
    je not_legal_HW1
    movslq length, %r10
    movslq Index, %r11
    cmpq %r10, %r11
    jae end
    movb $1 , Legal
    movq (%r9, %r11, 4), %r12
    movl %r12d, num
    jmp end
not_legal_HW1:
    movb $0, Legal
end:
