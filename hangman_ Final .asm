.model small
.stack 100h

.data
    ; --- UI Elements ---
    ui_top      db "================================================================================", 13, 10
                db " LEVEL: $"
    ui_score    db "  SCORE: $"
    ui_rank     db "  RANK: $"
    ui_lives    db "  LIVES: $"
    ui_hint     db "  HINT: $"
    ui_bot      db 13, 10, "================================================================================", 13, 10, "$"

    ; --- Ranks (10 tiers) ---
    rank_1      db "BRONZE$"
    rank_2      db "SILVER$"
    rank_3      db "GOLD$"
    rank_4      db "PLATINUM$"
    rank_5      db "DIAMOND$"
    rank_6      db "HEROIC$"
    rank_7      db "ELITE HEROIC$"
    rank_8      db "MASTER$"
    rank_9      db "ELITE MASTER$"
    rank_10     db "GRAND MASTER$"
    rank_ptrs   dw offset rank_1, offset rank_2, offset rank_3, offset rank_4, offset rank_5
                dw offset rank_6, offset rank_7, offset rank_8, offset rank_9, offset rank_10

    hint_avail  db "AVAILABLE$"
    hint_used_s db "USED     $"

    ; --- Welcome / Instructions Screen ---
    welcome_msg db 13,10,13,10
                db "        ##  ##    ###    ##  ##   ####   ##  ##   ###   ##  ##",13,10
                db "        ##  ##   ## ##   ### ##  ##      ### ##  ## ##  ### ##",13,10
                db "        ######  #######  ## ###  ## ###  ## ###  #####  ## ###",13,10
                db "        ##  ##  ##   ##  ##  ##   ####   ##  ##  ## ##  ##  ##",13,10,13,10
                db "        ----------------- ASM EDITION -----------------",13,10,13,10
                db "  RULES:",13,10
                db "    * Guess one letter at a time to reveal the hidden word.",13,10
                db "    * 6 lives per level. Clear ALL 10 levels to become GRAND MASTER.",13,10
                db "    * Each cleared level: +10 score. Words get harder each level.",13,10
                db "    * Press '?' for a HINT - reveals one letter (1 hint per level, FREE).",13,10
                db "    * Repeating a letter you already tried does NOT cost a life.",13,10
                db "    * Ranks: BRONZE -> SILVER -> GOLD -> PLATINUM -> DIAMOND ->",13,10
                db "            HEROIC -> ELITE HEROIC -> MASTER -> ELITE MASTER -> GRAND MASTER",13,10,13,10
                db "  Press any key to begin... $"

    prompt      db 13, 10, 13, 10, "Enter your guess (a-z or '?' for hint): $"
    msg_win     db 13, 10, 13, 10, ">>> LEVEL CLEARED! +10 Points. Press any key...$"
    msg_victory db 13, 10, 13, 10, ">>> CONGRATULATIONS! YOU ARE THE GRAND MASTER! Press any key...$"
    msg_lose    db 13, 10, 13, 10, ">>> GAME OVER! Press any key...$"
    msg_word    db 13, 10, "The word was: $"
    msg_already db 13, 10, "  (You already tried that letter!) $"
    msg_invalid db 13, 10, "  (Invalid input - letters only.) $"
    msg_wrong   db 13, 10, "Wrong letters: $"
    msg_again   db 13, 10, 13, 10, "Play again? (Y/N): $"
    msg_nohint  db 13, 10, "  (No more letters to hint!) $"
    msg_hintused db 13, 10, "  (Hint already used this level!) $"

    ; --- Game Logic Variables ---
    level       dw 1
    score       dw 0
    mistakes    db 0
    hint_used   db 0          ; 0 = hint available this level, 1 = used

    active_word db 20 dup('$')
    word_len    dw 0
    guess       db 20 dup('_')

    tried_tbl   db 26 dup(0)
    wrong_buf   db 60 dup('$')

    ; --- Word Banks (10 levels x 5 words, increasing difficulty) ---
    l1_w1 db "RAM$"
    l1_w2 db "CPU$"
    l1_w3 db "BIT$"
    l1_w4 db "BUS$"
    l1_w5 db "ROM$"
    l1_ptrs dw offset l1_w1, offset l1_w2, offset l1_w3, offset l1_w4, offset l1_w5

    l2_w1 db "BYTE$"
    l2_w2 db "CODE$"
    l2_w3 db "DATA$"
    l2_w4 db "LOOP$"
    l2_w5 db "FLAG$"
    l2_ptrs dw offset l2_w1, offset l2_w2, offset l2_w3, offset l2_w4, offset l2_w5

    l3_w1 db "STACK$"
    l3_w2 db "CACHE$"
    l3_w3 db "LOGIC$"
    l3_w4 db "MACRO$"
    l3_w5 db "ARRAY$"
    l3_ptrs dw offset l3_w1, offset l3_w2, offset l3_w3, offset l3_w4, offset l3_w5

    l4_w1 db "MEMORY$"
    l4_w2 db "BINARY$"
    l4_w3 db "OPCODE$"
    l4_w4 db "KERNEL$"
    l4_w5 db "BUFFER$"
    l4_ptrs dw offset l4_w1, offset l4_w2, offset l4_w3, offset l4_w4, offset l4_w5

    l5_w1 db "PROGRAM$"
    l5_w2 db "NETWORK$"
    l5_w3 db "VIRTUAL$"
    l5_w4 db "DECODER$"
    l5_w5 db "POINTER$"
    l5_ptrs dw offset l5_w1, offset l5_w2, offset l5_w3, offset l5_w4, offset l5_w5

    l6_w1 db "REGISTER$"
    l6_w2 db "COMPILER$"
    l6_w3 db "HARDWARE$"
    l6_w4 db "ASSEMBLY$"
    l6_w5 db "FUNCTION$"
    l6_ptrs dw offset l6_w1, offset l6_w2, offset l6_w3, offset l6_w4, offset l6_w5

    l7_w1 db "INTERRUPT$"
    l7_w2 db "ALGORITHM$"
    l7_w3 db "RECURSION$"
    l7_w4 db "PROCESSOR$"
    l7_w5 db "EXECUTION$"
    l7_ptrs dw offset l7_w1, offset l7_w2, offset l7_w3, offset l7_w4, offset l7_w5

    l8_w1 db "ARITHMETIC$"
    l8_w2 db "BENCHMARKS$"
    l8_w3 db "MULTIPLIER$"
    l8_w4 db "DEBUGGABLE$"
    l8_w5 db "ALLOCATION$"
    l8_ptrs dw offset l8_w1, offset l8_w2, offset l8_w3, offset l8_w4, offset l8_w5

    l9_w1 db "MOTHERBOARD$"
    l9_w2 db "INSTRUCTION$"
    l9_w3 db "INTEGRATION$"
    l9_w4 db "COMPILATION$"
    l9_w5 db "TERMINATION$"
    l9_ptrs dw offset l9_w1, offset l9_w2, offset l9_w3, offset l9_w4, offset l9_w5

    l10_w1 db "ARCHITECTURE$"
    l10_w2 db "OPTIMIZATION$"
    l10_w3 db "CALCULATIONS$"
    l10_w4 db "INTELLIGENCE$"
    l10_w5 db "PROGRAMMABLE$"
    l10_ptrs dw offset l10_w1, offset l10_w2, offset l10_w3, offset l10_w4, offset l10_w5

    ; Master pointer table indexed by (level-1)
    level_ptrs  dw offset l1_ptrs, offset l2_ptrs, offset l3_ptrs, offset l4_ptrs, offset l5_ptrs
                dw offset l6_ptrs, offset l7_ptrs, offset l8_ptrs, offset l9_ptrs, offset l10_ptrs

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

