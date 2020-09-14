format pe Console
entry  start

include 'win32ax.inc'

section '.data' data readable writeable

        query db "Enter number which will be multiply on 5:", 0
        num db '%d', 0
        output db '%d', 0
        n dd 0

 section '.idata' import data readable writeable
         library kernel32,'kernel32.dll',\
                 msvcrt,'msvcrt.dll'

         import  kernel32,\
                 ExitProcess,'ExitProcess'

         import  msvcrt,\
                 printf,'printf',\
                 getch,'_getch',\
                 scanf, 'scanf'

section '.code' code readable executable

        start:
                push query
                call [printf]

                push n
                push num
                call [scanf]

                mov eax, 5
                mov ebx, [n]

                mul ebx

                push eax
                push output
                call [printf]
                call [getch]
                call [ExitProcess]


