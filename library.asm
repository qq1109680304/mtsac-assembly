section     .bss
    isNeg:      resb    1
    numArray:   resb    4
    num_sz:     resd    1
    temp:       resd    1

section     .data
    errMsg:     db      "Error: invalid integer input", 0x0A
    err_sz:     equ     $ - errMsg
    endline:    db      0x0A
    seed:       dd      1
    const_a:    equ     1103515245
    const_b:    equ     12345
    const_c:    equ     65536
    const_d:    equ     32768

section     .text

global      print_string
global      endl
global      get_input
global      exit
global 	    reverse_string
global      atoi
global      itoa
global      current_time
global      srand
global      rand
global      legal_string_input
global      pow
global      swap
global      swap2
; test precedure
global      arraySearch

;----------------------------------------------------------------------------------------
print_string:
;
; Prints an array of characters to the console.
; Receives: arg1: address of the array
;           arg2: size of the array
; Returns:  Nothing
; Requires: Nothing
;----------------------------------------------------------------------------------------
    push    ebp                 ; preserve caller's base pointer
    mov     ebp, esp            ; set base pointer for frame
    
    push    ebx                 ; preserve ebx

    mov     ecx, [ebp + 8]      ; move arg1 into ecx (address of the string)
    mov     edx, [ebp + 12]     ; move arg2 into edx (size of the string)
    mov     eax, 4              ; set stream as stdout
    mov     ebx, 1              ; set write code
    int     80h                 ; syscall

    pop     ebx                 ; restore
    pop     ebp                 ; restore caller's base pointer

    ret                         ; return procedure
; End print_string ----------------------------------------------------------------------

;----------------------------------------------------------------------------------------
endl:
;
; Print a next line.
; Receives: Nothing
; Returns:  Nothing
; Requires: Nothing
;----------------------------------------------------------------------------------------
    push    eax                 ; preserve
    push    ebx                 ; preserve

    mov     eax, 4              ; write to file
    mov     ebx, 1              ; file descriptor is stdout
    mov     ecx, endline        ; the new line character
    mov     edx, 1              ; length is 1
    int     0x80                ; syscall

    pop     ebx                 ; restore
    pop     eax                 ; restore
    ret                         ; return procedure
; End print_string ----------------------------------------------------------------------

;----------------------------------------------------------------------------------------
get_input:
;
; Get input of an array of characters from the console
; Receives: arg1: address of the input array
;           arg2: size of the array
; Returns:  EAX (number of characters)
; Requires: Nothing
;----------------------------------------------------------------------------------------
    push    ebp                 ; preserve caller's base pointer
    mov     ebp, esp            ; set base pointer for frame
    
    push    ebx                 ; preserve

    mov     ecx, [ebp + 8]      ; set ecx to arg1
    mov     edx, [ebp + 12]     ; set edx to arg2
    mov     eax, 3              ; set stream as stdin
    mov     ebx, 0              ; set read code
    int     80h                 ; syscall

    pop     ebx                 ; restore
    pop     ebp                 ; restore caller's base pointer
    
    ret                         ; return procedure
; End get_input -------------------------------------------------------------------------

;----------------------------------------------------------------------------------------
exit:  
;
; Exits the program gracefully
; Receives: arg1: exit code
; Returns:  Nothing
; Requires: Nothing
;----------------------------------------------------------------------------------------
    push    ebp                 ; preserve caller's base pointer
    mov     ebp, esp            ; set base pointer for frame
    
    mov     ebx, [ebp + 8]      ; return status on exit
    mov     eax, 1              ; invoke SYS_EXIT (kernel opcode 1)
    int     80h
; End exit ------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------
reverse_string:
; 
; Reverse an array of characters
; Receives: arg1: address of the array
; 			arg2: size of the array
; Returns: 	Nothing
; Requires:	Nothing
;----------------------------------------------------------------------------------------
    push    ebp                 ; preserve caller's base pointer
    mov     ebp, esp            ; set base pointer for frame

	push	esi                 ; preserve
	push 	edi                 ; preserve

	mov 	esi, [ebp + 8]      ; set esi as pointer
	mov 	ecx, [ebp + 12]     ; set ecx as counter
	mov 	edi, esi            ; store address in edi for write loop
	
read:
	.loop:
	movzx 	dx, byte [esi]      ; mov char into dx
	push 	dx                  ; push char on stack
	inc 	esi                 ; increment pointer
	loop 	.loop
	
