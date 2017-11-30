
scancode = [
    0x0000,0x011B,0x0231,0x0332,0x0433,0x0534,0x0635,0x0736,0x0837,0x0938,0x0A39,0x0B30,0x0C2D,0x0D3D,0x0E08,0x0F09,
    0x1071,0x1177,0x1265,0x1372,0x1474,0x1579,0x1675,0x1769,0x186F,0x1970,0x1A5B,0x1B5D,0x1C0D,0x1D00,0x1E61,0x1F73,
    0x2064,0x2166,0x2267,0x2368,0x246A,0x256B,0x266C,0x273B,0x2827,0x2960,0x2A00,0x2B5C,0x2C7A,0x2D78,0x2E63,0x2F76,
    0x3062,0x316E,0x326D,0x332C,0x342E,0x352F,0x3600,0x372A,0x3800,0x3920,0x3A00,0x3B00,0x3C00,0x3D00,0x3E00,0x3F00,
    0x4000,0x4100,0x4200,0x4300,0x4400,0x4500,0x4600,0x4700,0x4800,0x4900,0x4A2D,0x4B00,0x4C00,0x4D00,0x4E2B,0x4F00,
    0x5000,0x5100,0x5200,0x5300,0x5400,0x5500,0x5600,0x8500,0x8600,0x0000,0x0000,0x5B00,0x5C00,0x5D00
]

for code in scancode:
    print('.word {:02x}'.format(code & 0xff))