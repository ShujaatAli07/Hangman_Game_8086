; ============================================================
;  HANGMAN  -  EMU8086 Edition
;  Pure text-mode (BIOS INT 10h) - runs inside EMU8086 screen
;  Assemble & Emulate in EMU8086, then press F5 / Run.
; ============================================================

org 100h

jmp start

; ---------- DATA ----------
words   db 'COMPUTER ', 'KEYBOARD ', 'MONITOR  ', 'PROGRAM  '
        db 'ASSEMBLY ', 'HANGMAN  ', 'PROCESSOR', 'SOFTWARE '
        db 'GRAPHICS ', 'PYRAMID  '
WCOUNT  equ 10
WLEN    equ 9

secret      db 9 dup('?'), 0     ; current word
display     db 9 dup('_'), 0     ; what player sees
guessed     db 26 dup(0)         ; A..Z flags
wrong       db 0                 ; wrong guesses
slen        db 0                 ; secret length
seed        dw 0

title_msg   db 'H A N G M A N   -   EMU8086',0
sub_msg     db 'Guess the word, one letter at a time!',0
word_lbl    db 'WORD : ',0
wrong_lbl   db 'WRONG: ',0
of6_msg     db ' / 6',0
used_lbl    db 'USED : ',0
prompt_msg  db 'Letter > ',0
win_msg     db '*** YOU WIN! Great job! ***',0
lose_msg    db '*** GAME OVER! The word was: ',0
again_msg   db 'Press R to play again, ESC to quit...',0
already_msg db '(already guessed)        ',0
notletter   db '(enter A-Z only)         ',0
clearline   db '                                        ',0
foot_msg    db 'ESC=Quit',0

; ---------- CODE ----------
start:
    ; seed RNG from BIOS ticks
    mov ah, 00h
    int 1Ah
    mov [seed], dx

new_game:
    call clear_screen
    call draw_frame
    call pick_word
    call reset_state
    call draw_static
    call draw_gallows
    call draw_word
    call draw_wrong
    call draw_used

game_loop:
    call get_letter        ; AL = uppercase letter, or 1Bh ESC
    cmp al, 1Bh
    je quit
    cmp al, 'A'
    jb bad_input
    cmp al, 'Z'
    ja bad_input

    mov bl, al
    sub bl, 'A'
    mov bh, 0
    mov si, offset guessed
    add si, bx
    cmp byte ptr [si], 0
    jne dup_input
    mov byte ptr [si], 1

    ; check letter against secret
    mov cx, 0
    mov cl, [slen]
    mov si, offset secret
    mov di, offset display
    mov bh, 0              ; hit flag
chk_loop:
    cmp byte ptr [si], al
    jne chk_next
    mov byte ptr [di], al
    mov bh, 1
chk_next:
    inc si
    inc di
    loop chk_loop

    cmp bh, 1
    je was_hit
    inc byte ptr [wrong]
was_hit:
    call draw_word
    call draw_wrong
    call draw_used
    call draw_gallows
    call clear_status

    ; win?
    call check_win
    cmp al, 1
    je you_win
    ; lose?
    cmp byte ptr [wrong], 6
    jae you_lose
    jmp game_loop

bad_input:
    mov dh, 22
    mov dl, 2
    mov si, offset notletter
    mov bl, 0Eh
    call print_at
    jmp game_loop

dup_input:
    mov dh, 22
    mov dl, 2
    mov si, offset already_msg
    mov bl, 0Eh
    call print_at
    jmp game_loop

you_win:
    mov dh, 22
    mov dl, 2
    mov si, offset win_msg
    mov bl, 0Ah
    call print_at
    jmp end_game

you_lose:
    call draw_gallows
    mov dh, 22
    mov dl, 2
    mov si, offset lose_msg
    mov bl, 0Ch
    call print_at
    ; print the word
    mov dh, 22
    mov dl, 32
    mov si, offset secret
    mov bl, 0Fh
    call print_at

end_game:
    mov dh, 23
    mov dl, 2
    mov si, offset again_msg
    mov bl, 0Bh
    call print_at
ask_again:
    mov ah, 00h
    int 16h
    cmp al, 1Bh
    je quit
    cmp al, 'r'
    je new_game
    cmp al, 'R'
    je new_game
    jmp ask_again

quit:
    call clear_screen
    mov ah, 4Ch
    int 21h

; ============ SUBROUTINES ============

; ---- clear screen, set 80x25 text ----
clear_screen proc
    mov ax, 0003h
    int 10h
    ; hide cursor
    mov ah, 01h
    mov cx, 2607h
    int 10h
    ret
clear_screen endp

