[org  0x7c00]

init:
  ; Set the stack
  mov bp, 0x9000
  mov sp, bp

  ; Print opening message
  mov bx, MSG_REAL_MODE
  call  print_string_bios

  ; Switch to protected mode.
  ; Note that we never return from here.
  jmp switch_to_pm

MSG_REAL_MODE db 'Started in 16-bit Real Mode', 0

; ==============================
; Print string using BIOS
; ==============================

print_string_bios:
  pusha
  mov ah, 0x0e

print_string_bios_loop:
  mov al, [bx]
  cmp al, 0
  je  print_string_bios_finish
  int 0x10
  add bx, 0x01
  jmp print_string_bios_loop

print_string_bios_finish:
  popa
  ret

; ==============================
; GDT
; ==============================
gdt_start:

gdt_null:  ; the mandatory null descriptor
  dd 0x0   ; 'dd' means define double word (i.e. 4 bytes)
  dd 0x0

gdt_code:  ; the code segment descriptor
  ; base address  = 0x0
  ; segment limit  = 0xfffff,
  ; 1st flags : (present) 1, (privilege) 00, (descriptor type) 1, -> 1001b,
  ; type flags : (code) 1, (conforming) 0, (readable) 1, (acessed) 0, -> 1010b
  ; 2nd flags : (granularity) 1, (320bit default) 1, (64bit seg) 0, (AVL) 0, -> 1100b
  dw 0xffff
  dw 0x0
  db 0x0
  db 10011010b
  db 11001111b
  db 0x0

gdt_data:
  dw 0xffff
  dw 0x0
  db 0x0
  db 10010010b
  db 11001111b
  db 0x0

gdt_end:

; GDT descriptor
gdt_descriptor:
  dw gdt_end - gdt_start - 1
  dd gdt_start

CODE_SEG equ gdt_code - gdt_start ; 0x8
DATA_SEG equ gdt_data - gdt_start ; 0x10

; ==================================
; Protected mode
; ==================================
switch_to_pm:
  cli       ; We must switch off interrupts until we have set-up the protected mode
            ; interrupt vector otherwise interrupts will run riot.
            ; "cli" means "clear interrupt".

  lgdt  [gdt_descriptor] ; Load out GDT.

  mov eax, cr0    ; To make the switch to protected mode, we set
  or  eax, 0x1    ; the first bit of CR0, a control register.
  mov cr0, eax

  jmp CODE_SEG:init_pm  ; Make a far jump. This also forces the CPU to flush its cache
                        ; of pre-fetched and real-mode decoded instructions.

[bits 32]
init_pm:
  mov ax, DATA_SEG      ; Now in PM, our old segments are meaningless,
  mov ds, ax            ; so we point our segment registers to the
  mov ss, ax            ; data selector we defined in our GDT
  mov es, ax
  mov fs, ax
  mov gs, ax

  mov ebp, 0x90000
  mov esp, ebp

BEGIN_PM:
  mov ebx, MSG_PROT_MODE
  call print_string_pm

  hlt
  jmp $

MSG_PROT_MODE db 'Successfully landed in 32-bit Protected Mode', 0

; ===============================
; Print string in protected mode
; ===============================

VIDEO_MEMORY_START equ 0xb8000
WHITE_ON_BLACK equ 0x0f

print_string_pm:
  pusha
  mov edx, VIDEO_MEMORY_START
  mov ah, WHITE_ON_BLACK

print_string_pm_loop:
  mov al, [ebx]
  cmp al, 0
  je  print_string_pm_finish
  mov [edx], ax
  add ebx, 1 ; Move to next char in string
  add edx, 2 ; Move to next cell in video memory
  jmp print_string_pm_loop

print_string_pm_finish:
  popa
  ret

; ============================
; Exit for debugging
; ============================

exit:

; ============================
; Bootsector padding
; ============================
times 510 - ($ - $$)  db 0
dw 0xaa55
