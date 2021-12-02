; Defines for registers, etc.

INIDISP      = $2100       ; w
OBSEL        = $2101       ; w
OAMADD       = $2102       ; w, 16-bit
OAMADDL      = OAMADD      ; w
OAMADDH      = $2103       ; w (sprite table select)
OAMDATA      = $2104       ; w, 2x (also see OAMDATAREAD)
BGMODE       = $2105       ; w
MOSAIC       = $2106       ; w
BG1SC        = $2107       ; w
BG2SC        = $2108       ; w
BG3SC        = $2109       ; w
BG4SC        = $210A       ; w
BG12NBA      = $210B       ; w
BG34NBA      = $210C       ; w
BG1HOFS      = $210D       ; w, 2x
M7HOFS       = BG1HOFS     ; w, 2x
BG1VOFS      = $210E       ; w, 2x
M7VOFS       = BG1VOFS     ; w, 2x
BG2HOFS      = $210F       ; w, 2x
BG2VOFS      = $2110       ; w, 2x
BG3HOFS      = $2111       ; w, 2x
BG3VOFS      = $2112       ; w, 2x
BG4HOFS      = $2113       ; w, 2x
BG4VOFS      = $2114       ; w, 2x
VMAINC       = $2115       ; w
VMADD        = $2116       ; w, 16-bit
VMADDL       = $2116       ; w
VMADDH       = $2117       ; w
VMDATA       = $2118       ; w, 16-bit (also see VMDATAREAD)
VMDATAL      = VMDATA      ; w
VMDATAH      = $2119       ; w
M7SEL        = $211A       ; w
M7A          = $211B       ; w, 2x
M7B          = $211C       ; w, 2x
M7C          = $211D       ; w, 2x
M7D          = $211E       ; w, 2x
M7X          = $211F       ; w, 2x
M7Y          = $2120       ; w, 2x
CGADD        = $2121       ; w
CGDATA       = $2122       ; w, 2x (also see CGDATAREAD)
W12SEL       = $2123       ; w
W34SEL       = $2124       ; w
WOBJSEL      = $2125       ; w
WH0          = $2126       ; w
WIN1L        = WH0         ; w
WH1          = $2127       ; w
WIN1R        = WH1         ; w
WH2          = $2128       ; w
WIN2L        = WH2         ; w
WH3          = $2129       ; w
WIN2R        = WH3         ; w
WBGLOG       = $212A       ; w
WOBJLOG      = $212B       ; w
TM           = $212C       ; w
TS           = $212D       ; w
TMW          = $212E       ; w
TSW          = $212F       ; w
CGWSEL       = $2130       ; w
CGADSUB      = $2131       ; w
COLDATA      = $2132       ; w
SETINI       = $2133       ; w
MPY          = $2134       ; r, 24-bit
MPYL         = MPY         ; r
MPYM         = $2135       ; r
MPYH         = $2136       ; r
SLHV         = $2137       ; r
OAMDATAREAD  = $2138       ; r, 2x (also see OAMADD and OAMDATA)
VMDATAREAD   = $2139       ; r, 16-bit (also see VMADD and VMDATA)
VMDATALREAD  = VMDATAREAD  ; r
VMDATAHREAD  = $213A       ; r
CGDATAREAD   = $213B       ; r, 2x (also see CGADD and CGDATA)
OPHCT        = $213C       ; r
OPVCT        = $213D       ; r
STAT77       = $213E       ; r
STAT78       = $213F       ; r

; APU registers

APUI00       = $2140 ; rw
APUI01       = $2141 ; rw
APUI02       = $2142 ; rw
APUI03       = $2143 ; rw

; WRAM registers

WMDATA       = $2180 ; rw
WMADD        = $2181 ; w, 24-bit
WMADDL       = $2181 ; w
WMADDH       = $2182 ; w
WMADDB       = $2183 ; w

; Serial joypad registers

JOYSER0      = $4016 ; rw
JOYSER1      = $4017 ; rw

; CPU registers

NMITIMEN     = $4200 ; w
WRIO         = $4201 ; w
WRMPYA       = $4202 ; w
WRMPYB       = $4203 ; w
WRDIV        = $4204 ; w, 16-bit
WRDIVL       = WRDIV ; w
WRDIVH       = $4205 ; w
WRDIVB       = $4206 ; w
HTIME        = $4207 ; w, 16-bit
HTIMEL       = HTIME ; w
HTIMEH       = $4208 ; w
VTIME        = $4209 ; w, 16-bit
VTIMEL       = $4209 ; w
VTIMEH       = $420A ; w
MDMAEN       = $420B ; w
HDMAEN       = $420C ; w
MEMSEL       = $420D ; w
RDNMI        = $4210 ; r
TIMEUP       = $4211 ; r
HVBJOY       = $4212 ; r
RDIO         = $4213 ; r
RDDIV        = $4214 ; r, 16-bit
RDDIVL       = RDDIV ; r
RDDIVH       = $4215 ; r
RDMPY        = $4216 ; r, 16-bit
RDMPYL       = RDMPY ; r
RDMPYH       = $4217 ; r
JOY1         = $4218 ; r, 16-bit
JOY1L        = JOY1  ; r
JOY1H        = $4219 ; r
JOY2         = $421A ; r, 16-bit
JOY2L        = JOY2  ; r
JOY2H        = $421B ; r
JOY3         = $421C ; r, 16-bit
JOY3L        = JOY3  ; r
JOY3H        = $421D ; r
JOY4         = $421E ; r, 16-bit
JOY4L        = JOY4  ; r
JOY4H        = $421F ; r

JOY_B        = $8000
JOY_Y        = $4000
JOY_Select   = $2000
JOY_Start    = $1000
JOY_Up       = $0800
JOY_Down     = $0400
JOY_Left     = $0200
JOY_Right    = $0100

JOY_A        = $0080
JOY_X        = $0040
JOY_L        = $0020
JOY_R        = $0010


function DMAP(n) = $4300+(n<<4)
function BBAD(n) = $4301+(n<<4)
function A1T(n)  = $4302+(n<<4)
function A1B(n)  = $4304+(n<<4)
function DAS(n)  = $4305+(n<<4)
function DASB(n) = $4307+(n<<4)
function A2A(n)  = $4308+(n<<4)
function NLTR(n) = $430A+(n<<4)
