.model small
.stack 100h

.data
    ; --- UI Elements ---
    ui_top      db "================================================================================", 13, 10
                db " LEVEL: $"
    ui_score    db "       SCORE: $"
    ui_rank     db "       RANK: $"
    ui_bot      db 13, 10, "================================================================================", 13, 10, "$"
    
    rank_1      db "NOVICE$"
    rank_2      db "HACKER$"
    rank_3      db "WIZARD$"

    prompt      db 13, 10, 13, 10, "Enter your guess: $"
    msg_win     db 13, 10, 13, 10, ">>> LEVEL CLEARED! +10 Points. Press any key...$"
    msg_lose    db 13, 10, 13, 10, ">>> GAME OVER! Press any key to exit...$"
    msg_word    db 13, 10, "The word was: $"

    ; --- Game Logic Variables ---
    level       dw 1
    score       dw 0
    mistakes    db 0
    
    active_word db 15 dup('$')      ; Holds the currently selected word
    word_len    dw 0                ; Length of active word
    guess       db 15 dup('_')      ; Tracks user progress

    ; --- Word Banks (3 words per level, '$' terminated) ---
    ; Level 1: 3-4 letters
    l1_w1 db "RAM$"
    l1_w2 db "CPU$"
    l1_w3 db "BYTE$"
    l1_ptrs dw offset l1_w1, offset l1_w2, offset l1_w3

    ; Level 2: 5-6 letters
    l2_w1 db "LOGIC$"
    l2_w2 db "MACRO$"
    l2_w3 db "MEMORY$"
    l2_ptrs dw offset l2_w1, offset l2_w2, offset l2_w3

    ; Level 3: 7+ letters
    l3_w1 db "REGISTER$"
    l3_w2 db "COMPILER$"
    l3_w3 db "HARDWARE$"
    l3_ptrs dw offset l3_w1, offset l3_w2, offset l3_w3

    ; --- ASCII Art Stages ---
    str0 db 13,10,"      +---+", 13,10,"      |   |", 13,10,"          |", 13,10,"          |", 13,10,"          |", 13,10,"          |", 13,10,"    =========$"
    str1 db 13,10,"      +---+", 13,10,"      |   |", 13,10,"      O   |", 13,10,"          |", 13,10,"          |", 13,10,"          |", 13,10,"    =========$"
    str2 db 13,10,"      +---+", 13,10,"      |   |", 13,10,"      O   |", 13,10,"      |   |", 13,10,"          |", 13,10,"          |", 13,10,"    =========$"
    str3 db 13,10,"      +---+", 13,10,"      |   |", 13,10,"      O   |", 13,10,"     /|   |", 13,10,"          |", 13,10,"          |", 13,10,"    =========$"
    str4 db 13,10,"      +---+", 13,10,"      |   |", 13,10,"      O   |", 13,10,"     /|\  |", 13,10,"          |", 13,10,"          |", 13,10,"    =========$"
    str5 db 13,10,"      +---+", 13,10,"      |   |", 13,10,"      O   |", 13,10,"     /|\  |", 13,10,"     /    |", 13,10,"          |", 13,10,"    =========$"
    str6 db 13,10,"      +---+", 13,10,"      |   |", 13,10,"      O   |", 13,10,"     /|\  |", 13,10,"     / \  |", 13,10,"          |", 13,10,"    =========$"
    hangman_ptrs dw str0, str1, str2, str3, str4, str5, str6

.code
main proc
    mov ax, @data
    mov ds, ax

start_level:
    mov mistakes, 0         ; Reset mistakes for new level
    call load_random_word   ; Pick a word based on level

game_loop:
    call clear_screen
    call draw_ui

    ; Print Current Hangman State
    mov bl, mistakes
    xor bh, bh
    shl bx, 1               
    mov dx, hangman_ptrs[bx] 
    mov ah, 09h
    int 21h

    ; Spacing
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    call print_guess
    call check_win
    cmp al, 1
    je level_won

    cmp mistakes, 6
    jge game_lost

    ; Prompt User for Guess
    mov dx, offset prompt
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h

    ; Convert lowercase to uppercase
    cmp al, 'a'
    jl process_guess
    cmp al, 'z'
    jg process_guess
    sub al, 32              

process_guess:
    mov cx, word_len
    mov si, offset active_word
    mov di, offset guess
    mov bl, 0               ; Match flag
    
check_loop:
    mov ah, [si]            
    cmp ah, al              
    jne no_match            
    mov [di], al            
    mov bl, 1               
no_match:
    inc si
    inc di
    loop check_loop

    cmp bl, 1               
    je next_turn
    inc mistakes            
next_turn:
    jmp game_loop

level_won:
    mov dx, offset msg_win
    mov ah, 09h
    int 21h
    
    ; Add Score and Level Up
    add score, 10
    cmp level, 3
    je cap_level
    inc level