write:
	mov 	ecx, [ebp + 12]     ; reset counter
	.loop:
	pop 	dx                  ; pop char from stack
	mov 	[edi], dl           ; store it in string
	inc 	edi                 ; increment pointer
	loop 	.loop
	
	pop 	edi                 ; restore
	pop 	esi                 ; restore
    pop     ebp                 ; restore caller's base pointer
	ret
; End reverse_string --------------------------------------------------------------------

;----------------------------------------------------------------------------------------
atoi:
; 
; Convert a string representation of an unsigned integer to an integer
; Receives: arg1: the address of the string
; 			arg2: the size of the string
; Returns: 	EAX: the unsigned integer value
; Requires:	Nothing
; Note:     Horner's polynomial method
;           tmp = 0
;           for each char (left to right)
;               tmp = 10 * tmp + (char_val - 48) (converts vhar to digit)
;----------------------------------------------------------------------------------------
    push    ebp                 ; preserve caller's base pointer
    mov     ebp, esp            ; set base pointer for frame

    push    esi                 ; preserve
    push    ebx                 ; preserve

    mov     esi, [ebp + 8]      ; esi is pointer to array
    mov     ecx, [ebp + 12]     ; ecx holds counter (number of chars)
    mov     ebx, 10             ; ebx is const multiplier
    xor     eax, eax            ; eax holds running product (set to 0)

    .loop:
    mul     ebx                 
    movzx   edx, byte [esi]     ; move character into edx
    add     eax, edx            ; char to running product
    sub     eax, 48             ; character to digit constant
    inc     esi                 ; increment pointer
    loop    .loop

    pop     ebx                 ; restore
    pop     esi                 ; restore
    pop     ebp                 ; restore caller's base pointer
    ret
; End atoi ------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------
itoa:
; 
; Convert an unsigned integer to a string representation
; Receives: arg1: the integer to be converted
; 			arg2: the address of the string
;           arg3: the size of the string
; Returns: 	EAX = the number of chars added to the string
; Requires:	Nothing
; Note:     Nothing
;----------------------------------------------------------------------------------------
    push    ebp                 ; preserve caller's base pointer
    mov     ebp, esp            ; set base pointer for frame
    sub     esp, 4              ; allocate temp var
    mov     [ebp - 4], dword 0  ; init temp to 0
    
    push    ebx                 ; preserve
    push    ecx                 ; preserve
    push    esi                 ; preserve
    push    edi                 ; preserve
    mov     eax, [ebp + 8]      ; move arg1 into eax for conversion

    mov     esi, [ebp + 12]     ; set esi as pointer
    mov     edi, [ebp + 12]     ; set edi as pointer
    mov     eax, [ebp + 16]     ; move arg3 (array size) into ecx
    mov     ebx, 10             ; ebx i divisor

    .loop:
    xor     edx, edx            ; set edx to 0 for division
    idiv    ebx                 ; divide number
    add     edx, 48             ; get character from remainder
    mov     [esi], edx          ; store the character
    inc     dword [ebp - 4]     ; increment counter
    cmp     eax, 0              ; eax <=> 0 ?
    je      .break              ; if eax == 0 then break from loop
    inc     esi                 ; increment pointer
    loop    .loop

    .break:
    push    dword [ebp - 4]     ; agr2 for rev_str call
    push    edi                 ; arg1 for rev_str call
    call    reverse_string
    add     esp, 8

    mov     eax, [ebp - 4]      ; ebx should still hold counter
    add     esp, 4              ; deallocate temp var
    pop     edi                 ; restore
    pop     esi                 ; restore
    pop     ecx                 ; restore
    pop     ebx                 ; restore

    pop     ebp                 ; restore caller's base pointer
    ret
; End itoa ------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------
current_time:
; 
; Get and return the current time in seconds since Unix EPOCH (Jan 1, 1970)
; Receives: Nothing
; Returns: 	EAX = integer value for time in secs
; Requires:	Nothing
; Note:     Nothing
;----------------------------------------------------------------------------------------
    push    ebx          
    mov     eax, 13             ; syscalll number for time
    xor     ebx, ebx            ; time location = NULL
    int     0x80                ; 32-bit time value returned in EAX

    pop     ebx
    ret
; End current_time ----------------------------------------------------------------------

;----------------------------------------------------------------------------------------
srand:
; 
; Set the random number seed
; Receives: EAX = unsigned integer value as seed
; Returns: 	Nothing
; Requires:	Nothing
; Note:     Nothing
;----------------------------------------------------------------------------------------
    mov     [seed], eax
    ret
