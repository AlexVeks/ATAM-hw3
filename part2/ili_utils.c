
#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
// <STUDENT FILL> - HINT: USE INLINE ASSEMBLY
    asm volatile("sidt %0" : "=m" (*idtr)); 
// </STUDENT FILL>
}

void my_load_idt(struct desc_ptr *idtr) {
// <STUDENT FILL> - HINT: USE INLINE ASSEMBLY
   asm volatile("lidt %0;": :"m"(*idtr));

// <STUDENT FILL>
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
// <STUDENT FILL> - HINT: NO NEED FOR INLINE ASSEMBLY
    gate->offset_low = addr & 0xFFFF;             // Lower 16 bits
    gate->offset_middle = (addr >> 16) & 0xFFFF;     // Middle 16 bits
    gate->offset_high = (addr >> 32) & 0xFFFFFFFF; // Upper 32 bits

// </STUDENT FILL>
}

unsigned long my_get_gate_offset(gate_desc *gate) {
// <STUDENT FILL> - HINT: NO NEED FOR INLINE ASSEMBLY
    unsigned long addr = gate->offset_high;         // Upper 32 bits
    addr = addr << 16 | gate->offset_middle;        // Add middle 16 bits
    addr = addr << 16 | gate->offset_low;           // Add lower 16 bits
    return addr;
// </STUDENT FILL>
}
