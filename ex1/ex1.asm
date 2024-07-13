.global _start

.section .text
_start:
    movq $0, Legal
    movq Adress, %r9
    movq length, %r10
    movq Index, %r11
    cmpq %r10, %r11
    jae end
    movq $1 , Legal
    movq (%r9, %r11, 4), %r12
    movq %r12, num
end:
