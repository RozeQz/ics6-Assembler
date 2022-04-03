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
OutputMsg   db      "Your line after changes:", 10
lenOutput   equ     $-OutputMsg
newLine     db      10
space       db      32

    section .bss            ; сегмент неинициализированных переменных
InBuf       resb    10          ; буфер для вводимой строки
lenIn       equ     $-InBuf     ; длина буфера для вводимой строки
OutBuf      resb    10
lenOut      equ     $-OutBuf
words       resq    16
lenWords    resw    1  
c_words     resq    16
lenCWords   resw    1
ptrw        resw    1
ptrc        resw    1
cnt         resw    1

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

    mov [words], rsp          ; words = адресс первого символа строки
    inc word [lenWords]       ; увеличиваем счетчик слов на 1

    mov rcx, 256              
    cld                       ; начинаем слева
    lea rdi, [rsp]            ; записываем в rdi адресс начала строки
    fill_words:
        mov al, 32            ; в al записываем код пробела
        repne scasb           ; повторяем, пока не найдем пробел в rdi, rcx -= кол-во повторений
        jecxz break           ; если пробелов нет, выходим из цикла

        mov rax, 256                ; rax = 256
        sub rax, rcx                ; rax = 256 - (256 - кол-во повторений) = индекс пробела от начала
        add rax, rsp                ; rax = rsp + индекс пробела
        mov rbx, [lenWords]         ; rbx = кол-во слов
        mov [words + rbx*8], rax    ; words[rbx] = адресс первого символа слова

        inc word [lenWords]         ; увеличиваем счетчик слов

        jmp fill_words              ; заполняем массив словами, пока не закончатся пробелы
    
    break:
        mov rcx, 0                  
        dec word [lenWords]         
        cycle:
            mov rax, [words + rcx*8 + 8]  ; rax = words[i+1], words - массив указателей на начала слов
            sub rax, [words + rcx*8]      ; rax = words[i+1] - words[i] = длина слова с пробелом
            cmp rax, 6            ; сравниваем с 6, т.к. 1 символ уходит на пробел
            jle less              ; если длина слова <= 5
            jmp continue          ; иначе прыгаем на continue
            less:
                mov rbx, [words + rcx*8]  ; rbx = words[i]
                cmp byte [rbx], 99        ; сравниваем rbx с "с"
                je is_c                   ; если это символ "c", прыгаем на is_s
                jmp continue              ; иначе на continue
            is_c:
                push rax                    ; rax = длина слова с пробелом
                mov rax, 0
                mov ax, [lenCWords]         ; ax = кол-во слов на букву "c" <= 5 символов
                mov rsi, [words + rcx*8]    ; rsi = words[i] - указатель на начало i-го слова
                mov [c_words + rax*8], rsi  ; c_words[j] = rsi, c_words - массив указателей на начала c_слов
                pop rbx           ; rbx = длина слова с пробелом
                dec rbx           ; rbx -= 1
                push rcx          
                write_string rsi, rbx   ; выводим слово из c_words
                write_string space, 1
                inc word [lenCWords]    ; увеличиваем счетчик слов на букву "с"
                pop rcx           
            continue:
                inc rcx               ; увеличиваем счетчик
                cmp cx, [lenWords]    ; пока счетчик < кол-ва слов, повторяем цикл
                jl cycle
  
    write_string newLine, 1
    write_string OutputMsg, lenOutput

    mov rax, 0
    mov [ptrw], rax
    mov [ptrc], rax

    here_we_go_again:
        movsx rax, word [ptrw]            ; rax = счетчик words
        mov rbx, [words + rax*8]          ; rbx = words[ptrw]
        movsx rax, word [ptrc]            ; rax = счетчик c_words
        cmp rbx, [c_words + rax*8]        ; words[ptrw] != c_words[ptrc] 
        jne yes                           ; если не равно, прыгаем на yes
        jmp no                            ; иначе прыгаем на no
        yes:
            movsx rax, word [ptrw]        ; rax = ptrw
            mov rsi, [words + rax*8]      ; rsi = words[ptrw]
            mov al, 32                    ; в al записываем код пробела
            cld                           ; начинаем слева
            mov rdi, rsi                  ; rdi = rsi
            mov cx, 32                    ; максимальная длина слова
            repne scasb                   ; повторяем, пока не найдем пробел в rdi, rcx -= кол-во повторений
            mov bx, 32                    
            sub bx, cx                    ; bx = кол-во повторений = длина слова
            movsx rbx, bx                       
            movsx rcx, word [ptrw]              ; rcx = ptrw
            write_string [words + rcx*8], rbx   ; выводим words[ptrw] длиной rbx 
            ; вывод ptrw-го слова
            inc word [ptrw]                     ; ptrw++
            jmp continue_ring
        no:
            movsx rax, word [ptrc]        
            movsx rbx, word [lenCWords]   
            dec rbx                         ; индекс слова последнего слова = длина массива - 1
            cmp rax, rbx                    ; если слово из c_words последнее, меняем его с первым, прыгая на first
            je first                        
            jmp not_first
            not_first:
                inc word [ptrc]
                movsx rax, word [ptrc]
                mov rsi, [c_words + rax*8]  
                mov al, 32
                cld
                mov rdi, rsi
                mov cx, 32                  ; максимальная длина слова
                repne scasb
                mov bx, 32
                sub bx, cx
                movsx rbx, bx
                movsx rcx, word [ptrc]
                write_string [c_words + rcx*8], rbx   ; выводим слово c_words[ptrc+1], реализуя кольцевой сдвиг
                dec word [ptrc]
                jmp end
                ; вывод ptrc+1-го слова
            first:
                movsx rax, word [ptrc]
                mov rsi, [c_words]      ; в rsi записываем первое слово
                mov al, 32
                cld
                mov rdi, rsi
                mov cx, 32              ; максимальная длина слова
                repne scasb
                mov bx, 32
                sub bx, cx
                movsx rbx, bx
                movsx rcx, word [ptrc]          
                write_string [c_words], rbx     ; выводим первое слово
                ; вывод ptrc-го слова
        end:
            inc word [ptrw]
            inc word [ptrc]
        continue_ring:
            inc word [cnt]
            mov rax, [cnt]
            cmp ax, [lenWords]
            jl here_we_go_again

    write_string newLine, 1

    ; завершение программы
    write_string ExitMsg, lenExit
    read_string InBuf, lenIn
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции