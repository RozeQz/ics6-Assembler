global _Z7analyzePcPi
extern _Z19find_most_freq_symbPi

    section .data           ; сегмент инициализированных переменных
    section .bss            ; сегмент неинициализированных переменных
    section .text
    _Z7analyzePcPi:
        ; пролог
        push rbp            ; сохраняем содержимое rbx в стек
        mov rbp, rsp        ; смещаем базу стека

        sub rsp, 8          ; по конвенции стек должен быть выровнен по 16 байт
        push rdi            ; помещаем адрес начала текста в стек
        push rsi            ; помещаем адрес первого элемента массива целых чисел в стек
        push rbx            ; помещаем rbx в стек

        cld                 ; сброс флага DF - обработка текста от начала к концу
        mov rcx, 255        ; счётчик
        mov rsi, rdi            ; rsi = адрес начала текста, потому что lodsb наботает в rsi
        mov rbx, [rbp - 24]     ; rbx = rsi
        mov rax, 0              ; rax = 0
        cycle:                  ; проходимся по всем символам текста
            lodsb                       ; копируем 1 байт из si в al
            inc dword [rbx + rax * 4]   ; mas[symbol]++
            loop cycle   AA               ; переходим к следующей итерации

        mov rdi, [rbp - 24]             ; rdi = адрес начала массива целых чисел
        call _Z19find_most_freq_symbPi  ; вызываем процедуру

        ; эпилог
        mov rsp, rbp        ; очищаем локальные переменные
        pop rbp             ; восстанавливаем базу стека
        ret
