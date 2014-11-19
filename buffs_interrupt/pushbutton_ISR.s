.include "key_codes.s"				/* defines values for KEY1, KEY2, KEY3 */
.extern	KEY_PRESSED					/* externally defined variable */
/***************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine checks which KEY has been pressed. If it is KEY1 or KEY2, it writes this 
 * value to the global variable KEY_PRESSED. 
****************************************************************************************/
	.global	PUSHBUTTON_ISR
PUSHBUTTON_ISR:
	subi		sp, sp, 16					/* reserve space on the stack */
	stw			ra, 0(sp)
	stw			r10, 4(sp)
	stw			r11, 8(sp)
   
	stw			r13, 12(sp)

	movia		r10, 0x10000050					/* base address of pushbutton KEY parallel port */
	ldwio		r11, 0xC(r10)					/* read edge capture register */
	stwio		r0,  0xC(r10)					/* clear the interrupt */                  
	movia		r10, KEY_PRESSED				/* global variable to return the result */
CHECK_KEY1:
	andi		r13, r11, 0b0010				/* check key1 */
	beq			r13, r0, CHECK_KEY2
	movia		r14, 0x00000008					/* This is the min speed of (measured by the led placement)*/
	beq			r23, r14, END_PUSHBUTTON_ISR	/* if we are at the end, then skip the rest of this cause it does not matter */
	
	addi		r17, r17, 4						/* increment down the array */
	ldw			r12, 0(r17)						/* put that shit on cinemax: used to be: movia		r12, 0x002625A0*/
	
	sthio		r12, 8(r16)						/* store the low half word of counter start value */ 
	srli		r12, r12, 16
	sthio		r12, 0xC(r16)					/* high half word of counter start value */ 
	
	/* start interval timer, enable its interrupts */
	movi		r15, 0b0111						/* START = 1, CONT = 1, ITO = 1 */
	sthio		r15, 4(r16)
	
	srli		r23, r23, 1
	stwio 		r23, 0(r9)
	
	br 			END_PUSHBUTTON_ISR
CHECK_KEY2:
	andi		r13, r11, 0b0100				/* check KEY2 */
	beq			r13, zero, END_PUSHBUTTON_ISR
	movia		r14, 0x00000200					/* This is the max speed of (measured by the led placement)*/	
	beq			r23, r14, END_PUSHBUTTON_ISR  	/* if we are at the end, then skip the rest of this cause it does not matter */
	
	addi		r17, r17, -4					/* increment up the array */
	ldw			r12, 0(r17)						/* put that shit on cinemax: used to be: movia		r12, 0x002625A0*/
	
	sthio		r12, 8(r16)						/* store the low half word of counter start value */ 
	srli		r12, r12, 16
	sthio		r12, 0xC(r16)					/* high half word of counter start value */ 

	/* start interval timer, enable its interrupts */
	movi		r15, 0b0111						/* START = 1, CONT = 1, ITO = 1 */
	sthio		r15, 4(r16)
	
	slli		r23, r23, 1
	stwio 		r23, 0(r9)
	
	br 			END_PUSHBUTTON_ISR
	
END_PUSHBUTTON_ISR:
	ldw			ra,  0(sp)							/* Restore all used register to previous */
	ldw			r10, 4(sp)
	ldw			r11, 8(sp)

	ldw			r13, 12(sp)
	addi		sp,  sp, 16
   
	ret
	.end
	
