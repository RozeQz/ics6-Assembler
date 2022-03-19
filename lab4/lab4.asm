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
    ; rsi должен содержать адрес строки для преобразования
    call    StrToInt64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
    mov     %1, ax            
%endmacro

%macro IntToStr 2
    ; перевод integer в string
    mov     rsi, %2
    mov     ax, %1              ; получение числа из памяти
    cwde
    call    IntToStr64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки         
%endmacro

    section .data           ; сегмент инициализированных переменных
ExitMsg     db      "Press Enter to Exit", 10 ; выводимое сообщение
lenExit     equ     $-ExitMsg
InputMsg    db      "Enter the martix 3x6:", 10
lenInput    equ     $-InputMsg
tab         db      9
newLine     db      10

    section .bss            ; сегмент неинициализированных переменных
InBuf   resb    10          ; буфер для вводимой строки
lenIn   equ     $-InBuf     ; длина буфера для вводимой строки
OutBuf  resb    10
lenOut  equ     $-OutBuf
matrix  resd    18

    section .text           ; сегмент кода
    global _start

_start:
    ; ввод параметров
    write_string InputMsg, lenInput

    mov rcx, 0          ; обнулим rcx
    cycle:
        push rcx        ; поместим rcx в стек 

        sub rsp, 16     ; выделяем память для буфера перевода строк в числа
        sub rsp, 64     ; выделяем память для буфера ввода 
        
        read_string rsp, 64

        mov rcx, 0              ; rcx - индекс символа в строке, введенной пользователем
        mov rax, [rsp + 80]     ; поместим в rax номер текущей строки
        imul rax, 6             ; вычислим индекс элемента массива для записи при сквозной нумерации
        mov [rsp + 70], ax      ; [rsp + 70] - индекс элемента массива для записи
        mov rax, 0              ; rax - счётчик символов в буфере для перевода строк в числа
        while:
            cmp byte [rsp + rcx], 32        ; сравниваем символ в строке с пробелом
            jne not_space                   ; если не пробел, прыгаем на not_space
            jmp end_of_number               ; иначе прыгаем на end_of_number
            not_space:
                cmp byte [rsp + rcx], 10    ; сравниваем символ в строке с enter
                jne not_enter               ; если не enter, прыгаем на not_enter
                jmp end_of_number           ; иначе прыгаем на end_of_number
            not_enter:
                ; запоминаем символ в буфере
                mov bl, [rsp + rcx]         
                mov [rsp + 64 + rax], bl    ; перенос символа из исходной строки в буфер для перевода
                inc rax                     ; увеличиваем счётчик
                jmp continue                ; прыгаем на continue
            end_of_number:
                mov bl, 10                  
                mov [rsp + 64 + rax], bl    ; добавляем символ \n в буфер для перевода 
                lea rsi, [rsp + 64]         ; помещаем в rsi адрес буфера для перевода
                mov rbx, 0                  ; чтобы StrToInt нормально работал
                push rcx                    ; помещаем rcx в стек, потому что регистров не хватает, создатели ассемблера не подумали
                mov rcx, [rsp + 78]         ; помещаем в rcx индекс элемента массива для записи
                StrToInt [matrix + rcx*4]   ; преобразуем буфер в число и записываем в матрицу
                inc word [rsp + 78]         ; переходим к следующему элементу матрицы
                pop rcx                     ; вытаскиваем rcx из стека, потому что регистров не хватало и т.п....
                mov rax, 0                  ; обнуляем счётчик символов в буфере для перевода
                cmp byte [rsp + rcx], 10    ; сравниваем символ в строке с enter
                je break_while              ; если enter, то выходим из цикла
            continue:
                inc rcx                     ; переходим к следующему символу в строке
                jmp while                   ; переходим к следующей итерации цикла
            break_while:
        
        add rsp, 80     ; вернем стек к изначальному состоянию
        pop rcx         ; вытащим rcx из стека
        inc rcx         ; увеличиваем счётчик строк на 1
        cmp rcx, 3      ; если строка < 3 по счету, то переходим к следующей итерации
        jl cycle

    mov rcx, 0          ; обнулим счётчик внешнего цикла (rcx = i * 6, i = 0)
    cycle_print_matrix:     ; внешний цикл для строк
        push rcx            ; помещаем rcx в стек
        mov rcx, 6          ; количество итераций внутреннего цикла равно 6
        cycle_print_array:                      ; внутренний цикл для столбцов
            push rcx                            ; помещаем rcx в стек, запоминаем номер итерации
            neg rcx                             
            add rcx, 6                         
            add rcx, [rsp + 8]                  ; вычисляем индекс текущего элемента при сквозной нумерации
            IntToStr [matrix + rcx*4], OutBuf   ; переводим элемент массива в строку и записываем в OutBuf
            mov rbx, rax                        ; перекладываем длину строки в rbx, т.к. write_string работает с rax
            dec rbx                             ; удаляем символ перевода строки из строки
            write_string OutBuf, rbx            ; выводим один элемент матрицы
            mov rbx, 0                          ; обнуляем rbx
            write_string tab, 1                 ; дописываем \t к строке
            pop rcx                             ; вытаскиваем rcx из стека
            loop cycle_print_array

        write_string newLine, 1                 ; дописываем \n к строке

        pop rcx                     ; вытаскиваем rcx из стека, rcx = количество пройденных строк * 6
        add rcx, 6                  ; увеличиваем счетчик (rcx = i * 6, i++)
        cmp rcx, 18                 ; сравниваем счетчик для нахождения конца матрицы (18 = 3 * 6, 3 - количество строк в матрице)
        jl cycle_print_matrix       ; если счетчик меньше количества строк, переходим к следующей итерации
    
    ; ; вывод результата
    ; write_string AnsMsg, lenAns
    ; IntToStr    f, OutBuf
    ; mov rbx, rax            ; помещаем в регистр rbx длину выводимой строки
    ; write_string OutBuf, rbx
    
    ; завершение программы
    write_string ExitMsg, lenExit
    read_string InBuf, lenIn
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции
