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

%macro IntToStr 2
    ; перевод integer в string
    mov     rsi, %2
    movsx   eax, byte %1        ; получение числа из памяти
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
OutputMsg   db      "The number of words with more than 3 letters A: "
lenOutput   equ     $-OutputMsg
newLine     db      10

    section .bss                ; сегмент неинициализированных переменных
InBuf       resb    10          ; буфер для вводимой строки
lenIn       equ     $-InBuf     ; длина буфера для вводимой строки
OutBuf      resb    10
lenOut      equ     $-OutBuf
lenword     resb    1
count       resb    1
symbols     resb    1

    section .text           ; сегмент кода
    global _start

_start:

    write_string InputMsg, lenInput

    ; ввод строки
    sub rsp, 256     ; выделяем память для буфера ввода 
    
    read_string rsp, 256      ; выделяем память для ввода строки

    mov rcx, 0
    mov rdx, 0
    mov rcx, 256             
    std                       ; начинаем поиск справа
    mov al, 10                ; в al записываем код искомого символа (enter)
    lea rdi, [rsp + 256]      ; в rdi записываем адресс конца строки
    repne scasb               ; поиск enter в введенной строке

    mov byte [rsp + rcx + 1], 32  ; запишем вместо enter пробел

    mov rbx, 256
    mov rcx, 256              
    cld                       ; начинаем слева
    lea rdi, [rsp]            ; записываем в rdi адресс начала строки
    words:
        mov al, 32            ; в al записываем код пробела
        repne scasb           ; повторяем, пока не найдем пробел в rdi, rcx -= кол-во повторений
        jecxz break           ; если пробелов нет, выходим из цикла

        push rcx              ; помещаем rcx в стек
        
        sub rbx, rcx                ; rbx = число символов в слове + 1
        mov [lenword], bl           ; lenword = длина слова + 1
        mov rbx, rcx                

        mov rdx, [symbols]                  ; rdx = кол-во пройденных символов
        lea rdi, [rsp + 8 + rdx]            ; записываем в rdi адресс начала обрабатываемого слова
        mov rdx, 0
        mov cl, [lenword]           ;  rcx = длина слова + 1
        a_search:
            mov al, 65              ; в al записываем код символа 'A'
            repne scasb             ; повторяем, пока не найдем букву 'A' в rdi
            jecxz no_more_a         ; если букв 'A' нет, прыгаем на a_search
            inc rdx                 ; увеличиваем счетчик символов
            jmp a_search            ; повторяем цикл

        no_more_a:
            cmp rdx, 3              ; сравниваем счетчик символов с 3
            jg more                 ; если больше 3, прыгаем на 3
            jmp continue            ; иначе прыгаем на continue
            more:
                inc byte [count]    ; увеличиваем счётчик слов

        continue:
            pop rcx                 ; вытаскиваем rcx из стека
            mov dl, [lenword]       ; rdx = lenword
            add [symbols], dl       ; symbols += rdx
            mov rdx, 0              ; очищаем регистр rdx
            jmp words               ; повторяем цикл
    
    break:

    write_string newLine, 1
    write_string OutputMsg, lenOutput

    mov rbx, 0
    ; вывод количества слов
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