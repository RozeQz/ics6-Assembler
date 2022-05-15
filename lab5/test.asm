global _Z7analyzePcPi

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
            loop cycle                  ; переходим к следующей итерации

        pop rbx             ; возвращаем rbx из стека
        pop rsi             ; возвращаем rbx из стека
        pop rdi             ; возвращаем rbx из стека
        add rsp, 8          ; выравнимаем стек по конценции

        ; эпилог
        mov rsp, rbp        ; очищаем локальные переменные
        pop rbp             ; восстанавливаем базу стека
        ret
