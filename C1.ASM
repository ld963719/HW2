; Variant: 17
; Task: Разработать программу, которая вводит одномерный массив A[n], формирует из элементов массива А, стоящих после последнего положительного элемента новый массив В и выводит его. Память под массивы может выделяться как статически, так и динамически по выбору разработчика

format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'Input size of vector A ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strVecElemOutA  db 'A[%d] = %d', 10, 0
        strVecElemOutB  db 'B[%d] = %d', 10, 0

        vec_size     dd 0
        last_positive dd -1   ; last positive element
        count_of_printed dd 0     ; count of printed elements of vector B
        i            dd ?
        j            dd ?
        tmp          dd ?
        tmpStack     dd ?
        tmpB         dd ?
        tmpStackB    dd ?
        vecA         rd 100
        vecB         rd 100


;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector A input
        call VectorAInput
; 2) search last positive element
        call SearchPositive
; 3)  vector A out
        call VectorAOut
; 4)  create vector B
        call CreateB
; 5)  vector B out
        call VectorBOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorAInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jg  getVectorA
; fail size
        push vec_size
        push strIncorSize
        call [printf]
        push 0
        call [ExitProcess]
; else continue...
getVectorA:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA            ; ebx = &vecA
getVecLoopA:
        mov [tmp], ebx
        cmp ecx, [vec_size]    ; comparing with vector A length
        jge endInputVectorA

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoopA
endInputVectorA:
        ret
;--------------------------------------------------------------------------
SearchPositive:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA            ; ebx = &vecA
searchPositiveLoop:
        cmp ecx, [vec_size]
        je endSearch

        mov eax, 0
        add eax, [ebx]
        cmp eax ,1   ;checking wheather element > 0
        jge save

        inc ecx
        add ebx, 4
        jmp searchPositiveLoop
; saving current last positive
save:
        mov [last_positive], ecx
        inc ecx
        add ebx, 4
        jmp searchPositiveLoop

endSearch:
        ret
;--------------------------------------------------------------------------
VectorAOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA            ; ebx = &vecA

putVecLoopA:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVectorA      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOutA
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoopA
endOutputVectorA:
        mov esp, [tmpStack]
        ret


CreateB:
   xor ecx, ecx            ; ecx = 0
   mov ebx, vecA
   mov edx, vecB
initializeB:
        cmp ecx, [vec_size]
        je endB
        cmp ecx, [last_positive]   ; comparing with last positive
        jg writeToB
        inc ecx
        add ebx, 4
        add edx, 4
        jmp initializeB
; writing new element to vector B
writeToB:
        mov eax, 0
        add eax,[ebx]
        mov [vecB + 4*ecx], eax
        inc ecx
        add ebx, 4
        add edx, 4
        jmp initializeB

endB:
        ret


;--------------------------------------------------------------------------

VectorBOut:
        mov [tmpStackB], esp
        xor ecx, ecx            ; ecx = 0
        mov edx, vecB            ; ebx = &vec
putVecLoopB:
        mov [tmpB], edx
        cmp ecx, [vec_size]
        je endOutputVectorB      ; to end of loop
        mov [j], ecx

        ; output element
        cmp ecx,[last_positive]
        jg printElem


        mov ecx, [j]
        inc ecx
        mov edx, [tmpB]
        add edx, 4
        jmp putVecLoopB
; printing elements of vector B with information about index of element
printElem:
        mov ecx, [count_of_printed]
        push dword [edx]
        push ecx
        push strVecElemOutB
        call [printf]
        mov ecx, [j]
        inc ecx
        inc [count_of_printed]
        mov edx, [tmpB]
        add edx, 4
        jmp putVecLoopB

endOutputVectorB:
        mov esp, [tmpStackB]
        ret

;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'