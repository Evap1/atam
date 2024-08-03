#include <asm/desc.h>

// Store the old IDTR interrupt descriptor table register 
// input : old_idtr
void my_store_idt(struct desc_ptr *idtr) {
  asm volatile(
    "sidt %0" :    // asm code  
    "=m"(*idtr) :  // output - store in the memory pointed by idtr the old IDTR
    :              // input
    :              // clobbered registers
    );
}

void my_load_idt(struct desc_ptr *idtr) {
// <STUDENT FILL> - HINT: USE INLINE ASSEMBLY

// <STUDENT FILL>
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
// <STUDENT FILL> - HINT: NO NEED FOR INLINE ASSEMBLY

// </STUDENT FILL>
}

// Store old INVALID OPCODE handler address
// input : old_idt[INVALID_OPCODE]
// return : the linking of (msb) offset_high -> offset_mid -> offset_low (lsb)
unsigned long my_get_gate_offset(gate_desc *gate) {
  unsigned long handler_address = gate->offset_high; // 32 highest bits
  handler_address = (handler_address << 16 ) + gate->offset_middle;  // shift left 16 bits and add middle 16 bits
  handler_address = (handler_address << 16 ) + gate->offset_low;  // shift left 16 bits and add lowest 16 bits
  return handler_address;
}

// asm(
//   "assembly template" :
//   output operands :
//   input operands   :
//   clobbered registers list
// )
