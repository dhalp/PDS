.include "key_codes.s"			/* defines values for KEY1, KEY2, KEY3 */
/********************************************************************************
 * This program demonstrates use of interrupts in the DE0 Basic Computer. It
 * first starts the interval timer with 33 msec timeouts, and then enables 
 * Nios II interrupts from the interval timer and pushbutton KEYs
 *
 * The interrupt service routine for the interval timer displays a pattern on 
 * the HEX displays, and shifts this pattern either left or right. The shifting
 * direction is set in the pushbutton interrupt service routine, as follows:
 *		KEY[1]: shifts the displayed pattern to the right
 *		KEY[2]: shifts the displayed pattern to the left
********************************************************************************/
	.text									/* executable code follows */
	.global _start
_start:
	/* set up the stack */
	movia 	sp, 0x007FFFFC				/* stack starts from largest memory address */

	movia		r16, 0x10002000			/* internal timer base address */
	movia		r9, 0x10000010			/* Base address for LEDS */
	movia		r17, SPEEEED			/* Loads the base address for the speed matix */
	addi		r17, r17, 12			/* Places us in the middle of the speed values */
	
	movia		r23, 0x00000040			/* Default LED */
	stwio 		r23, 0(r9)				/* Pushes value to LED*/
	

	/* set the interval timer period for scrolling the HEX displays */
	movia		r12, 0x00F00000			/* 1/(50 MHz) x (0x190000) = 33 msec */
	sthio		r12, 8(r16)				/* store the low half word of counter start value */ 
	srli		r12, r12, 16
	sthio		r12, 0xC(r16)			/* high half word of counter start value */ 

	/* start interval timer, enable its interrupts */
	movi		r15, 0b0111				/* START = 1, CONT = 1, ITO = 1 */
	sthio		r15, 4(r16)

	/* write to the pushbutton port interrupt mask register */
	movia		r15, 0x10000050			/* pushbutton key base address */
	movi		r7, 0b0110				/* set 2 interrupt mask bits (bit 0 is Nios II Reset) */
	stwio		r7, 8(r15)				/* interrupt mask register is (base + 8) */

	/* enable Nios II processor interrupts */
	movi		r7, 0b011				/* set interrupt mask bits for levels 0 (interval */
	wrctl		ienable, r7				/* timer) and level 1 (pushbuttons) */
	movi		r7, 1
	wrctl		status, r7				/* turn on Nios II interrupt processing */
	movia		r19, HEX_bits
	addi		r18, r19, 84

IDLE:
	br 		IDLE						/* main program simply idles */

	.data
/* The two global variables used by the interrupt service routines for the interval timer
 * and the pushbutton keys are declared below */
	
	.global	KEY_PRESSED
	.global SPEEEED

SPEEEED:
	.word 0x002625A0
	.word 0x004625A0
	.word 0x006625A0
	.word 0x00F00000
	.word 0x018F0000
	.word 0x028F0000
	.word 0x030FFFFF

	.global HEX_bits
HEX_bits:
	.word 0x00063000
	.word 0x00300600
	.word 0x06000030
	.word 0x30000006
	.word 0x303d3f06
	.word 0x00000000
	.word 0x303d3f06
	.word 0x00000000
	.word 0x7c1c7171
	.word 0x1c71716d
	.word 0x71716d00
	.word 0x716d0000
	.word 0x6d000000
	.word 0x00000000
	.word 0x2908010d
	.word 0x30090906
	.word 0x1901080b
	.word 0x2908010d
	.word 0x30090906
	.word 0x1901080b
	.word 0x2908010d
	.word 0x30090906
	.word 0x1901080b
KEY_PRESSED:
	.word		KEY2						/* stores code representing pushbutton key pressed */

	.end
