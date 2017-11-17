import sys
import struct

class ASError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class ImmOutOfRangeError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class DuplicatedSymbolError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class SymbolNotFoundError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class BadOperandError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

class UnknownInstructionError(ASError):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

# define pseudo-instructions

PSEUDO = {}

def pseudo_twd2():
    return [['nop']] * 3
PSEUDO['twd2'] = pseudo_twd2

def pseudo_li(rx, imm):
    imm = parse_imm(imm)
    if not -32768 <= imm <= 65535:
        raise ImmOutOfRangeError(imm)
    hi = (imm >> 8) & 0xff
    lo = imm & 0xff
    if hi == 0:
        return [['li', rx, str(lo)]]
    else:
        if lo >= 0x80:
            return [['li', rx, str((hi + 1) & 0xff)],
                    ['sll', rx, rx, str(8)],
                    ['addiu', rx, str(lo)]]
        else:
            return [['li', rx, str(hi)],
                    ['sll', rx, rx, str(8)],
                    ['addiu', rx, str(lo)]]
PSEUDO['li'] = pseudo_li

def pseudo_push(rx):
    return [['addsp', '-1'],
            ['sw_sp', rx, '0']]
PSEUDO['push'] = pseudo_push

def pseudo_pop(rx):
    return [['lw_sp', rx, '0'],
            ['addsp', '1']]
PSEUDO['pop'] = pseudo_pop

def pseudo_call(label, rx='r7'):
    return [['mfpc', rx],
            ['addiu', rx, '3'],
            ['b', label]]
PSEUDO['call'] = pseudo_call

def pseudo_ret(rx='r7'):
    return [['jr', rx]]
PSEUDO['ret'] = pseudo_ret

# define instructions

ACT = {}

def make0(op, remain):
    return ((op & 0b11111) << 11) | (remain & 0b11111111111)

def make1(op, rx, remain):
    return ((op & 0b11111) << 11) | ((rx & 0b111) << 8) | (remain & 0b11111111)

def make2(op, rx, ry, remain):
    return ((op & 0b11111) << 11) | ((rx & 0b111) << 8) | ((ry & 0b111) << 5) | (remain & 0b11111)

def make3(op, rx, ry, rz, remain):
    return ((op & 0b11111) << 11) | ((rx & 0b111) << 8) | ((ry & 0b111) << 5) | ((rz & 0b111) << 2) | (remain & 0b11)

def make_addiu(rx, imm):
    # if not -128 <= imm <= 127:
    #     raise ImmOutOfRangeError(imm)
    return make1(0b01001, reg(rx), imm & 0b11111111)
ACT['addiu'] = make_addiu

def make_addiu3(rx, ry, imm):
    if not -8 <= imm <= 7:
        raise ImmOutOfRangeError(imm)
    return make2(0b01000, reg(rx), reg(ry), imm & 0b1111)
ACT['addiu3'] = make_addiu3

def make_addsp3(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b00000, reg(rx), imm)
ACT['addsp3'] = make_addsp3
ACT['add_sp3'] = make_addsp3

def make_addsp(imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b01100, 0b011, imm)
ACT['addsp'] = make_addsp
ACT['add_sp'] = make_addsp

def make_addu(rx, ry, rz):
    return make3(0b11100, reg(rx), reg(ry), reg(rz), 0b01)
ACT['addu'] = make_addu

def make_and(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b01100)
ACT['and'] = make_and

def make_b(imm):
    if not -1024 <= imm <= 1023:
        raise ImmOutOfRangeError(imm)
    return make0(0b00010, imm)
ACT['b'] = make_b

def make_beqz(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b00100, reg(rx), imm)
ACT['beqz'] = make_beqz

def make_bnez(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b00101, reg(rx), imm)
ACT['bnez'] = make_bnez

def make_bteqz(imm):
    return make1(0b01100, 0b000, imm)
ACT['bteqz'] = make_bteqz

def make_btnez(imm):
    return make1(0b01100, 0b001, imm)
ACT['btnez'] = make_btnez

def make_cmp(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b01010)
ACT['cmp'] = make_cmp

def make_cmpi(rx):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b01110, reg(rx), imm)
ACT['cmpi'] = make_cmpi

def make_jr(rx):
    return make1(0b11101, reg(rx), 0)
ACT['jr'] = make_jr

def make_li(rx, imm):
    if not 0 <= imm <= 255:
        raise ImmOutOfRangeError(imm)
    return make1(0b01101, reg(rx), imm)
ACT['li'] = make_li

def make_lw(rx, ry, imm):
    if not -16 <= imm <= 15:
        raise ImmOutOfRangeError(imm)
    return make2(0b10011, reg(rx), reg(ry), imm)
ACT['lw'] = make_lw

def make_lw_sp(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b10010, reg(rx), imm)
ACT['lw_sp'] = make_lw_sp
ACT['lwsp'] = make_lw_sp

