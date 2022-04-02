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
InputMsg    db      "Enter the martix 5x5:", 10
lenInput    equ     $-InputMsg
OutputMsg   db      "Your matrix after conversion:", 10
lenOutput   equ     $-OutputMsg
tab         db      9
newLine     db      10

    section .bss            ; сегмент неинициализированных переменных
InBuf   resb    10          ; буфер для вводимой строки
lenIn   equ     $-InBuf     ; длина буфера для вводимой строки
OutBuf  resb    10
lenOut  equ     $-OutBuf
matrix  resd    25          ; 5 * 5 = 25 => резервируем 25 элементов для матрицы
sum     resd    1           

    section .text           ; сегмент кода
    global _start

_start:

    write_string InputMsg, lenInput

    ; ввод матрицы
    mov rcx, 0          ; обнуляем счётчик внешнего цикла
    cycle_read_matrix:
        push rcx        ; помещаем rcx в стек 

        sub rsp, 16     ; выделяем память для буфера перевода строк в числа и счетчик (6 - буфер, 2 -счетчик)
        sub rsp, 64     ; выделяем память для буфера ввода 
        
        read_string rsp, 64

        mov rcx, 0              ; rcx - индекс символа в строке, введенной пользователем
        mov rax, [rsp + 80]     ; поместим в rax номер текущей строки (80 т.к. 64+16 = 80)
        imul rax, 5             ; вычислим индекс элемента массива для записи при сквозной нумерации
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
        cmp rcx, 5      ; если строка < 5 по счету, то переходим к следующей итерации
        jl cycle_read_matrix


    ; вычисления
    mov rcx, 0              ; обнуляем счётчик внешнего цикла
    cycle_row:              ; внешний цикл для строк
        push rcx            ; помещаем rcx в стек (номер текущей строки - 1)
        mov rbx, 0          
        mov [sum], rbx      ; изначально сумма равна 0
        mov rcx, 5          ; количество итерации внешнего цикла равно 5
        cycle_col:                      ; внутренний цикл для столбцов
            push rcx                    ; помещаем rcx в стек (счётчик итераций)
            push rbx                    ; помещаем rbx в стек (индекс элемента в строке)
            mov rbx, [rsp + 16]         ; rbx = номер текущей строки - 1
            imul rbx, 5                 ; rbx = (номер текущей строки - 1) * 5, т.к. в строке 5 элементов
            add rbx, [rsp]              ; rbx = rbx + индекс элемента в строке
            mov eax, [matrix + rbx*4]   ; eax = matrix[rbx], умножаем на 4, т.к. dword
            pop rbx                     ; вытаскиваем rbx из стека (индекс элемента в строке)
            inc rbx                     ; переходим к следующему элементу строки
            add eax, [sum]              ; eax = eax + sum
            mov [sum], eax              ; sum = eax
            pop rcx                     ; вытаскиваем rcx из стека (счётчик итераций)
            loop cycle_col              ; переходим к следующей итерации внутреннего цикла
        mov cx, 5                   ; в строке по 5 элементов
        mov eax, [sum]              ; eax = конечная сумма строки
        idiv cx                     ; eax = среднеарифметическое строки
        pop rcx                     ; вытаскиваем rcx из стека (номер текущей строки - 1)
        mov rbx, rcx                ; rbx = номер текущей строки - 1
        imul rbx, 5                 ; rbx = (номер текущей строки - 1) * 5
        add rbx, rcx                ; rbx = индекс элемента матрицы, совпадающий с номером строки, в которой он находится
        mov [matrix + rbx*4], eax   ; matrix[rbx] = произведение строки
        mov rbx, 0                  ; обнуляем rbx
        inc rcx                     ; увеличиваем счетчик итераций внешнего цикла
        cmp rcx, 5                  ; сравниваем счётчик с 5
        jl cycle_row                ; если итераций меньше 5, прыгаем на cycle_row


    write_string OutputMsg, lenOutput

    ;вывод матрицы
    mov rcx, 0              ; обнулим счётчик внешнего цикла (rcx = i * 5, i = 0)
    cycle_print_matrix:     ; внешний цикл для строк
        push rcx            ; помещаем rcx в стек
        mov rcx, 5          ; количество итераций внутреннего цикла равно 5
        cycle_print_array:                      ; внутренний цикл для столбцов
            push rcx                            ; помещаем rcx в стек, запоминаем номер итерации
            neg rcx                             
            add rcx, 5                         
            add rcx, [rsp + 8]                  ; вычисляем индекс текущего элемента при сквозной нумерации (+8, т.к. до этого было 2 пуша)
            IntToStr [matrix + rcx*4], OutBuf   ; переводим элемент массива в строку и записываем в OutBuf
            mov rbx, rax                        ; перекладываем длину строки в rbx, т.к. write_string работает с rax
            dec rbx                             ; удаляем символ перевода строки из строки
            write_string OutBuf, rbx            ; выводим один элемент матрицы
            mov rbx, 0                          ; обнуляем rbx
            write_string tab, 1                 ; дописываем \t к строке
            pop rcx                             ; вытаскиваем rcx из стека
            loop cycle_print_array

        write_string newLine, 1                 ; дописываем \n к строке

        pop rcx                     ; вытаскиваем rcx из стека, rcx = количество пройденных строк * 5
        add rcx, 5                  ; увеличиваем счетчик (rcx = i * 5, i++)
        cmp rcx, 25                 ; сравниваем счетчик для нахождения конца матрицы (25 = 5 * 5, 5 - количество строк в матрице)
        jl cycle_print_matrix       ; если счетчик меньше количества строк, переходим к следующей итерации
    
    
    ; завершение программы
    write_string ExitMsg, lenExit
    read_string InBuf, lenIn
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции