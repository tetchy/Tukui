local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

-- BATTLE.NET LOGO
local battlenetlogo = CreateFrame("Frame", "TukuiBattleNetLogo", UIParent)
battlenetlogo:CreatePanel(battlenetlogo, 205, 20, "BOTTOMLEFT", TukuiTabsLeftBackground, "TOPLEFT", -6, 11)
battlenetlogo:SetClampedToScreen(true)
--battlenetlogo:EnableMouse(true)
--battlenetlogo:SetMovable(true)
--battlenetlogo:SetUserPlaced(true)
--battlenetlogo:SetClampedToScreen(true)
--battlenetlogo:SetScript("OnMouseDown", function(self) self:StartMoving() end)
--battlenetlogo:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
battlenetlogo:SetBackdrop({
bgFile = TukuiCF["media"].battlenetl, 
edgeFile = TukuiCF["media"].blank, 
tile = false, tileSize = 0, edgeSize = 1, 
insets = { left = -1, right = -1, top = -1, bottom = -1}
})
battlenetlogo:SetBackdropBorderColor(unpack(C["media"].bordercolor))

local BattlePanel = CreateFrame("Frame", "TukuiBattlePanel", UIParent)
BattlePanel:CreatePanel(BattlePanel, 205, 95, "BOTTOMLEFT", battlenetlogo, "TOPLEFT", 0, 6)
local r,g,b,_ = C["media"].backdropcolor
BattlePanel:SetBackdropColor(r,g,b,0)
BattlePanel:SetBackdropBorderColor(r,g,b,0)

-- Battle.net
local BattleNetP = CreateFrame("Frame", "TukuiBattleNetP", UIParent)
BattleNetP:CreatePanel(BattleNetP, 46, 46, "TOPLEFT", TukuiBattlePanel, "TOPLEFT", 0, 0)
BattleNetP:SetFrameLevel(2)
BattleNetP:CreateShadow()
BattleNetP:SetBackdrop({
bgFile = C["media"].battlenet,
edgeFile = C["media"].blank,
tile = false, tileSize = 0, edgeSize = 1,
insets = { left = -1, right = -1, top = -1, bottom = -1}
})
BattleNetP:SetBackdropBorderColor(unpack(C["media"].bordercolor))

local BattleNetPTopStat = CreateFrame("Frame", "TukuiBattleNetPTopStat", UIParent)
BattleNetPTopStat:CreatePanel(BattleNetPTopStat, BattleNetP:GetWidth() * 3.4, 20, "TOPLEFT", BattleNetP, "TOPRIGHT", 5, 0)
BattleNetPTopStat:SetFrameLevel(2)
BattleNetPTopStat:CreateShadow()
BattleNetPTopStat:SetClampedToScreen(true)

local BattleNetPBottomStat = CreateFrame("Frame", "TukuiBattleNetPBottomStat", UIParent)
BattleNetPBottomStat:CreatePanel(BattleNetPBottomStat, BattleNetP:GetWidth() * 3.4, 20, "BOTTOMLEFT", BattleNetP, "BOTTOMRIGHT", 5, 0)
BattleNetPBottomStat:SetFrameLevel(2)
BattleNetPBottomStat:CreateShadow()

-- Gold Panel
local GoldP = CreateFrame("Frame", "TukuiGoldP", UIParent)
GoldP:CreatePanel(GoldP, 46, 46, "TOPLEFT", TukuiBattleNetP, "BOTTOMLEFT", 0, -5)
GoldP:SetFrameLevel(2)
GoldP:CreateShadow()
GoldP:SetClampedToScreen(true)
GoldP:SetBackdrop({
bgFile = C["media"].gold,
edgeFile = C["media"].blank,
tile = false, tileSize = 0, edgeSize = 1,
insets = { left = -1, right = -1, top = -1, bottom = -1}
})
GoldP:SetBackdropBorderColor(unpack(C["media"].bordercolor))

local GoldPTopStat = CreateFrame("Frame", "TukuiGoldPTopStat", UIParent)
GoldPTopStat:CreatePanel(GoldPTopStat, GoldP:GetWidth() * 3.4, 20, "TOPLEFT", GoldP, "TOPRIGHT", 5, 0)
GoldPTopStat:SetFrameLevel(2)
GoldPTopStat:CreateShadow()

local GoldPBottomStat = CreateFrame("Frame", "TukuiGoldPBottomStat", UIParent)
GoldPBottomStat:CreatePanel(GoldPBottomStat, GoldP:GetWidth() * 3.4, 20, "BOTTOMLEFT", GoldP, "BOTTOMRIGHT", 5, 0)
GoldPBottomStat:SetFrameLevel(2)
GoldPBottomStat:CreateShadow()

-- LEFTMENU SHOW/HIDE BUTTON
local lmenushow = CreateFrame("Button", "TukuiLeftMenuShowButton", UIParent)
local buttontext = lmenushow:CreateFontString(nil,"OVERLAY",nil)
buttontext:SetFont(C.media.font,C["datatext"].fontsize,"OUTLINE")
buttontext:SetText(hexa.."<<"..hexb)
buttontext:SetPoint("CENTER", 2, 0.5)
TukuiDB.CreatePanel(lmenushow, buttontext:GetWidth()+20, 15, "TOPRIGHT", battlenetlogo, "TOPRIGHT", -3, -3)
lmenushow:SetFrameLevel(TukuiBattleNetLogo:GetFrameLevel() + 1)
lmenushow:EnableMouse(true)
		
lmenushow:HookScript("OnEnter", function(self) lmenushow:SetBackdropBorderColor(unpack(C["media"].altclasscolor)) end)
lmenushow:HookScript("OnLeave", function(self) lmenushow:SetBackdropBorderColor(unpack(C["media"].bordercolor)) end)
lmenushow:RegisterForClicks("AnyUp") lmenushow:SetScript("OnClick", function() 
	if BattlePanel:IsShown() then
		BattlePanel:Hide()
		BattleNetP:Hide()
		BattleNetPTopStat:Hide()
		BattleNetPBottomStat:Hide()
		GoldP:Hide()
		GoldPTopStat:Hide()
		GoldPBottomStat:Hide()
		buttontext:SetText(hexa..">>"..hexb)
	else
		BattlePanel:Show()
		BattleNetP:Show()
		BattleNetPTopStat:Show()
		BattleNetPBottomStat:Show()
		GoldP:Show()
		GoldPTopStat:Show()
		GoldPBottomStat:Show()
		buttontext:SetText(hexa.."<<"..hexb)
	end
end)

if C["datatext"].battlenet == true then
	-- Battle.Net Bar
	local battlenet = CreateFrame("Frame", "TukuiBattleNet", UIParent)
	battlenet:CreatePanel(battlenet, 200, 20, "TOP", TukuiTopBar, "BOTTOM", 5, -100)
	--battlenet:SetClampedToScreen(true)
	battlenet:SetFrameLevel(2)
	battlenet:SetBackdrop({
	bgFile = C["media"].battlenetl, 
	edgeFile = C["media"].blank, 
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = { left = -1, right = -1, top = -1, bottom = -1}
	})
	battlenet:SetBackdropBorderColor(unpack(C["media"].bordercolor))

	-- Toggle Button
	local battletoggle = CreateFrame("Button", "BattlenetToggle", UIParent)
	local battletext = battletoggle:CreateFontString(nil, "OVERLAY", nil)
	battletext:SetFont(C.media.uffontp, 10, "OUTLINE")
	battletext:SetText(hexa.."<<"..hexb)
	battletext:SetPoint("CENTER", 2, 0.5)
	battletoggle:CreatePanel(battletoggle, battletext:GetWidth()+20, 15, "RIGHT", battlenet, "RIGHT", -3, 0)
	battletoggle:SetFrameLevel(battlenet:GetFrameLevel() + 1)

	-- Frame Holder
	local battleframe = CreateFrame("Frame", "BattlenetHolder", UIParent)
	battleframe:CreatePanel(battleframe, 200, 95, "TOPLEFT", battlenet, "BOTTOMLEFT", 0, 1)
	battleframe:SetFrameLevel(2)
	battleframe:SetBackdropColor(unpack(C["media"].backdropcolor))
	battleframe:SetBackdropBorderColor(unpack(C["media"].bordercolor))

	-- Battle.net image
	local bimage = CreateFrame("Frame", nil, battleframe)
	bimage:CreatePanel(bimage, 44, 44, "TOPLEFT", battleframe, "TOPLEFT", 2, -2)
	bimage:SetFrameLevel(3)
	bimage:SetBackdrop({
	bgFile = C["media"].battlenet,
	edgeFile = C["media"].blank,
	tile = false, tileSize = 0, edgeSize = 1,
	insets = { left = -1, right = -1, top = -1, bottom = -1}
	})
	bimage:SetBackdropBorderColor(unpack(C["media"].bordercolor))

	-- Battlenet Datatext placeholder
	-- Top
	local battletopstat = CreateFrame("Frame", "BattleStatTop", battleframe)
	battletopstat:CreatePanel(battletopstat, (battleframe:GetWidth() -49), ((bimage:GetHeight() / 2)), "TOPLEFT", bimage, "TOPRIGHT", 0, 0)
	battletopstat:SetFrameLevel(3) 

	-- Bottom
	local battlebottomstat = CreateFrame("Frame", "BattleStatBottom", battleframe)
	battlebottomstat:CreatePanel(battlebottomstat, (battleframe:GetWidth() -49), ((bimage:GetHeight() / 2)), "BOTTOMLEFT", bimage, "BOTTOMRIGHT", 0, 0)
	battlebottomstat:SetFrameLevel(3) 

end