new_game:
    mov level, 1
    mov score, 0

    call clear_screen
    mov dx, offset welcome_msg
    mov ah, 09h
    int 21h
    mov ah, 07h
    int 21h

start_level:
    mov mistakes, 0
    mov hint_used, 0
    call reset_tried
    call load_random_word

game_loop:
    call clear_screen
    call draw_ui

    mov bl, mistakes
    xor bh, bh
    shl bx, 1
    mov dx, hangman_ptrs[bx]
    mov ah, 09h
    int 21h

    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    call print_guess
    call print_wrong

    call check_win
    cmp al, 1
    je level_won

    cmp mistakes, 6
    jge game_lost

    mov dx, offset prompt
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h

    cmp al, '?'
    je do_hint

    cmp al, 'a'
    jl chk_upper
    cmp al, 'z'
    jg invalid_input
    sub al, 32
    jmp letter_ok
chk_upper:
    cmp al, 'A'
    jl invalid_input
    cmp al, 'Z'
    jg invalid_input
letter_ok:
    push ax
    mov bl, al
    sub bl, 'A'
    xor bh, bh
    cmp tried_tbl[bx], 1
    je already_tried
    mov tried_tbl[bx], 1
    pop ax

process_guess:
    mov cx, word_len
    mov si, offset active_word
    mov di, offset guess
    mov bl, 0

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
    call add_wrong
