; VGA
.extern vga_control_base, 0xeffc
.extern graphics_base, 0xf000

; PS/2
.extern ps2_base, 0xe002
.extern ps2_data, 0xe002
.extern ps2_control, 0xe003

; global variables
.extern ctrl_pressed, 0xc000
.extern alt_pressed, 0xc001
.extern shift_pressed, 0xc002
.extern is_extend, 0xc003
.extern is_break, 0xc004
.extern char_addr, 0xc005

; stack
.extern stack_base 0xe000