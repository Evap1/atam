.global _start

.section .text
_start:
movw $3, type
movq size, %r9
movq data, %r10 
andq $7 , %r9
testq %r9, %r9  #bitwise and with itself - update ZF
je loop_zeros



loop_zeros:
movq %0, %r11
movq (%r10, %r11, 8), %r12 #iterartes data using base=data and iterator=R11
testq %r12, %r12

