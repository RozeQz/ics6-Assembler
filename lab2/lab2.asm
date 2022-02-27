    section .data           ; сегмент инициализированных переменных
ExitMsg db      "Press Enter to Exit", 10 ; выводимое сообщение
lenExit equ     $-ExitMsg
a       dw      0
b       dw      5
y       dw      -20

    section .bss            ; сегмент неинициализированных переменных
InBuf   resb    10          ; буфер для вводимой строки
lenIn   equ     $-InBuf     ; длина буфера для вводимой строки
x       resw    1

    section .text           ; сегмент кода
    global _start

_start:
    ; вычисления
    mov     AX,  [a]    ; AX = a
    mov     BX,  [a]    ; BX = a
    mul     BX          ; AX = a^2
    mov     CX,  AX     ; CX = a^2
    mov     AX,  BX     ; AX = a
    mov     BX,  [b]    ; BX = b
    mov     DX,  [y]    ; DX = y
    sub     BX,  AX     ; BX = b-a
    imul    DX          ; AX = a*y
    imul    BX          ; AX = a*y*(b-a)
    mov     BX,  4      ; BX = 4
    idiv    BX          ; AX = a*y*(b-a)/4
    add     AX,  CX     ; AX = a*y*(b-a)/4 + a^2
    sub     AX,  2      ; AX = a*y*(b-a)/4 + a^2 - 2
    mov     [x], AX     ; x =  a*y*(b-a)/4 + a^2 - 2
    
    ; вывод
    mov     rax, 1          ; системная функция 1 (write)
    mov     rdi, 1          ; дескриптор файла stdout=1
    mov     rsi, ExitMsg    ; адрес выводимой строки
    mov     rdx, lenExit    ; длина строки
    syscall                 ; вызов системной функции

    ; ввод
    mov     rax, 0          ; системная функция 0 (read)
    mov     rdi, 0          ; дескриптор файла stdin=0
    mov     rsi, InBuf      ; адрес вводимой строки
    mov     rdx, lenIn      ; длина строки
    syscall                 ; вызов системной функции

    ; завершение программы
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции
