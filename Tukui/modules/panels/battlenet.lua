local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

local BattlePanel = CreateFrame("Frame", "TukuiBattlePanel", UIParent)
BattlePanel:CreatePanel(BattlePanel, 205, 95, "BOTTOMLEFT", TukuiTabsLeftBackground, "TOPLEFT", -6, 12)
--BattlePanel:EnableMouse(true)
--BattlePanel:SetMovable(true)
--BattlePanel:SetUserPlaced(true)
--BattlePanel:SetClampedToScreen(true)
--BattlePanel:SetScript("OnMouseDown", function(self) self:StartMoving() end)
--BattlePanel:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
BattlePanel:SetFrameLevel(3)
BattlePanel:SetBackdrop({
bgFile = C["media"].transparent,
edgeFile = TukuiCF["media"].transparent,
tile = false, tileSize = 0, edgeSize = TukuiDB.mult,
insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult}
})

-- Battle.net
local BattleNetP = CreateFrame("Frame", "TukuiBattleNetP", UIParent)
BattleNetP:CreatePanel(BattleNetP, 46, 46, "TOPLEFT", TukuiBattlePanel, "TOPLEFT", 0, 0)
BattleNetP:SetFrameLevel(2)
BattleNetP:SetBackdrop({
bgFile = C["media"].battlenet,
edgeFile = TukuiCF["media"].blank,
tile = false, tileSize = 0, edgeSize = TukuiDB.mult,
insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult}
})
BattleNetP:SetBackdropBorderColor(unpack(C["media"].bordercolor))

local BattleNetPTopStat = CreateFrame("Frame", "TukuiBattleNetPTopStat", UIParent)
BattleNetPTopStat:CreatePanel(BattleNetPTopStat, BattleNetP:GetWidth() * 3.4, 20, "TOPLEFT", BattleNetP, "TOPRIGHT", 5, 0)
BattleNetPTopStat:SetFrameLevel(2)
BattleNetPTopStat:SetClampedToScreen(true)

local BattleNetPBottomStat = CreateFrame("Frame", "TukuiBattleNetPBottomStat", UIParent)
BattleNetPBottomStat:CreatePanel(BattleNetPBottomStat, BattleNetP:GetWidth() * 3.4, 20, "BOTTOMLEFT", BattleNetP, "BOTTOMRIGHT", 5, 0)
BattleNetPBottomStat:SetFrameLevel(2)

-- Gold Panel
local GoldP = CreateFrame("Frame", "TukuiGoldP", UIParent)
GoldP:CreatePanel(GoldP, 46, 46, "TOPLEFT", TukuiBattleNetP, "BOTTOMLEFT", 0, -5)
GoldP:SetFrameLevel(2)
GoldP:SetClampedToScreen(true)
GoldP:SetBackdrop({
bgFile = C["media"].gold,
edgeFile = TukuiCF["media"].blank,
tile = false, tileSize = 0, edgeSize = TukuiDB.mult,
insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult}
})
GoldP:SetBackdropBorderColor(unpack(C["media"].bordercolor))

local GoldPTopStat = CreateFrame("Frame", "TukuiGoldPTopStat", UIParent)
GoldPTopStat:CreatePanel(GoldPTopStat, GoldP:GetWidth() * 3.4, 20, "TOPLEFT", GoldP, "TOPRIGHT", 5, 0)
GoldPTopStat:SetFrameLevel(2)

local GoldPBottomStat = CreateFrame("Frame", "TukuiGoldPBottomStat", UIParent)
GoldPBottomStat:CreatePanel(GoldPBottomStat, GoldP:GetWidth() * 3.4, 20, "BOTTOMLEFT", GoldP, "BOTTOMRIGHT", 5, 0)
GoldPBottomStat:SetFrameLevel(2)
GoldPBottomStat:SetClampedToScreen(true)