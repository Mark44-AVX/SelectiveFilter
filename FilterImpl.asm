; FilterImpl.asm

GREATER EQU 1

; Prototype: extern "C" int FilterTop(unsigned int arrSize, int Arr[], int cutOffVal, int* SumAbove);
; Calculate the sums of numbers above a cutoff value in an array.
; Parameters:
;    arrSize   - Number of elements in Arr in RCX
;    Arr       - Address of Arr in RDX
;    cutOffVal - Cutoff value in R8
;    SumAbove  - Address of sum of numbers larger than cutoff in R9    
; Returns count of elements larger than cutoff value in EAX
; Registers used:
;    zmm0 -- Initialized to 16 copies of cutoff value
;    zmm1 -- accumulator for sum of entries > cutoff value


.code

FilterTop PROC C
; Prologue
	push        rdi			; RDI and RSI are non-volatile registers, so save them.
	push		rsi
	sub         rsp, 20h  
	mov         rdi, rsp	
	vzeroall
; 
	shr rcx, 4							; Divide by 16, since we can process 16 ints (64 bytes) per iteration
	mov rsi, r8							; Copy cutoff value to RSI
	vpbroadcastd zmm0, esi				; zmm0 contains 16 copies of cutoff value
	xor rax, rax						; Zero out RAX and R10
	xor r10, r10

;------------- Loop that processes the numbers in the array
L1:
	vmovdqa32 zmm3, zmmword ptr[rdx]	; Get 16 ints
	vpcmpd k1, zmm3, zmm0, GREATER		; Compare (<) ints in zmm3 with cutoff values in zmm0, and set 16 flags in k1
										; See below for list of imm8 values for comparison
	knotw k2, k1						; k2 == ~k1 -- Flags in k2 are for the values in zmm3 that are >= cutoff value
	kmovq r10, k2
	popcnt r10, r10						; Number of elements in this batch that are larger than cutoff
	add rax, r10
	vpaddd zmm1 {k2}, zmm1, zmm3		; Selectively add value > cutoff to the accumulated sum	
							
	add rdx, 64				; Increment array address to next 16 ints
	loop L1
;-------------------------------------------------------

	; zmm1 is a vector with 16 partial sums of the positive values
	; Convert zmm1 to two ymm regs, each with 8 ints
	vmovaps zmm4, zmm1
	vextracti32x8 ymm5, zmm4, 1
	
	; Contents of zmm1 are now in ymm4 and ymm5
	
	; Get the sum of all of the positive numbers
	; Each horizontal addition combines two of the partial sums
	vpaddd ymm0, ymm4, ymm5			; Add the two halves and put in ymmm0
	vphaddd ymm0, ymm0, ymm0		; Four partial sums are duplicated in upper and lower
									;    halves of ymm0
	vpermq ymm0, ymm0, 0d8h			; Swap 2nd and 3rd qwords of ymm0 -- 0d8h == 11 01 10 00
									; Now the four partial sums are all in xmm0
									
	vphaddd xmm0, xmm0, xmm0		; Two partial sums are now in low half of xmm0
	vphaddd xmm0, xmm0, xmm0		; Final sum is now in low dword of xmm0 (and duplicated in other parts)
	vpextrd ebx, xmm0, 0			; Extract the dword at index 0 from xmm0
	mov dword ptr[r9], ebx			; Save the value to memory
		

; Epilogue	
	add     rsp, 20h		; Adjust the stack back to original state
	pop		rsi
	pop     rdi				; Restore RDI	
	ret 

FilterTop ENDP

readTime	PROC C
	;; Returns the start time, clocks, in RAX.
	rdtscp
	shl rdx, 32
	or rax, rdx
	ret
readTime ENDP
END

; Comparison predicate values as used in vpcmpd above
; 0 - EQ
; 1 - LT
; 2 - LE
; 3 - FALSE
; 4 - NEQ
; 5 - NLT
; 6 - NLE
; 7 - TRUE