def make_mfih(rx):
    return make1(0b11110, reg(rx), 0)
ACT['mfih'] = make_mfih

def make_mfpc(rx):
    return make1(0b11101, reg(rx), 0b01000000)
ACT['mfpc'] = make_mfpc

def make_move(rx, ry):
    return make2(0b01111, reg(rx), reg(ry), 0)
ACT['move'] = make_move

def make_mtih(rx):
    return make1(0b11110, reg(rx), 0b00000001)
ACT['mtih'] = make_mtih

def make_mtsp(ry):
    return make2(0b01100, 0b100, reg(ry), 0)
ACT['mtsp'] = make_mtsp

def make_not(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b01111)
ACT['not'] = make_not

def make_nop():
    return make0(0b00001, 0)
ACT['nop'] = make_nop

def make_or(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b01101)
ACT['or'] = make_or

def make_sll(rx, ry, imm):
    if not 1 <= imm <= 8:
        raise ImmOutOfRangeError(imm)
    if imm == 8:
        imm = 0
    return make3(0b00110, reg(rx), reg(ry), imm, 0)
ACT['sll'] = make_sll

def make_sllv(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b00100)
ACT['sllv'] = make_sllv

def make_sra(rx, ry, imm):
    if not 1 <= imm <= 8:
        raise ImmOutOfRangeError(imm)
    if imm == 8:
        imm = 0
    return make3(0b00110, reg(rx), reg(ry), imm, 0b11)
ACT['sra'] = make_sra

def make_srav(rx, ry):
    return make2(0b11101, reg(rx), reg(ry), 0b00111)
ACT['srav'] = make_srav

def make_subu(rx, ry, rz):
    return make3(0b11100, reg(rx), reg(ry), reg(rz), 0b11)
ACT['subu'] = make_subu

def make_sw(rx, ry, imm):
    if not -16 <= imm <= 15:
        raise ImmOutOfRangeError(imm)
    return make2(0b11011, reg(rx), reg(ry), imm)
ACT['sw'] = make_sw

def make_sw_sp(rx, imm):
    if not -128 <= imm <= 127:
        raise ImmOutOfRangeError(imm)
    return make1(0b11010, reg(rx), imm)
ACT['sw_sp'] = make_sw_sp
ACT['swsp'] = make_sw_sp

def reg(r):
    if r[0] not in list('$Rr'):
        raise BadOperandError(r)
    try:
        return int(r[1:])
    except ValueError:
        raise BadOperandError(r) from None

def parse_imm(imm):
    if len(imm) >= 2 and imm[0:2] == '0x':
        return int(imm, 16)
    elif len(imm) >= 2 and imm[0:2] == '0b':
        return int(imm, 2)
    else:
        return int(imm)

def asm(code):
    code = '\n'.join([l.split(';')[0] for l in code.split('\n')])
    code = code.replace(':', ':\n')

    # pass 1: build inst list and symbol table
    inst_list = []
    syms = {}
    for line in code.split('\n'):
        line = line.split(';')[0].strip()
        if not line:
            continue
        if line[-1] == ':': # label
            sym = line[:-1]
            if sym in syms:
                raise DuplicatedSymbolError(sym)
            syms[sym] = len(inst_list)
        else: # inst
            l = list(filter(lambda s: bool(s), line.replace(',', ' ').split(' ')))
            if l[0].lower() in PSEUDO:
                inst_list.extend(PSEUDO[l[0].lower()](*l[1:]))
            else:
                inst_list.append(l)

    # pass 2: symbol/imm resolve
    for pc, inst in enumerate(inst_list):
        op = inst[0].lower()
        if op in ['b', 'bteqz', 'btnez']:
            sym = inst[1]
            if sym not in syms:
                raise SymbolNotFoundError(sym)
            inst[1] = syms[sym] - (pc + 1)
        elif op in ['beqz', 'bnez']:
            sym = inst[2]
            if sym not in syms:
                raise SymbolNotFoundError(sym)
            inst[2] = syms[sym] - (pc + 1)
        else:
            for i in range(len(inst)):
                arg = inst[i].lower()
                if arg[0] in list('-0123456789'):
                    inst[i] = parse_imm(arg)
    print(inst_list)

    # pass 3: generate target code
    mc = []
    for inst in inst_list:
        if inst[0].lower() not in ACT:
            raise UnknownInstructionError(inst[0])
        try:
            mc.append(ACT[inst[0].lower()](*inst[1:]))
        except TypeError:
            raise BadOperandError(inst) from None

    # pass 4: generate binary
    buffer = b''
    for c in mc:
        buffer += struct.pack('<H', c) # big-endian
    return buffer, syms

def main():
    pass

if __name__ == '__main__':
    main()

buffer, syms = asm(sys.stdin.read())
with open('a.out', 'wb') as f:
    f.write(buffer)