; ---- draw outer frame & title bar ----
draw_frame proc
    ; fill background colored bar at top
    mov dh, 0
    mov dl, 0
    mov ah, 02h
    mov bh, 0
    int 10h
    ; title line  (blue background, white fg)
    mov cx, 80
    mov al, ' '
    mov bl, 1Fh
    mov ah, 09h
    int 10h
    ; print title centered
    mov dh, 0
    mov dl, 25
    mov si, offset title_msg
    mov bl, 1Fh
    call print_at
    ; subtitle
    mov dh, 1
    mov dl, 21
    mov si, offset sub_msg
    mov bl, 0Bh
    call print_at
    ; footer
    mov dh, 24
    mov dl, 0
    mov ah, 02h
    mov bh, 0
    int 10h
    mov cx, 80
    mov al, ' '
    mov bl, 70h
    mov ah, 09h
    int 10h
    mov dh, 24
    mov dl, 36
    mov si, offset foot_msg
    mov bl, 70h
    call print_at
    ret
draw_frame endp

; ---- print labels ----
draw_static proc
    mov dh, 14
    mov dl, 40
    mov si, offset word_lbl
    mov bl, 0Fh
    call print_at

    mov dh, 16
    mov dl, 40
    mov si, offset wrong_lbl
    mov bl, 0Fh
    call print_at

    mov dh, 18
    mov dl, 40
    mov si, offset used_lbl
    mov bl, 0Fh
    call print_at

    mov dh, 21
    mov dl, 2
    mov si, offset prompt_msg
    mov bl, 0Eh
    call print_at
    ret
draw_static endp

; ---- pick a random word ----
pick_word proc
    ; advance LCG
    mov ax, [seed]
    mov bx, 25173
    mul bx
    add ax, 13849
    mov [seed], ax
    ; index = ax mod WCOUNT
    xor dx, dx
    mov bx, WCOUNT
    div bx
    mov ax, dx                ; ax = word index 0..9
    mov bx, WLEN
    mul bx                    ; ax = offset
    mov si, offset words
    add si, ax
    mov di, offset secret
    mov cx, WLEN
    mov bx, 0                 ; len counter
copyw:
    mov al, [si]
    cmp al, ' '
    je skip_sp
    mov [di], al
    inc di
    inc bx
skip_sp:
    inc si
    loop copyw
    mov byte ptr [di], 0
    mov [slen], bl
    ret
pick_word endp

; ---- reset display, guessed, wrong ----
reset_state proc
    mov cx, 0
    mov cl, [slen]
    mov di, offset display
fill_under:
    mov byte ptr [di], '_'
    inc di
    loop fill_under
    mov byte ptr [di], 0

    mov cx, 26
    mov di, offset guessed
zero_g:
    mov byte ptr [di], 0
    inc di
    loop zero_g

    mov byte ptr [wrong], 0
    ret
reset_state endp

; ---- draw word with spaces between letters ----
draw_word proc
    mov dh, 14
    mov dl, 47
    mov cx, 0
    mov cl, [slen]
    mov si, offset display
dw_loop:
    push cx
    mov al, [si]
    mov bl, 0Ah
    cmp al, '_'
    jne dw_color
    mov bl, 08h
dw_color:
    mov ah, 02h
    mov bh, 0
    int 10h
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    inc dl
    mov ah, 02h
    mov bh, 0
    int 10h
    mov al, ' '
    mov bl, 07h
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    inc dl
    inc si
    pop cx
    loop dw_loop
    ret
draw_word endp

; ---- draw wrong count ----
draw_wrong proc
    mov dh, 16
    mov dl, 47
    mov ah, 02h
    mov bh, 0
    int 10h
    mov al, [wrong]
    add al, '0'
    mov bl, 0Ch
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    mov dh, 16
    mov dl, 48
    mov si, offset of6_msg
    mov bl, 07h
    call print_at
    ret
draw_wrong endp

; ---- draw used letters list ----
draw_used proc
    mov dh, 18
    mov dl, 47
    mov ah, 02h
    mov bh, 0
    int 10h
    mov si, offset clearline
    mov bl, 07h
    push dx
    mov ah, 13h
    mov bp, si
    mov cx, 30
    mov al, 0
    int 10h
    pop dx
    mov dh, 18
    mov dl, 47
    mov cx, 26
    mov bx, 0
ul_loop:
    push cx
    push bx
    mov si, offset guessed
    add si, bx
    cmp byte ptr [si], 0
    je ul_skip
    mov ah, 02h
    mov bh, 0
    int 10h
    mov al, bl
    add al, 'A'
    mov bl, 0Eh
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    inc dl
    mov ah, 02h
    mov bh, 0
    int 10h
    mov al, ' '
    mov bl, 07h
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    inc dl
ul_skip:
    pop bx
    pop cx
    inc bx
    loop ul_loop
    ret
draw_used endp

; ---- get a key, return uppercase in AL ----
get_letter proc
    mov dh, 21
    mov dl, 11
    mov ah, 02h
    mov bh, 0
    int 10h
    mov al, ' '
    mov bl, 0Fh
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h

    mov ah, 00h
    int 16h
    cmp al, 1Bh
    je gl_done
    cmp al, 'a'
    jb gl_upper
    cmp al, 'z'
    ja gl_upper
    sub al, 32