; End srand -----------------------------------------------------------------------------

;----------------------------------------------------------------------------------------
rand:
; 
; Generate a random number
; Receives: Nothing
; Returns: 	EAX = random unsigned integer
; Requires:	Nothing
; Note:     Nothing
;----------------------------------------------------------------------------------------
    push    ebx                 ; preserve
    push    ecx                 ; preserve
    push    edx                 ; preserve
    xor     eax, eax            ; initalize eax to 0
    xor     ebx, ebx            ; initalize ebx to 0
    xor     ecx, ecx            ; initalize ecx to 0
    xor     edx, edx            ; initalize edx to 0
    mov     eax, [seed]         ; eax = seed
    mov     ebx, const_a        ; ebx = 1103515245
    mul     ebx                 ; eax *= ebx
    add     eax, const_b        ; eax += 12345
    mov     [seed], eax         ; store the new seed number
    xor     ebx, ebx            ; initalize ebx to 0
    mov     ebx, const_c        ; ebx = 65536
    xor     edx, edx            ; initalize edx to 0
    idiv    ebx                 ; eax /= ebx, edx get remainder
    xor     ebx, ebx            ; initalize ebx to 0
    mov     ebx, const_d        ; ebx = 32768
    xor     edx, edx            ; initalize edx to 0
    idiv    ebx                 ; eax /= ebx, edx get remainder
    mov     eax, edx            ; move edx into eax
    pop     edx                 ; restore
    pop     ecx                 ; restore
    pop     ebx                 ; restore
    ret
; End rand ------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------
get_next:
; 
; Get the character value from ESI and then move ESI to next one
; Receives: ESI = Pointer to character
; Returns: 	AL = the character
; Requires:	Nothing
; Note:     Nothing
;----------------------------------------------------------------------------------------
    mov     al, byte [esi]
    inc     esi
    ret
; End get_next --------------------------------------------------------------------------

;----------------------------------------------------------------------------------------
display_error:
; 
; Display the error message
; Receives: Nothing
; Returns: 	Nothing
; Requires:	Nothing
; Note:     Nothing
;----------------------------------------------------------------------------------------
    mov     eax, errMsg
    mov     ebx, err_sz
    call    print_string
    ret
; End display_error ---------------------------------------------------------------------

;----------------------------------------------------------------------------------------
is_digit:
; 
; Generate a random number
; Receives: AL = character we need to check
; Returns: 	ZF = Zero Flag
; Requires:	Nothing
; Note:     Nothing
;----------------------------------------------------------------------------------------
    cmp     al, '0'             ; ZF = 0
    jb      ID1
    cmp     al, '9'             ; ZF = 0
    ja      ID1
    test    ax, 0               ; ZF = 1
    
    ID1:
    ret
; End is_digit --------------------------------------------------------------------------

;----------------------------------------------------------------------------------------
legal_string_input:
; 
; Get and return the current time in seconds since Unix EPOCH (Jan 1, 1970)
; Receives: EAX = the address of the string
; 			EBX = the size of the string
; Returns: 	EAX = integer value for time in secs
; Requires:	Nothing
; Note:     Nothing
;----------------------------------------------------------------------------------------
    push    esi                 ; preserve
    push    ebx                 ; preserve
    push    edx                 ; preserve

    mov     esi, eax            ; esi is pointer to array
    mov     edi, eax            ; edi is the array for number
    mov     ecx, ebx            ; ecx holds counter (number of chars)
    xor     eax, eax            ; eax holds running product (set to 0)

    .loop:
    
    .state_a:
    call    get_next
    cmp     al, '+'             ; leading plus sign?
    je      .state_b            ; go to State B
    cmp     al, '-'             ; leading minus sign?
    je      .state_b            ; go to State B
    call    is_digit            ; returns ZF = 1 if AL = digit
    jz      .state_c            ; go to State C
    call    display_error       ; invalid input found
    jmp     .exit

    .state_b:
    cmp     ecx, ebx            ; see the character is the first one or not
    je      .continue_b         ; if legal, continue work in state_b
    call    display_error       ; invalid input found
    jmp     .exit
    .continue_b:
    sub     al, '+'             ; subtract al with '+'
    inc     edi                 ; increase one byte in edi for atoi convert
    dec     ebx                 ; decrease one byte in ebx for atoi convert
    mov     byte [isNeg], al    ; move the subtract result into isNeg
    jmp     .state_d

    .state_c:
    .state_d:
    loop    .loop               
    mov     eax, edi            ; move the address edi into eax
    call    atoi
    mov     bl, [isNeg]         ; move isNeg number into bl, it should be either 0 or 2
    cmp     bl, 0               ; check bl if it has been subtracted by '+'
    je      .isPos              ; jump if bl == 0
    neg     eax                 ; change number in eax to negative

    .isPos:
    .exit:
    pop     edx                 ; restore
    pop     ebx                 ; restore
    pop     esi                 ; restore
    ret
