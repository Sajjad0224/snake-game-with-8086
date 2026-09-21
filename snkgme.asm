.model small
.stack 100h

.data
snakeX db 100 dup(0)
snakeY db 100 dup(0)
length db 3
dir db 'd'
foodX db 20
foodY db 10
score db 0
gameovermsg db 'GAME OVER$'

.code

main proc

    mov ax,@data
    mov ds,ax

    mov ax,03h
    int 10h

    mov snakeX[0],40
    mov snakeY[0],12

    mov snakeX[1],39
    mov snakeY[1],12

    mov snakeX[2],38
    mov snakeY[2],12

mainloop:
    call delay
    call input
    call moveSnake
    call checkFood
    call checkCollision
    call draw
    jmp mainloop


; ----------------
; DELAY
; Speed increased approximately 2x
; ----------------
delay proc

    mov cx,4           ; was 8, now 4 = approximately 2x faster

outer:
    push cx

    mov cx,0FFFFh

inner:
    loop inner

    pop cx
    loop outer

    ret

delay endp


; ----------------
; INPUT
; ----------------
input proc

    mov ah,01h
    int 16h

    jz noKey

    mov ah,00h
    int 16h

    cmp al,'w'
    je chkW

    cmp al,'a'
    je chkA

    cmp al,'s'
    je chkS

    cmp al,'d'
    je chkD

    jmp noKey


chkW:
    cmp dir,'s'         ; prevent reversing
    je noKey

    mov dir,'w'
    jmp noKey


chkA:
    cmp dir,'d'
    je noKey

    mov dir,'a'
    jmp noKey


chkS:
    cmp dir,'w'
    je noKey

    mov dir,'s'
    jmp noKey


chkD:
    cmp dir,'a'
    je noKey

    mov dir,'d'


noKey:
    ret

input endp


; ----------------
; MOVE SNAKE
; ----------------
moveSnake proc

    mov cl,length
    dec cl

shiftLoop:

    mov bx,cx

    dec bx

    mov al,snakeX[bx]
    mov snakeX[bx+1],al

    mov al,snakeY[bx]
    mov snakeY[bx+1],al

    loop shiftLoop


    cmp dir,'w'
    je up

    cmp dir,'s'
    je down

    cmp dir,'a'
    je left

    cmp dir,'d'
    je right

    ret


up:
    dec snakeY[0]
    jmp wrapY


down:
    inc snakeY[0]
    jmp wrapY


left:
    dec snakeX[0]
    jmp wrapX


right:
    inc snakeX[0]
    jmp wrapX


; ----------------
; WRAP X
; ----------------
wrapX:

    ; if snakeX[0] == 255
    ; went left of 0, wrap to 79

    mov al,snakeX[0]

    cmp al,255
    jne chkRight

    mov snakeX[0],79

    jmp moveEnd


chkRight:

    cmp al,80
    jl moveEnd

    mov snakeX[0],0

    jmp moveEnd


; ----------------
; WRAP Y
; ----------------
wrapY:

    ; if snakeY[0] == 255
    ; went above 0, wrap to 24

    mov al,snakeY[0]

    cmp al,255
    jne chkDown

    mov snakeY[0],24

    jmp moveEnd


chkDown:

    cmp al,25
    jl moveEnd

    mov snakeY[0],0


moveEnd:
    ret

moveSnake endp


; ----------------
; CHECK FOOD
; ----------------
checkFood proc

    mov al,snakeX[0]

    cmp al,foodX
    jne foodEnd

    mov al,snakeY[0]

    cmp al,foodY
    jne foodEnd

    inc length
    inc score

    add foodX,11

    mov al,foodX

    cmp al,79
    jle fycheck

    sub foodX,79


fycheck:

    add foodY,7

    mov al,foodY

    cmp al,24
    jle foodEnd

    sub foodY,24


foodEnd:
    ret

checkFood endp


; ----------------
; CHECK COLLISION
; ----------------
checkCollision proc

    mov cl,length
    mov si,1


collLoop:

    cmp si,cx
    jge collEnd

    mov al,snakeX[0]

    cmp al,snakeX[si]
    jne next

    mov al,snakeY[0]

    cmp al,snakeY[si]
    jne next

    jmp gameover


next:

    inc si

    jmp collLoop


collEnd:
    ret

checkCollision endp


; ----------------
; DRAW
; ----------------
draw proc

    mov ax,03h
    int 10h

    mov cl,length
    mov si,0


drawLoop:

    mov ah,02h
    mov bh,0

    mov dh,snakeY[si]
    mov dl,snakeX[si]

    int 10h

    mov ah,02h
    mov dl,'O'

    int 21h

    inc si

    loop drawLoop


    ; draw food

    mov ah,02h
    mov bh,0

    mov dh,foodY
    mov dl,foodX

    int 10h

    mov ah,02h
    mov dl,'*'

    int 21h

    ret

draw endp


; ----------------
; GAME OVER
; ----------------
gameover:

    mov ax,03h
    int 10h

    mov ah,09h

    lea dx,gameovermsg

    int 21h

    mov ah,4ch
    int 21h


main endp

end main