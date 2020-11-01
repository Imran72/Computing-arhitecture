; Работу выполнил Тимканов Имран БПИ193


format PE console
entry start

include 'win32a.inc' ; Подключаем библиотеку

section '.data' data readable writable
        ScanInt db '%u',10, 0
        printNumber db "General number of prime & fibbo numbers in range [1;%u] = %u;",0 ; строка ответа на задачу (ответ зависит от машинного слова)

        numberFibboPrime dd 0 ; переменная - колво простых чисел среди чисел Фибоначии в диапозоне [1; машинное слово]
        startNumber dd 2   ; стартовое число для проверки на простоту

        lastFibbo dd 1 ; предпоследнее рассматриваемое число Фибоначчи
        prelastFibbo dd 1  ; последнее рассматриваемое число Фибоначчи
        tmp dd 1

        number dd ?; машинное слово веденное пользователем

section '.code' code readable executable
start:
        mov [number], 65536  ; 2^16 = машинное слово

        ; count number of prime digits that are in fibbo sequence
        call getCount
finish:
        call [getch]

        push 0
        call [ExitProcess]
;-------------------------------------
getCount:
        mov ebx, [lastFibbo]  ; сохраним последнее число Фибоначчи в регистр eax
        add ebx, [prelastFibbo] ; сохраним предпоследнее число Фибоначчи в регист ebx
        mov [tmp], ebx        ;  перезаписываем в переменную временного хранилища

        mov eax, [number]
        cmp eax, [tmp] ; сравним рассматриваемо число Фибоначчи и максимальное число - если оно больше, то заканчиваем
        jl outputInfo             ; вывод информации завершение

        mov edx, [lastFibbo]    ; перезапись в регистр
        mov [prelastFibbo], edx  ; prelast -- last
        mov edx, [tmp]
        mov [lastFibbo], edx   ; last -- новый


        add [numberFibboPrime], 1       ; апостариорно добавим
        mov [startNumber], 2                                  ; назначим первое число проверки
        jmp primeCheckFunc
;-------------------------------------
primeCheckFunc:
        mov ecx, [lastFibbo]
        cmp [startNumber], ecx   ; проверяем строго от 2 до самого числа - 1. Если хоть одно число будет делить - то исходное число не просте
        jb  primeCheck
        jmp getCount    ; повторим вновь
primeCheck:
        mov dx, 0
        mov ax, 0

        mov dx, word [lastFibbo+2]
        mov ax, word [lastFibbo]    ; в регистр  eax  положим рассматриваемое на простоту число
        div [startNumber] ; поделить рассматриваемое число на текущий делитель. Остаток пойдет в регистр dx

        cmp dx, 0  ; Если остаток 0 --> число точно не простое, тогда переходим в метку "а"
        je a
        add [startNumber], 1
        jmp primeCheckFunc
a:
        sub [numberFibboPrime], 1 ; вычитаем единицу, которую прибавили априорно, поскольку убедились в обратном нашему предположению
        jmp getCount  ; возвращаемся в  getCount, где рассматриваем другое число
;-------------------------------------
outputInfo:
        ; вывод ответа на задачу
        push [numberFibboPrime]
        push [number]    ; число чисел
        push printNumber  ; строка форматирование
        call [printf]
        add esp, 8
        call finish
;-------------------------------------
section '.idata' import data readable  ; подключаем все библиотеки
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll'

    import kernel,\
           ExitProcess, 'ExitProcess'

    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'