gl_upper:
    push ax
    mov dh, 21
    mov dl, 11
    mov ah, 02h
    mov bh, 0
    int 10h
    pop ax
    push ax
    mov bl, 0Fh
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    pop ax
gl_done:
    ret
get_letter endp

; ---- check win: any '_' in display? ----
check_win proc
    mov cx, 0
    mov cl, [slen]
    mov si, offset display
cw_loop:
    cmp byte ptr [si], '_'
    je cw_no
    inc si
    loop cw_loop
    mov al, 1
    ret
cw_no:
    mov al, 0
    ret
check_win endp

; ---- clear status line 22 ----
clear_status proc
    mov dh, 22
    mov dl, 2
    mov si, offset clearline
    mov bl, 07h
    call print_at
    ret
clear_status endp

; ---- draw gallows + body parts ----
; Position: rows 4..13, cols 4..18
draw_gallows proc
    ; base
    mov dh, 13
    mov dl, 4
    mov si, offset g_base
    mov bl, 06h
    call print_at
    mov dh, 12
    mov dl, 4
    mov si, offset g_pole
    mov bl, 06h
    call print_at
    mov dh, 11
    mov dl, 4
    mov si, offset g_pole
    mov bl, 06h
    call print_at
    mov dh, 10
    mov dl, 4
    mov si, offset g_pole
    mov bl, 06h
    call print_at
    mov dh, 9
    mov dl, 4
    mov si, offset g_pole
    mov bl, 06h
    call print_at
    mov dh, 8
    mov dl, 4
    mov si, offset g_pole
    mov bl, 06h
    call print_at
    mov dh, 7
    mov dl, 4
    mov si, offset g_pole
    mov bl, 06h
    call print_at
    mov dh, 6
    mov dl, 4
    mov si, offset g_pole
    mov bl, 06h
    call print_at
    mov dh, 5
    mov dl, 4
    mov si, offset g_pole
    mov bl, 06h
    call print_at
    mov dh, 4
    mov dl, 4
    mov si, offset g_top
    mov bl, 06h
    call print_at
    mov dh, 5
    mov dl, 14
    mov si, offset g_rope
    mov bl, 0Eh
    call print_at

    ; clear figure area first (rows 6..12, cols 12..18)
    mov dh, 6
gd_clr:
    mov dl, 12
    mov ah, 02h
    mov bh, 0
    int 10h
    mov al, ' '
    mov bl, 07h
    mov ah, 09h
    mov bh, 0
    mov cx, 7
    int 10h
    inc dh
    cmp dh, 13
    jb gd_clr

    ; draw parts based on wrong count
    mov al, [wrong]
    cmp al, 1
    jb gd_done
    ; head
    mov dh, 6
    mov dl, 13
    mov si, offset p_head
    mov bl, 0Eh
    call print_at
    cmp al, 2
    jb gd_done
    ; body
    mov dh, 7
    mov dl, 14
    mov si, offset p_body1
    mov bl, 0Bh
    call print_at
    mov dh, 8
    mov dl, 14
    mov si, offset p_body1
    mov bl, 0Bh
    call print_at
    cmp al, 3
    jb gd_done
    ; left arm
    mov dh, 7
    mov dl, 13
    mov al, '/'
    mov bl, 0Bh
    call putc_at
    cmp byte ptr [wrong], 4
    jb gd_done
    ; right arm
    mov dh, 7
    mov dl, 15
    mov al, '\'
    mov bl, 0Bh
    call putc_at
    cmp byte ptr [wrong], 5
    jb gd_done
    ; left leg
    mov dh, 9
    mov dl, 13
    mov al, '/'
    mov bl, 0Bh
    call putc_at
    cmp byte ptr [wrong], 6
    jb gd_done
    ; right leg
    mov dh, 9
    mov dl, 15
    mov al, '\'
    mov bl, 0Bh
    call putc_at
    ; X eyes when dead
    mov dh, 6
    mov dl, 13
    mov si, offset p_dead
    mov bl, 0Ch
    call print_at
gd_done:
    ret
draw_gallows endp

g_base  db '==============',0
g_pole  db '|',0
g_top   db '|------+',0
g_rope  db '|',0
p_head  db ' (O) ',0
p_body1 db '|',0
p_dead  db ' XOX ',0

; ---- print ASCIIZ at DH,DL with attribute BL ----
print_at proc
    push ax
    push bx
    push cx
    push dx
    push si
pa_loop:
    mov al, [si]
    cmp al, 0
    je pa_end
    push si
    push dx
    mov ah, 02h
    mov bh, 0
    int 10h
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    pop dx
    pop si
    inc si
    inc dl
    jmp pa_loop
pa_end:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_at endp

; ---- put single char AL at DH,DL with attribute BL ----
putc_at proc
    push ax
    push cx
    push dx
    push bx
    mov ah, 02h
    mov bh, 0
    int 10h
    pop bx
    push bx
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    pop bx
    pop dx
    pop cx
    pop ax
    ret
putc_at endp

end start
