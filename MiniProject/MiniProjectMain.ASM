format PE console
entry start

include 'win32a.inc' ; Подключаем библиотеку

section '.data' data readable writable
        ScanInt db '%d', 0 ; Строка форматирования для чисел
        titleNumber db "Please, enter a number in range [2;65536]: ", 0 ; строка обращения к пользователю - ввод машинного слова
        printNumber db "General number of prime & fibbo numbers in range [1;%d] = %d",0 ; строка ответа на задачу (ответ зависит от машинного слова)

        inputInfo db "Your number is %d. (y/n)",10, 0  ; строка уточнения введенного числа
        numberFibboPrime dd 0 ; переменная - колво простых чисел среди чисел Фибоначии в диапозоне [1; машинное слово]
        startNumber dd 2

        lastFibbo dd 1
        prelastFibbo dd 1

        number dd ?

section '.code' code readable executable
start:
        ; read data from user
        call inputData
        ; count number of prime digits that are in fibbo sequence
        call getCount
finish:
        push dword[numberFibboPrime]
        push [number]
        push printNumber
        call [printf]

        call [getch]

        push 0
        call [ExitProcess]
;-------------------------------------
inputData:
        push titleNumber
        call [printf]
        add esp, 4

        push number
        push ScanInt
        call [scanf]
        add esp, 8

        mov eax, 2
        cmp eax, [number]
        jg inputData

        cmp [number], 65536
        jg inputData

        call checkInput
        ret
checkInput:
        push [number]
        push inputInfo
        call [printf]
        add esp, 8

        call [getch]

        cmp eax, 121
        je endInput

        cmp eax, 110
        je inputData

        call checkInput
endInput:
        ret
;-------------------------------------
getCount:

        mov eax, [lastFibbo]
        mov ebx, [prelastFibbo]
        add [lastFibbo], ebx
        mov [prelastFibbo], eax
        mov eax, [lastFibbo]
        cmp eax, [number]
        jg finish
        add [numberFibboPrime], 1
        mov [startNumber], 2
        call primeCheckFunc
        ret
;-------------------------------------
primeCheckFunc:
        mov ecx, dword [lastFibbo]
        cmp [startNumber], ecx
        jl primeCheck
        call getCount
primeCheck:
        mov edx, 0
        mov eax, 0

        mov eax, ecx
        div [startNumber]
        cmp dx, 0
        je a
        add [startNumber], 1
        call primeCheckFunc
a:
        sub [numberFibboPrime], 1
        call getCount
;-------------------------------------
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll'

    import kernel,\
           ExitProcess, 'ExitProcess'

    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'