next_turn:
    jmp game_loop

invalid_input:
    mov dx, offset msg_invalid
    mov ah, 09h
    int 21h
    mov ah, 07h
    int 21h
    jmp game_loop

already_tried:
    pop ax
    mov dx, offset msg_already
    mov ah, 09h
    int 21h
    mov ah, 07h
    int 21h
    jmp game_loop

do_hint:
    ; 1 hint per level, FREE (no score change)
    cmp hint_used, 1
    je hint_already_used
    call reveal_one
    cmp al, 0
    je hint_none_left
    mov hint_used, 1
    jmp game_loop

hint_already_used:
    mov dx, offset msg_hintused
    mov ah, 09h
    int 21h
    mov ah, 07h
    int 21h
    jmp game_loop

hint_none_left:
    mov dx, offset msg_nohint
    mov ah, 09h
    int 21h
    mov ah, 07h
    int 21h
    jmp game_loop

level_won:
    mov ah, 02h
    mov dl, 7
    int 21h

    mov dx, offset msg_win
    mov ah, 09h
    int 21h

    add score, 10
    cmp level, 10
    je full_victory
    inc level
    mov ah, 07h
    int 21h
    jmp start_level

full_victory:
    mov dx, offset msg_victory
    mov ah, 09h
    int 21h
    mov ah, 07h
    int 21h
    jmp ask_replay

game_lost:
    mov ah, 02h
    mov dl, 7
    int 21h
    int 21h

    mov dx, offset msg_lose
    mov ah, 09h
    int 21h

    mov dx, offset msg_word
    mov ah, 09h
    int 21h

    mov dx, offset active_word
    mov ah, 09h
    int 21h

    mov ah, 07h
    int 21h

ask_replay:
    mov dx, offset msg_again
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    cmp al, 'y'
    je new_game
    cmp al, 'Y'
    je new_game

end_game:
    mov ah, 4ch
    int 21h
main endp

; --- Reset tried letters table & wrong_buf ---
reset_tried proc
    pusha
    mov cx, 26
    mov di, offset tried_tbl
rt_loop:
    mov byte ptr [di], 0
    inc di
    loop rt_loop

    mov cx, 60
    mov di, offset wrong_buf
rt_loop2:
    mov byte ptr [di], '$'
    inc di
    loop rt_loop2
    popa
    ret
reset_tried endp

; --- Append AL to wrong_buf ---
add_wrong proc
    push ax
    push di
    mov di, offset wrong_buf
aw_find:
    cmp byte ptr [di], '$'
    je aw_put
    inc di
    jmp aw_find
aw_put:
    mov [di], al
    inc di
    mov byte ptr [di], ' '
    inc di
    mov byte ptr [di], '$'
    pop di
    pop ax
    ret
add_wrong endp

print_wrong proc
    mov dx, offset msg_wrong
    mov ah, 09h
    int 21h
    mov dx, offset wrong_buf
    mov ah, 09h
    int 21h
    ret
print_wrong endp

; --- Reveal a hidden letter (hint). Reveals ALL occurrences of the
;     first still-hidden letter. AL=1 if revealed, 0 if none. ---
reveal_one proc
    ; Pass 1: find first hidden letter -> DL
    mov cx, word_len
    mov si, offset active_word
    mov di, offset guess
