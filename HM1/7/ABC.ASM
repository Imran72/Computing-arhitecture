format pe Console
entry  start

include 'win32ax.inc'

section '.data' data readable writeable

        query db "Enter number:", 0
        num db '%d', 0
        output db '%d! = %d', 0
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

                mov eax, 1
                mov ebx, [n]

                lp:
                        mul ebx
                        dec ebx
                        cmp ebx, 0
                        jg lp
                push eax
                push [n]
                push output
                call [printf]
                call [getch]
                call [ExitProcess]