cap_level:
    ; Wait for keypress
    mov ah, 07h
    int 21h
    jmp start_level

game_lost:
    mov dx, offset msg_lose
    mov ah, 09h
    int 21h
    
    mov dx, offset msg_word
    mov ah, 09h
    int 21h
    
    mov dx, offset active_word
    mov ah, 09h
    int 21h

    ; Wait for keypress
    mov ah, 07h
    int 21h

end_game:
    mov ah, 4ch
    int 21h
main endp

; --- PROCEDURE: Load Random Word Based on Level ---
load_random_word proc
    ; 1. Get random number 0-2
    mov ah, 00h
    int 1Ah                 ; Get system timer (CX:DX)
    mov ax, dx              ; Use lower part of ticks
    mov dx, 0
    mov cx, 3               ; 3 words per level
    div cx                  ; AX / 3 -> Remainder in DX (0, 1, or 2)
    
    mov bx, dx
    shl bx, 1               ; Multiply by 2 for word pointer array index

    ; 2. Select array based on level
    cmp level, 1
    je do_l1
    cmp level, 2
    je do_l2
    
do_l3:
    mov si, l3_ptrs[bx]
    jmp copy_word
do_l2:
    mov si, l2_ptrs[bx]
    jmp copy_word
do_l1:
    mov si, l1_ptrs[bx]

copy_word:
    mov di, offset active_word
    mov cx, 0               ; Counter for length
cw_loop:
    mov al, [si]
    cmp al, '$'
    je done_copy
    mov [di], al
    inc si
    inc di
    inc cx
    jmp cw_loop

done_copy:
    mov [di], byte ptr '$'  ; Ensure active_word is terminated
    mov word_len, cx        ; Save length
    
    ; 3. Initialize guess array with '_'
    mov di, offset guess
ig_loop:
    mov byte ptr [di], '_'
    inc di
    loop ig_loop
    
    ret
load_random_word endp

; --- PROCEDURE: Draw UI Header ---
draw_ui proc
    mov dx, offset ui_top
    mov ah, 09h
    int 21h

    ; Print Level Number
    mov ax, level
    call print_number

    mov dx, offset ui_score
    mov ah, 09h
    int 21h

    ; Print Score Number
    mov ax, score
    call print_number

    mov dx, offset ui_rank
    mov ah, 09h
    int 21h

    ; Print Rank based on Score
    cmp score, 20
    jge rank_mid
    mov dx, offset rank_1
    jmp print_r
rank_mid:
    cmp score, 50
    jge rank_high
    mov dx, offset rank_2
    jmp print_r
rank_high:
    mov dx, offset rank_3
print_r:
    mov ah, 09h
    int 21h

    mov dx, offset ui_bot
    mov ah, 09h
    int 21h
    ret
draw_ui endp

; --- PROCEDURE: Print Number in AX ---
print_number proc
    pusha
    mov cx, 0
    mov bx, 10
pn_div:
    mov dx, 0
    div bx                  ; Divide AX by 10
    push dx                 ; Push remainder to stack
    inc cx                  ; Increment digit count
    cmp ax, 0               
    jne pn_div              ; Loop until quotient is 0

pn_print:
    pop dx                  ; Pop digit
    add dl, '0'             ; Convert to ASCII
    mov ah, 02h
    int 21h
    loop pn_print
    popa
    ret
print_number endp

; --- PROCEDURE: Clear Screen & Set Colors ---
clear_screen proc
    mov ah, 06h
    mov al, 0
    mov bh, 1Fh             ; 1 = Blue Background, F = Bright White Text
    mov cx, 0000h
    mov dx, 184Fh
    int 10h

    mov ah, 02h             
    mov bh, 00h             
    mov dx, 0000h           
    int 10h                 
    ret
clear_screen endp

; --- PROCEDURE: Print the 'guess' array ---
print_guess proc
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    mov dl, ' '
    int 21h
    int 21h

    mov cx, word_len
    mov si, offset guess
pg_loop:
    mov dl, [si]
    mov ah, 02h
    int 21h
    mov dl, ' '             
    int 21h
    inc si
    loop pg_loop
    ret
print_guess endp

; --- PROCEDURE: Check Win Condition ---
; --- PROCEDURE: Check Win Condition (Renamed Labels) ---
check_win proc
    mov cx, word_len
    mov si, offset guess
    mov al, 1               ; Assume win is true (AL=1)
win_loop:                   ; Changed from cw_loop
    mov ah, [si]
    cmp ah, '_'             ; Is there still a blank?
    jne win_next            ; Changed from cw_next
    mov al, 0               ; Found a blank, win is false (AL=0)
    ret                     
win_next:                   ; Changed from cw_next
    inc si
    loop win_loop           ; Changed from cw_loop
    ret
check_win endp

end main