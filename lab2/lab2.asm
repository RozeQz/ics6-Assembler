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
AnsMsg      db      "The result is: x = "
lenAns      equ     $-AnsMsg
AIs     db      "a = "
lenAIs  equ     $-AIs
BIs     db      "b = "
lenBIs  equ     $-BIs
YIs     db      "y = "
lenYIs  equ     $-YIs

    section .bss            ; сегмент неинициализированных переменных
InBuf   resb    10          ; буфер для вводимой строки
lenIn   equ     $-InBuf     ; длина буфера для вводимой строки
OutBuf  resb    10
a       resw    1
b       resw    1
y       resw    1
x       resw    1
temp    resw    1

    section .text           ; сегмент кода
    global _start

_start:
    ; ввод параметров
    write_string InputMsg, lenInput
    
    write_string AIs, lenAIs
    read_string  InBuf, lenIn 
    StrToInt    a
    
    write_string BIs, lenBIs
    read_string  InBuf, lenIn 
    StrToInt    b

    write_string YIs, lenYIs
    read_string  InBuf, lenIn 
    StrToInt    y
    
    ; вычисления
    mov     AX,  [a]    ; AX = a
    imul    AX          ; DX:AX = a^2
    mov     [temp], AX  ; temp = a^2
    mov     AX,  [a]    ; AX = a
    mov     BX,  [b]    ; BX = b
    mov     DX,  [y]    ; DX = y
    sub     BX,  AX     ; BX = b-a
    imul    DX          ; AX = a*y
    imul    BX          ; AX = a*y*(b-a)
    mov     BX,  4      ; BX = 4
    idiv    BX          ; AX = a*y*(b-a)/4
    add     AX,  [temp] ; AX = a*y*(b-a)/4 + a^2
    sub     AX,  2      ; AX = a*y*(b-a)/4 + a^2 - 2
    mov     [x], AX     ; x =  a*y*(b-a)/4 + a^2 - 2
    mov     RBX, 0      ; затираем содержание регистра rbx
    
    ; вывод результата
    write_string AnsMsg, lenAns
    IntToStr    x, OutBuf
    mov rbx, rax            ; помещаем в регистр rbx длину выводимой строки
    write_string OutBuf, rbx
    
    ; завершение программы
    write_string ExitMsg, lenExit
    read_string InBuf, lenIn
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции