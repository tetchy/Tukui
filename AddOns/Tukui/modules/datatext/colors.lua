-- Color system for Hydra datatexts
local T, C, L = unpack(select(2, ...))
local ccolor = CUSTOM_CLASS_COLORS[T.myclass]
hexa, hexb = C["datatext"].color, "|r"

if C["datatext"].classcolor then
	hexa = string.format("|c%02x%02x%02x%02x", 255, ccolor.r * 255, ccolor.g * 255, ccolor.b * 255)
end

-- also adding font here because i'm lazy
if C["datatext"].pixelfont then
	tdatafont = C.media.dmgfont
	C["datatext"].fontsize = 8
	
else
	tdatafont = C.media.font
	C["datatext"].fontsize = 12
end