; End legal_string_input ----------------------------------------------------------------

;----------------------------------------------------------------------------------------
pow:
; 
; Exponentiation function
; Receives: param1 base (32bit)
; 			param2 exponent (32bit->16bit)
; Returns: 	EDX:EAX = base raised to the exponent
; Requires:	Two arguments on stack
; Note:     Nothing
; Algo:     Square and Multiply
;----------------------------------------------------------------------------------------
    
    push    ebp                 ; preserve
    mov     ebp, esp            ; set base of stack frame

    push    ebx                 ; preserve
    push    edi                 ; preserve
    mov     eax, 1              ; product
    mov     ecx, 16             ; 
    mov     ebx, [ebp + 8]      ; get base (ebx)
    mov     edi, [ebp + 12]     ; get exp  (edi)

.state_1:
    shl     di, 1               ; shift left to inspect msb
    jc      .state_2            ; if msb == 1 transition to state 2
    loop    .state_1            ; get next msb

.state_2:
    pushfd                      ; preserve CF
    mul     eax                 ; square prod
    popfd                       ;
    jnc     .next               ; if not CF then don't multiply
    mul     ebx                 ; 
    .next:
    shl     di, 1
    loop    .state_2

    pop     edi                 ; restore
    pop     ebx                 ; restore
    pop     ebp                 ; restore
    ret
; End pow -------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------
swap:
; 
; Swaps the values at two addresses 
; Receives: arg1: address 1
;           arg2: address 2
; Returns: 	Nothing
; Requires: Nothing
;----------------------------------------------------------------------------------------
    
    push    ebp                 ; preserve caller's base pointer
    mov     ebp, esp            ; set base of frame
    sub     esp, 4              ; allocate temp var

    mov     eax, [ebp + 8]      ; get address of arg1
    mov     eax, [eax]          ; get val at arg1
    mov     [ebp - 4], eax      ; store val in temp
    mov     eax, [ebp + 12]     ; get address of arg2
    mov     eax, [eax]          ; get val at arg2
    xchg    eax, [ebp - 4]      ; swap values

    mov     edx, [ebp + 12]     ; move address of arg1 into edx
    mov     [edx], eax          ; move into address of arg1 val in eax
    mov     edx, [ebp - 4]      ; move val in temp into edx
    mov     eax, [ebp + 8]      ; move address of arg2 into eax
    mov     [eax], edx          ; move val in edx to address of arg2

    mov     esp, ebp            ; deallocate temp var
    pop     ebp                 ; restore caller's base pointer
    ret

; End swap ------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------
swap2:
; 
; Swap two values
; Receives: REF x
;           REF y
; Returns: 	Nothing
; Requires:	Nothing
; Note:     Nothing
; Algo:     Nothing
;----------------------------------------------------------------------------------------
    
    push    ebp
    mov     ebp, esp

    push    esi
    push    edi

    lea     esi, [ebp + 12]     ; Store address for REF x
    lea     edi, [ebp + 8]      ; Store address for REF y

    mov     eax, [edi]
    xor     [esi], eax
    mov     eax, [esi]
    xor     [edi], eax
    mov     eax, [edi]
    xor     [esi], eax

    pop     edi
    pop     esi
    leave
    ret
    
; End swap2 -----------------------------------------------------------------------------


; test precedure
arraySearch:
    push    ebp                 ; preserve
    mov     ebp, esp            ; start frame
    push    dword 0             ; create a init local var i
    push    esi                 ; preserve 
    mov     esi, [ebp + 8]      ; array
    mov     ecx, [ebp + 12]     ; count
    mov     edx, [ebp + 16]     ; term
    mov     eax, -1

    .while:
    cmp     edx, [esi]
    je      .wend
    inc     dword [ebp - 4]
    add     esi, 4
    loop    .while

    .wend:
    mov     eax, [ebp - 4]

    .return:
    pop     esi
    add     esp, 4
    pop     ebp
    ret
