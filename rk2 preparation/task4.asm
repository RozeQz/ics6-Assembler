%include "../lib64.asm"

%macro write_string 2
    ; вывод
    ; 1 - адрес строки, 2 - длина строки
    mov     rax, 1          ; системная функция 1 (write)
    mov     rdi, 1          ; дескриптор файла stdout=1
    mov     rsi, %1         ; адрес выводимой строки
    mov     rdx, %2         ; длина строки
    syscall                 ; вызов системной функции
%endmacro

%macro read_string 2
    ; ввод
    ; 1 - буфер ввода, 2 - длина буфера ввода
    mov     rax, 0          ; системная функция 0 (read)
    mov     rdi, 0          ; дескриптор файла stdin=0
    mov     rsi, %1         ; адрес вводимой строки
    mov     rdx, %2         ; длина строки
    syscall                 ; вызов системной функции
%endmacro

%macro StrToInt 1
    ; перевод string в integer
    ; rsi должен содержать адрес строки для преобразования
    call    StrToInt64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
    mov     %1, eax            
%endmacro

%macro IntToStr 2
    ; перевод integer в string
    mov     rsi, %2
    mov     eax, %1             ; получение числа из памяти
    cwde
    call    IntToStr64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки         
%endmacro

    section .data           ; сегмент инициализированных переменных
ExitMsg     db      "Press Enter to Exit", 10 ; выводимое сообщение
lenExit     equ     $-ExitMsg
InputMsg    db      "Enter the line:", 10
lenInput    equ     $-InputMsg
OutputMsg   db      "Number of characters a: "
lenOutput   equ     $-OutputMsg
newLine     db      10

    section .bss            ; сегмент неинициализированных переменных
InBuf   resb    10          ; буфер для вводимой строки
lenIn   equ     $-InBuf     ; длина буфера для вводимой строки
OutBuf  resb    10
lenOut  equ     $-OutBuf
count   resd    1

    section .text           ; сегмент кода
    global _start

_start:

    write_string InputMsg, lenInput

    ; ввод строки
    sub rsp, 64     ; выделяем память для буфера ввода 
    
    read_string rsp, 64     ; выделяем память для ввода строки

    mov rax, 0
    mov rcx, 0              ; rcx - индекс символа в строке, введенной пользователем
    while:
        cmp byte [rsp + rcx], 10        ; сравниваем символ в строке с enter
        je break_while                  ; если enter, прыгаем на end_of_line
        not_enter:
            mov bl, [rsp + rcx]         ; bl = текущий символ
            cmp bl, 'a'
            je is_a                     ; если символ "а", прыгаем на is_a
            jmp continue                ; прыгаем на continue
        is_a:
            inc rax                     ; увеличиваем счетчик символов
            mov [count], rax            ; count = rax
        continue:
            inc rcx                     ; переходим к следующему символу в строке
            jmp while                   ; переходим к следующей итерации цикла
    break_while:
        add rsp, 64     ; вернем стек к изначальному состоянию
        mov rbx, 0      ; очищаем регистр rbx для последующей работы с ним

    write_string newLine, 1
    write_string OutputMsg, lenOutput

    ; вывод количества символов
    IntToStr [count], OutBuf
    mov rbx, rax                        ; перекладываем длину строки в rbx, т.к. write_string работает с rax
    write_string OutBuf, rbx
    write_string newLine, 1

    ; завершение программы
    write_string ExitMsg, lenExit
    read_string InBuf, lenIn
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции