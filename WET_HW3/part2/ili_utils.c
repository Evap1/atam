#include <asm/desc.h>

// Store the old IDTR interrupt descriptor table register 
// input : old_idtr
void my_store_idt(struct desc_ptr *idtr) {
  asm volatile("sidt %0":"=m"(*idtr):::);

  // asm volatile(
  //   "sidt %0" :    // asm code  
  //   "=m"(*idtr) :  // output - (dest) store in the memory pointed by idtr the old IDTR
  //   :              // input
  //   :              // clobbered registers
  //   );
}

// Swap to the new IDTR
// input : new_idtr
void my_load_idt(struct desc_ptr *idtr) {
  asm volatile("lidt %0"::"m"(*idtr)::);
  
    // asm volatile(   
    // "lidt %0" :    // asm code  
    // :              // output 
    // "m"(*idtr) :    // input - (src) load 10 bytes starting at *idtr (from the memory) to the register IDTR
    // :              // clobbered registers
    // );
}

// Replace INVALID OPCODE handler address with my_ili_handler
// input : gate - the new handler address
//         addr - our new handler function itself
void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
  gate->offset_high = addr >> 32;      // shirt right 32 bits to store in high
  gate->offset_middle = addr >> 16;    // shift right 16 bits to store in middle
  gate->offset_low = addr ;            // store the lowest 16 bits
}

// Store old INVALID OPCODE handler address
// input : gate - the old invalid opcode handler address
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
