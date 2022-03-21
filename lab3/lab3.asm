%include "../lib64.asm"

%macro write_string 2
    ; вывод
    mov     rax, 1          ; системная функция 1 (write)
    mov     rdi, 1          ; дескриптор файла stdout=1
    mov     rsi, %1         ; адрес выводимой строки
    mov     rdx, %2         ; длина строки
    syscall                 ; вызов системной функции
%endmacro

%macro read_string 2
    ; ввод
    mov     rax, 0          ; системная функция 0 (read)
    mov     rdi, 0          ; дескриптор файла stdin=0
    mov     rsi, %1         ; адрес вводимой строки
    mov     rdx, %2         ; длина строки
    syscall                 ; вызов системной функции
%endmacro

%macro StrToInt 1
    ; перевод string в integer
    call    StrToInt64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
    mov     [%1], ax            
%endmacro

%macro IntToStr 2
    ; перевод integer в string
    mov     rsi, %2
    mov     ax, [%1]            ; получение числа из памяти
    cwde
    call    IntToStr64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки         
%endmacro

    section .data           ; сегмент инициализированных переменных
ExitMsg     db      "Press Enter to Exit", 10 ; выводимое сообщение
lenExit     equ     $-ExitMsg
InputMsg    db      "Enter the parameters", 10
lenInput    equ     $-InputMsg
AnsMsg      db      "The result is: f = "
lenAns      equ     $-AnsMsg
ErrorMsg    db      "Parameter d cannot be 0", 10
lenError    equ     $-ErrorMsg
AIs     db      "a = "
lenAIs  equ     $-AIs
DIs     db      "d = "
lenDIs  equ     $-DIs
XIs     db      "x = "
lenXIs  equ     $-XIs
CIs     db      "c = "
lenCIs  equ     $-CIs

    section .bss            ; сегмент неинициализированных переменных
InBuf   resb    10          ; буфер для вводимой строки
lenIn   equ     $-InBuf     ; длина буфера для вводимой строки
OutBuf  resb    10
a       resw    1
c       resw    1
d       resw    1
x       resw    1
f       resw    1

    section .text           ; сегмент кода
    global _start

_start:
    ; ввод параметров
    write_string InputMsg, lenInput
    
    write_string CIs, lenCIs
    read_string  InBuf, lenIn 
    StrToInt    c

    write_string AIs, lenAIs
    read_string  InBuf, lenIn 
    StrToInt    a

    write_string DIs, lenDIs
    read_string  InBuf, lenIn 
    StrToInt    d

    mov ax, [d]     ; ax = d
    cmp ax, 0       ; if ax  = 0 {
    je error        ;   прыгаем на метку error }

    write_string XIs, lenXIs
    read_string  InBuf, lenIn 
    StrToInt    x
    
    ; вычисления
    mov ax, [c]
    cmp ax, 10      ; if (c <= 10) {
    jg  more        ; 
    mov ax, 3       ; ax = 3;
    jmp continue    ; }
    more:           ; else {
        mov ax, [a]     ; ax = a;
        imul word [a]   ; ax = a*a;
        imul word [a]   ; ax = a*a*a;
        idiv word [d]   ; ax = a*a*a/d;
        sub  ax, [x]    ; ax = a*a*a/d - x;
    continue:       ; }
        mov [f], ax     ; f = ax;
    
    ; вывод результата
    write_string AnsMsg, lenAns
    IntToStr    f, OutBuf
    mov rbx, rax            ; помещаем в регистр rbx длину выводимой строки
    write_string OutBuf, rbx
    jmp exit

    error:
        write_string ErrorMsg, lenError     ; выводим сообщение об ошибке

    exit:
        ; завершение программы
        write_string ExitMsg, lenExit
        read_string InBuf, lenIn
        mov     rax, 60         ; системная функция 60 (exit)
        xor     rdi, rdi        ; return code 0    
        syscall                 ; вызов системной функции