ro_find:
    cmp byte ptr [di], '_'
    jne ro_skip
    mov dl, [si]            ; DL = letter to reveal (uppercase)
    jmp ro_have
ro_skip:
    inc si
    inc di
    loop ro_find
    mov al, 0               ; nothing left hidden
    ret

ro_have:
    ; Mark letter as tried so guessing it later isn't penalized
    push bx
    mov bl, dl
    sub bl, 'A'
    xor bh, bh
    mov tried_tbl[bx], 1
    pop bx

    ; Pass 2: reveal every matching position
    mov cx, word_len
    mov si, offset active_word
    mov di, offset guess
ro_fill:
    mov al, [si]
    cmp al, dl
    jne ro_next
    mov [di], dl
ro_next:
    inc si
    inc di
    loop ro_fill

    mov al, 1
    ret
reveal_one endp

; --- Load Random Word Based on Level (1..10) ---
load_random_word proc
    mov ah, 00h
    int 1Ah
    mov ax, dx
    mov dx, 0
    mov cx, 5
    div cx                 ; dx = random index 0..4

    mov bx, dx
    shl bx, 1              ; word offset within level's ptr table

    ; Get pointer to current level's ptr table
    mov si, level
    dec si
    shl si, 1
    mov si, level_ptrs[si] ; SI = address of lN_ptrs
    add si, bx
    mov si, [si]           ; SI = pointer to chosen word

copy_word:
    mov di, offset active_word
    mov cx, 0
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
    mov [di], byte ptr '$'
    mov word_len, cx

    mov di, offset guess
ig_loop:
    mov byte ptr [di], '_'
    inc di
    loop ig_loop

    ret
load_random_word endp

; --- Draw UI Header ---
draw_ui proc
    mov dx, offset ui_top
    mov ah, 09h
    int 21h

    mov ax, level
    call print_number

    mov dx, offset ui_score
    mov ah, 09h
    int 21h

    mov ax, score
    call print_number

    mov dx, offset ui_rank
    mov ah, 09h
    int 21h

    ; --- Rank by score: 0..9 BRONZE, 10..19 SILVER, ... 90+ GRAND MASTER ---
    mov ax, score
    mov dx, 0
    mov cx, 10
    div cx                 ; AX = score / 10
    cmp ax, 9
    jbe rank_ok
    mov ax, 9
rank_ok:
    shl ax, 1
    mov bx, ax
    mov dx, rank_ptrs[bx]
    mov ah, 09h
    int 21h

    ; Lives left
    mov dx, offset ui_lives
    mov ah, 09h
    int 21h
    mov al, 6
    sub al, mistakes
    xor ah, ah
    call print_number

    ; Hint status
    mov dx, offset ui_hint
    mov ah, 09h
    int 21h
    cmp hint_used, 1
    je hint_st_used
    mov dx, offset hint_avail
    jmp hint_st_print
hint_st_used:
    mov dx, offset hint_used_s
hint_st_print:
    mov ah, 09h
    int 21h

    mov dx, offset ui_bot
    mov ah, 09h
    int 21h
    ret
draw_ui endp

; --- Print Number in AX ---
print_number proc
    pusha
    mov cx, 0
    mov bx, 10
pn_div:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne pn_div

pn_print:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop pn_print
    popa
    ret
print_number endp

; --- Clear Screen & Set Colors ---
clear_screen proc
    mov ah, 06h
    mov al, 0
    mov bh, 1Fh
    mov cx, 0000h
    mov dx, 184Fh
    int 10h

    mov ah, 02h
    mov bh, 00h
    mov dx, 0000h
    int 10h
    ret
clear_screen endp

; --- Print the 'guess' array ---
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

; --- Check Win Condition ---
check_win proc
    mov cx, word_len
    mov si, offset guess
    mov al, 1
win_loop:
    mov ah, [si]
    cmp ah, '_'
    jne win_next
    mov al, 0
    ret
win_next:
    inc si
    loop win_loop
    ret
check_win endp

end main
