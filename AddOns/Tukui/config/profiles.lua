----------------------------------------------------------------------------
-- Per Class Config (overwrite general)
-- Class need to be UPPERCASE
----------------------------------------------------------------------------
local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

if T.myclass == "PRIEST" then
	-- do some config!
end

----------------------------------------------------------------------------
-- Per Character Name Config (overwrite general and class)
-- Name need to be case sensitive
----------------------------------------------------------------------------

if T.myname == "Tukz" then
	-- yeah my default config is not really like default tukui.
	C.actionbar.hotkey = false
	C.actionbar.hideshapeshift = true
	C.unitframes.enemyhcolor = true
end

if T.myname == "Xirasis" then
	C.datatext.haste = 0
	C.datatext.dps_text = 0
	C.datatext.fps_ms = 4
	C.datatext.system = 5
	C.datatext.bags = 6
	C.datatext.gold = 12
	C.datatext.wowtime = 7
	C.datatext.guild = 10
	C.datatext.dur = 2
	C.datatext.friends = 9
	C.datatext.power = 14
	C.datatext.avd = 1
	C.datatext.currency = 11	
	C.datatext.hit = 13
	C.datatext.mastery = 3
	C.datatext.battlenet = true
	C.datatext.classcolor = true
	C.actionbar.hotkey = true
	C.merchant.autorepair = false
	C.unitframes.showownname = false
end
if T.myname == "Péy" then
	C.datatext.haste = 0
	C.datatext.dps_text = 0
	C.datatext.fps_ms = 4
	C.datatext.system = 5
	C.datatext.bags = 6
	C.datatext.gold = 12
	C.datatext.wowtime = 7
	C.datatext.guild = 10
	C.datatext.dur = 2
	C.datatext.friends = 9
	C.datatext.power = 14
	C.datatext.avd = 1
	C.datatext.currency = 11	
	C.datatext.hit = 13
	C.datatext.mastery = 3
	C.datatext.battlenet = true
	C.datatext.classcolor = true
	C.actionbar.hotkey = true
	C.merchant.autorepair = false
	C.unitframes.showownname = false
end