.include "key_codes.s"				/* defines values for KEY1, KEY2, KEY3 */
.extern	PATTERN						/* externally defined variables */
.extern	KEY_PRESSED					

/*****************************************************************************
 * Interval timer interrupt service routine
 *                                                                          
 * Shifts a PATTERN being displayed on the HEX displays. The shift direction 
 * is determined by the external variable KEY_PRESSED.
 * 
******************************************************************************/
	.global INTERVAL_TIMER_ISR
INTERVAL_TIMER_ISR:					
	subi		sp,  sp, 36				/* reserve space on the stack */
	stw		ra, 0(sp)
	stw		r4, 4(sp)
	stw		r5, 8(sp)
	stw		r6, 12(sp)
	stw		r8, 16(sp)
	stw		r10, 20(sp)
	stw		r20, 24(sp)
	stw		r21, 28(sp)
	stw		r22, 32(sp)


	movia		r10, 0x10002000			/* interval timer base address */
	sthio		r0,  0(r10)				/* clear the interrupt */
	

	movia		r20, 0x10000020			/* HEX3_HEX0 base address */
	/*addi		r5, r0, 1 				 set r5 to the constant value 1 */
	movia		r21, HEX_bits			/* set up a pointer to the pattern for HEX displays */
	addi		r21, r21, 84
	movia		r22, KEY_PRESSED		/* set up a pointer to the key pressed */
	ldw			r6, 0(r19)				/* load pattern for HEX displays */ 
	stwio		r6, 0(r20)				/* store to HEX3 ... HEX0 */
	beq			r19, r21, RES
	addi		r19, r19, 4
	br	 		END_INTERVAL_TIMER_ISR
	
SLOW:
	/*stwio 		r13, 0(r9)*/
	br			END_INTERVAL_TIMER_ISR
	
RES:
	movia 		r19, HEX_bits
	br		 	END_INTERVAL_TIMER_ISR

END_INTERVAL_TIMER_ISR:
	stw		r6, 0(r21)				/* store HEX display pattern */

	ldw		ra, 0(sp)				/* Restore all used register to previous */
	ldw		r4, 4(sp)
	ldw		r5, 8(sp)
	ldw		r6, 12(sp)
	ldw		r8, 16(sp)
	ldw		r10, 20(sp)
	ldw		r20, 24(sp)
	ldw		r21, 28(sp)
	ldw		r22, 32(sp)
   addi		sp,  sp, 36				/* release the reserved space on the stack */

	ret

	.end
	
