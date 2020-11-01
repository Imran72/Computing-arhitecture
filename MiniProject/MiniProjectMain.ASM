; Работу выполнил Тимканов Имран БПИ193


format PE console
entry start

include 'win32a.inc' ; Подключаем библиотеку

section '.data' data readable writable
        ScanInt db '%d', 0 ; Строка форматирования для чисел
        titleNumber db "Please, enter a number in range [2;65536]: ", 0 ; строка обращения к пользователю - ввод машинного слова
        printNumber db "General number of prime & fibbo numbers in range [1;%d] = %d",0 ; строка ответа на задачу (ответ зависит от машинного слова)

        inputInfo db "Your number is %d. (y/n)",10, 0  ; строка уточнения введенного числа
        numberFibboPrime dd 0 ; переменная - колво простых чисел среди чисел Фибоначии в диапозоне [1; машинное слово]
        startNumber dd 2   ; стартовое число для проверки на простоту

        lastFibbo dd 1 ; предпоследнее рассматриваемое число Фибоначчи
        prelastFibbo dd 1  ; последнее рассматриваемое число Фибоначчи

        number dd ? ; машинное слово веденное пользователем

section '.code' code readable executable
start:
        ; read data from user
        call inputData
        ; count number of prime digits that are in fibbo sequence
        call getCount
finish:
        ; Ввыод ответа на задачу
        push dword[numberFibboPrime]
        push [number]     ; число чисел
        push printNumber  ; строка форматирование
        call [printf]

        call [getch]

        push 0
        call [ExitProcess]
;-------------------------------------
inputData:
        push titleNumber  ; вывод информации для пользователя
        call [printf]
        add esp, 4

        push number ; считывание числа с консоли
        push ScanInt
        call [scanf]
        add esp, 8

        mov eax, 2
        cmp eax, [number]  ; проверка на соответствие - число не может быть < 2. Иначе задача теряет смысл
        jg inputData ; повтор ввода числа

        cmp [number], 65536  ; проверка на соответствие машинному слову - машинное слово 2 байта = 2^16 = 65536 - максимальное значение
        jg inputData  ; повтор ввода числа

        call checkInput
        ret
checkInput:
        push [number]   ; удостоверимся в том, что пользователь ввел то, что хотел
        push inputInfo
        call [printf]
        add esp, 8

        call [getch]   ; считывание одного символа

        cmp eax, 121   ; введет y - все верно
        je endInput

        cmp eax, 110  ; введет n - повторим считывание
        je inputData

        call checkInput  ; введет что-либо другое - повторим свое обращение
endInput:
        ret
;-------------------------------------
getCount:

        mov eax, [lastFibbo]  ; сохраним последнее число Фибоначчи в регистр eax
        mov ebx, [prelastFibbo] ; сохраним предпоследнее число Фибоначчи в регист ebx
        add [lastFibbo], ebx ; вычислим следующее число Фибоначи
        mov [prelastFibbo], eax  ;  предпоследнее --> последнее, последнее --> следующее
        mov eax, [lastFibbo]
        cmp eax, [number]  ; сравним рассматриваемо число Фибоначчи и максимальное число - если оно больше, то заканчиваем
        jg finish
        add [numberFibboPrime], 1 ; априорно допустим, что рассматриваемое число соответствует
        mov [startNumber], 2
        call primeCheckFunc  ; рассмотрим все числа от start number - делят его или нет
        ret
;-------------------------------------
primeCheckFunc:
        mov ecx, dword [lastFibbo]
        cmp [startNumber], ecx   ; проверяем строго от 2 до самого числа - 1. Если хоть одно число будет делить - то исходное число не просте
        jl primeCheck
        call getCount    ; повторим вновь
primeCheck:
        mov edx, 0
        mov eax, 0

        mov eax, ecx    ; в регистр  eax  положим рассматриваемое на простоту число
        div [startNumber] ; поделить рассматриваемое число на текущий делитель. Остаток пойдет в регистр dx
        cmp dx, 0  ; Если остаток 0 --> число точно не простое, тогда переходим в метку "а"
        je a
        add [startNumber], 1
        call primeCheckFunc
a:
        sub [numberFibboPrime], 1 ; вычитаем единицу, которую прибавили априорно, поскольку убедились в обратном нашему предположению
        call getCount  ; возвращаемся в  getCount, где рассматриваем другое число
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

