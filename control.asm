; Author name: Julian Coronado
; Program title: Arrays
; Files in this program: driver.cpp, control.asm, square.cpp, display.c, compute_mean.asm, run.sh
; Course number: CPSC 240
; Assignment number: 3
; Required delivery date: Mar 7, 2019 before 11:59pm
; Purpose: Learn how arrays work and pass them through different files.
; Language of this module:  X86 with Intel syntax

; ===== BEGIN CODE AREA ====================================================================================================================================================

extern printf                                               ; External C++ function for writing to standard output device
extern scanf                                                ; External C++ function for reading from the standard input device
extern display
global control                                              ; This makes "control" callable by functions outside of this file.
extern square
extern compute_mean

; ===== INITIALIZED DATA ===================================================================================================================================================

segment .data                                               ; Place initialized data here

prompt db "Enter an integer: ", 0
cntrld db "[control + d]", 10, 0
emptyline db "- - -", 10, 0

stringformat db "%s", 0                                     ; General string format
inputformat db "%ld", 0                                     ; General integer format
mean_output db "The mean of those numbers is %lf", 10, 0

; ===== UNINITIALIZED DATA =================================================================================================================================================

segment .bss                                                ; Place un-initialized data here.

; array will hold 20 spaces, as default
arr resq 20

; ===== EXECUTABLE INSTRUCTIONS ============================================================================================================================================

segment .text                                               ; Place executable instructions in this segment.

control:                                                    ; Entry point. Execution begins here.

; ===== BACK UP REGISTERS ==================================================================================================================================================

push       rbp                                              ; Save a copy of the stack base pointer
mov        rbp, rsp                                         ; We do this in order to be 100% compatible with C and C++.
push       rbx                                              ; Back up rbx
push       rcx                                              ; Back up rcx
push       rdx                                              ; Back up rdx
push       rsi                                              ; Back up rsi
push       rdi                                              ; Back up rdi
push       r8                                               ; Back up r8
push       r9                                               ; Back up r9
push       r10                                              ; Back up r10
push       r11                                              ; Back up r11
push       r12                                              ; Back up r12
push       r13                                              ; Back up r13
push       r14                                              ; Back up r14
push       r15                                              ; Back up r15
pushf                                                       ; Back up rflags

; ===== END OF BACK UP REGISTERS ===========================================================================================================================================

; r13 register is the counter
mov r13, 0
; r14 register will hold the array address
mov r14, arr

loop:
    ; compares counter to number 20
    ; if r13 is greater or equal to 20, it'll jump to done
    ; if not continue below
    cmp r13, 20
    jge done

    ; prints out prompt for user to enter integer one by one
    mov rax, 0
    mov rdi, stringformat
    mov rsi, prompt
    call printf

    ; scans in user input and stores it into r14
    mov rax, 0
    mov rdi, inputformat
    mov rsi, r14
    call scanf

    ; checks if user has entered cntrl d, if so jump to done
    cmp eax, -1
    je done

    ; increases counter and moves array up an address
    inc r13
    add r14, 8
    jmp loop

done:

    ; prints out [cntrl+d] to indicate user have entered that key combo
    mov rax, 0
    mov rdi, stringformat
    mov rsi, cntrld
    call printf

    ; moves arr into rdi for function call, displays array
    ; moves r13 (counter / size) into rsi for function call
    ; void display(arr[], size)
    mov rdi, arr
    mov rsi, r13
    call display

    ; prints "---"
    mov rax, 0
    mov rdi, stringformat
    mov rsi, emptyline
    call printf

    ; calls compute_mean passing in array and size
    mov rdi, arr
    mov rsi, r13
    call compute_mean

    ; any register below xmm8 is volatile (xmm0 through xmm7)
    ; store xmm0 in xmm15 until the end of the program
    movsd xmm15, xmm0

    ; mov rax, 1 so assembler knows to look in xmm0
    mov rax, 1
    mov rdi, mean_output
    ; assembler knows that xmm0 is going to be used
    call printf

    ; squares all numbers in array
    mov rdi, arr
    mov rsi, r13
    call square

    ; prints "---"
    mov rdi, stringformat
    mov rsi, emptyline
    call printf

    ; displays array one more time with the squared values
    mov rdi, arr
    mov rsi, r13
    call display

    ; prints "---"
    mov rax, 0
    mov rdi, stringformat
    mov rsi, emptyline
    call printf

    ; moves xmm15 (the mean) back into xmm0 to return the double to the main finally
    movsd xmm0, xmm15

; ===== RESTORES REGISTERS =================================================================================================================================================

popf                                                        ; Restore rflags
pop        r15                                              ; Restore r15
pop        r14                                              ; Restore r14
pop        r13                                              ; Restore r13
pop        r12                                              ; Restore r12
pop        r11                                              ; Restore r11
pop        r10                                              ; Restore r10
pop        r9                                               ; Restore r9
pop        r8                                               ; Restore r8
pop        rdi                                              ; Restore rdi
pop        rsi                                              ; Restore rsi
pop        rdx                                              ; Restore rdx
pop        rcx                                              ; Restore rcx
pop        rbx                                              ; Restore rbx
pop        rbp                                              ; Restore rbp

ret                                                         ; No parameter with this instruction.  This instruction will pop 8 bytes from
                                                            ; the integer stack, and jump to the address found on the stack.
; ===== END OF PROGRAM ====================================================================================================================================================
