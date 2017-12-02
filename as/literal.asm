hello_world:
.word 'h'
.word 'e'
.word 'l'
.word 'l'
.word 'o'
.word 44
.word 32
.word 'w'
.word 'o'
.word 'r'
.word 'l'
.word 'd'
.word 10
.word 0

prompt:
.word 's'
.word 'h'
.word '#'
.word 32
.word 0

boot_message:
.word 'S'
.word 'y'
.word 's'
.word 't'
.word 'e'
.word 'm'
.word 32
.word 'b'
.word 'o'
.word 'o'
.word 't'
.word 'e'
.word 'd'
.word 32
.word 's'
.word 'u'
.word 'c'
.word 'c'
.word 'e'
.word 's'
.word 's'
.word 'f'
.word 'u'
.word 'l'
.word 'l'
.word 'y'
.word '!'
.word 10
.word 10
.word 'T'
.word 'H'
.word 'C'
.word 'O'
.word 32
.word 'M'
.word 'I'
.word 'P'
.word 'S'
.word '1'
.word '6'
.word 'e'
.word 32
.word '['
.word 'v'
.word 'e'
.word 'r'
.word 's'
.word 'i'
.word 'o'
.word 'n'
.word 32
.word '0'
.word '.'
.word '0'
.word '.'
.word '0'
.word ']'
.word 10
.word 32
.word 32
.word 32
.word 32
.word 'b'
.word 'y'
.word 32
.word 't'
.word 'w'
.word 'd'
.word '2'
.word 32
.word 'a'
.word 'n'
.word 'd'
.word 32
.word 'C'
.word 'o'
.word 'l'
.word 'i'
.word 'n'
.word 10
.word 10
.word 0

server:
.word 's'
.word 'e'
.word 'r'
.word 'v'
.word 'e'
.word 'r'
.word 0

unknown_command:
.word 'U'
.word 'n'
.word 'k'
.word 'n'
.word 'o'
.word 'w'
.word 'n'
.word 32
.word 'c'
.word 'o'
.word 'm'
.word 'm'
.word 'a'
.word 'n'
.word 'd'
.word 58
.word 32
.word 0

empty_string:
.word 0

ps2_scancode:
; scancode lookup table
; 128 items
; usage:
; la r0, ps2_scancode
; addu r1, r0, r0
; lw r1, r1, 0
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x09
.word 0x60
.word 0x00
.word 0x01
.word 0x02
.word 0x03
.word 0x04
.word 0x05
.word 0x71
.word 0x31
.word 0x00
.word 0x01
.word 0x02
.word 0x7A
.word 0x73
.word 0x61
.word 0x77
.word 0x32
.word 0x00
.word 0x00
.word 0x63
.word 0x78
.word 0x64
.word 0x65
.word 0x34
.word 0x33
.word 0x00
.word 0x00
.word 0x20
.word 0x76
.word 0x66
.word 0x74
.word 0x72
.word 0x35
.word 0x00
.word 0x00
.word 0x6E
.word 0x62
.word 0x68
.word 0x67
.word 0x79
.word 0x36
.word 0x00
.word 0x00
.word 0x00
.word 0x6D
.word 0x6A
.word 0x75
.word 0x37
.word 0x38
.word 0x00
.word 0x00
.word 0x2C
.word 0x6B
.word 0x69
.word 0x6F
.word 0x30
.word 0x39
.word 0x00
.word 0x00
.word 0x2E
.word 0x2F
.word 0x6C
.word 0x3B
.word 0x70
.word 0x2D
.word 0x00
.word 0x00
.word 0x00
.word 0x27
.word 0x00
.word 0x5B
.word 0x3D
.word 0x00
.word 0x00
.word 0x00
.word 0x00
.word 0x0A
.word 0x5D
.word 0x00
.word 0x5C
.word 0x00
.word 0x01
.word 0x02
.word 0x03
.word 0x04
.word 0x05
.word 0x06
.word 0x07
.word 0x08
.word 0x00
.word 0x00
.word 0x31
.word 0x00
.word 0x34
.word 0x37
.word 0x00
.word 0x00
.word 0x00
.word 0x30
.word 0x2E
.word 0x32
.word 0x35
.word 0x36
.word 0x38
.word 0x00
.word 0x00
.word 0x00
.word 0x2B
.word 0x33
.word 0x2D
.word 0x2A
.word 0x39
.word 0x00
.word 0x00
