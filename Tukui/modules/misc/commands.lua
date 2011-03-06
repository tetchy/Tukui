local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

--
SLASH_TEST1 = "/test"
SlashCmdList["TEST"] = function()
    for _, frames in pairs({"TukuiPlayer", "TukuiTarget", "TukuiTargetTarget", "TukuiPet", "TukuiFocus"}) do
        _G[frames].Hide = function() end
        _G[frames]:Show()
        _G[frames].unit = "player"
    end
    for _, frames in pairs({"TukuiArena"--[[, "TukuiArenaUnitButton"]]}) do
        for i = 1, 5 do
            _G[frames..i].Hide = function() end
            _G[frames..i]:Show()
            _G[frames..i].unit = "player"
        end
    end
	for i = 1, 25 do
		_G["TukuiRaidUnitButton"..i].Hide = function() end
		_G["TukuiUnitButton"..i]:Show()
	end
end


-- enable or disable an addon via command
SlashCmdList.DISABLE_ADDON = function(addon) local _, _, _, _, _, reason, _ = GetAddOnInfo(addon) if reason ~= "MISSING" then DisableAddOn(addon) ReloadUI() else print("|cffff0000Error, Addon not found.|r") end end
SLASH_DISABLE_ADDON1 = "/disable"
SlashCmdList.ENABLE_ADDON = function(addon) local _, _, _, _, _, reason, _ = GetAddOnInfo(addon) if reason ~= "MISSING" then EnableAddOn(addon) LoadAddOn(addon) ReloadUI() else print("|cffff0000Error, Addon not found.|r") end end
SLASH_ENABLE_ADDON1 = "/enable"

local function ARCH()
	EnableAddOn("GatherMate2")
	EnableAddOn("GatherMate2_Data")
	EnableAddOn("MinimalArchaeology")
	EnableAddOn("Arh")
	ReloadUI()
end
SLASH_ARCH1 = "/arch"
SlashCmdList["ARCH"] = ARCH

local function ARCHY()
	DisableAddOn("GatherMate2")
	DisableAddOn("GatherMate2_Data")
	DisableAddOn("MinimalArchaeology")
	DisableAddOn("Arh")
	ReloadUI()
end
SLASH_ARCHY1 = "/archy"
SlashCmdList["ARCHY"] = ARCHY

-- switch to heal layout via a command
SLASH_TUKUIHEAL1 = "/heal"
SlashCmdList.TUKUIHEAL = function()
	DisableAddOn("Tukui_Raid")
	EnableAddOn("Tukui_Raid_Healing")
	ReloadUI()
end

-- switch to dps layout via a command
SLASH_TUKUIDPS1 = "/dps"
SlashCmdList.TUKUIDPS = function()
	DisableAddOn("Tukui_Raid_Healing")
	EnableAddOn("Tukui_Raid")
	ReloadUI()
end

-- fix combatlog manually when it broke
SLASH_CLFIX1 = "/clfix"
SlashCmdList.CLFIX = CombatLogClearEntries

SLASH_RAIDDISBAND1 = "/rd"
SlashCmdList["RAIDDISBAND"] = function()
		SendChatMessage(L.disband, "RAID" or "PARTY")
		if UnitInRaid("player") then
			for i=1, GetNumRaidMembers() do
				local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
				if online and name ~= T.myname then
					UninviteUnit(name)
				end
			end
		else
			for i=MAX_PARTY_MEMBERS, 1, -1 do
				if GetPartyMember(i) then
					UninviteUnit(UnitName("party"..i))
				end
			end
		end
		LeaveParty()
end
