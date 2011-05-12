local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

local TukuiBar1 = CreateFrame("Frame", "TukuiBar1", UIParent, "SecureHandlerStateTemplate")
TukuiBar1:CreatePanel("Default", 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, 48)
TukuiBar1:SetWidth(414)
TukuiBar1:SetHeight(72)
TukuiBar1:SetFrameStrata("BACKGROUND")
TukuiBar1:SetFrameLevel(1)

local TukuiForteBar = CreateFrame("Frame", "TukuiForteBar", UIParent)
TukuiForteBar:CreatePanel("Default", 1, 1, "BOTTOM", TukuiBar1, "TOP", 0, 4)
TukuiForteBar:SetWidth(414)
TukuiForteBar:SetHeight(18)
TukuiForteBar:SetFrameStrata("BACKGROUND")
TukuiForteBar:SetFrameLevel(2)
TukuiForteBar:SetAlpha(0)
if T.lowversion then
	TukuiForteBar:SetAlpha(0)
else
	TukuiForteBar:SetAlpha(1)
end

local TukuiBar2 = CreateFrame("Frame", "TukuiBar2", UIParent)
TukuiBar2:CreatePanel("Default", 1, 1, "BOTTOMRIGHT", TukuiBar1, "BOTTOMLEFT", -6, 0)
TukuiBar2:SetWidth((T.buttonsize * 6) + (T.buttonspacing * 7))
TukuiBar2:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar2:SetFrameStrata("BACKGROUND")
TukuiBar2:SetFrameLevel(2)
TukuiBar2:SetAlpha(0)
if T.lowversion then
	TukuiBar2:SetAlpha(0)
else
	TukuiBar2:SetAlpha(1)
end

local TukuiBar3 = CreateFrame("Frame", "TukuiBar3", UIParent)
TukuiBar3:CreatePanel("Default", 1, 1, "BOTTOMLEFT", TukuiBar1, "BOTTOMRIGHT", 6, 0)
TukuiBar3:SetWidth((T.buttonsize * 6) + (T.buttonspacing * 7))
TukuiBar3:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar3:SetFrameStrata("BACKGROUND")
TukuiBar3:SetFrameLevel(2)
if T.lowversion then
	TukuiBar3:SetAlpha(0)
else
	TukuiBar3:SetAlpha(1)
end

local TukuiBar4 = CreateFrame("Frame", "TukuiBar4", UIParent)
TukuiBar4:CreatePanel("Default", 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, 48)
TukuiBar4:SetWidth((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar4:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar4:SetFrameStrata("BACKGROUND")
TukuiBar4:SetFrameLevel(2)
TukuiBar4:SetAlpha(0)

local TukuiBar5 = CreateFrame("Frame", "TukuiBar5", UIParent)
TukuiBar5:CreatePanel("Default", 1, (T.buttonsize * 12) + (T.buttonspacing * 13), "RIGHT", UIParent, "RIGHT", -23, -14)
TukuiBar5:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar5:SetFrameStrata("BACKGROUND")
TukuiBar5:SetFrameLevel(2)
TukuiBar5:SetAlpha(0)

local TukuiBar6 = CreateFrame("Frame", "TukuiBar6", UIParent)
TukuiBar6:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar6:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar6:SetPoint("LEFT", TukuiBar5, "LEFT", 0, 0)
TukuiBar6:SetFrameStrata("BACKGROUND")
TukuiBar6:SetFrameLevel(2)
TukuiBar6:SetAlpha(0)

local TukuiBar7 = CreateFrame("Frame", "TukuiBar7", UIParent)
TukuiBar7:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar7:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar7:SetPoint("TOP", TukuiBar5, "TOP", 0 , 0)
TukuiBar7:SetFrameStrata("BACKGROUND")
TukuiBar7:SetFrameLevel(2)
TukuiBar7:SetAlpha(0)

local petbg = CreateFrame("Frame", "TukuiPetBar", UIParent, "SecureHandlerStateTemplate")
petbg:CreatePanel("Default", T.petbuttonsize + (T.petbuttonspacing * 2), (T.petbuttonsize * 10) + (T.petbuttonspacing * 11), "RIGHT", TukuiBar5, "LEFT", -6, 0)
petbg:SetAlpha(0)

local ltpetbg1 = CreateFrame("Frame", "TukuiLineToPetActionBarBackground", petbg)
ltpetbg1:CreatePanel("Default", 24, 265, "LEFT", petbg, "RIGHT", 0, 0)
ltpetbg1:SetParent(petbg)
ltpetbg1:SetFrameStrata("BACKGROUND")
ltpetbg1:SetFrameLevel(0)
ltpetbg1:SetAlpha(0)

-- INVISIBLE FRAME COVERING BOTTOM ACTIONBARS JUST TO PARENT UF CORRECTLY
local invbarbg = CreateFrame("Frame", "InvTukuiActionBarBackground", UIParent)
if T.lowversion then
	invbarbg:SetPoint("TOPLEFT", TukuiBar1)
	invbarbg:SetPoint("BOTTOMRIGHT", TukuiBar1)
	TukuiBar2:Hide()
	TukuiBar3:Hide()
else
	invbarbg:SetPoint("TOPLEFT", TukuiBar2)
	invbarbg:SetPoint("BOTTOMRIGHT", TukuiBar3)
end

-- LEFT VERTICAL LINE
local ileftlv = CreateFrame("Frame", "TukuiInfoLeftLineVertical", TukuiBar1)
ileftlv:CreatePanel("Default", 2, 130, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 22, 30)

-- RIGHT VERTICAL LINE
local irightlv = CreateFrame("Frame", "TukuiInfoRightLineVertical", TukuiBar1)
irightlv:CreatePanel("Default", 2, 130, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -22, 30)

if not C.chat.background then
	-- CUBE AT LEFT, ACT AS A BUTTON (CHAT MENU)
	local cubeleft = CreateFrame("Frame", "TukuiCubeLeft", TukuiBar1)
	cubeleft:CreatePanel("Default", 10, 10, "BOTTOM", ileftlv, "TOP", 0, 0)
	cubeleft:EnableMouse(true)
	cubeleft:SetScript("OnMouseDown", function(self, btn)
		if TukuiInfoLeftBattleGround and UnitInBattleground("player") then
			if btn == "RightButton" then
				if TukuiInfoLeftBattleGround:IsShown() then
					TukuiInfoLeftBattleGround:Hide()
				else
					TukuiInfoLeftBattleGround:Show()
				end
			end
		end
		
		if btn == "LeftButton" then	
			ToggleFrame(ChatMenu)
		end
	end)

	-- CUBE AT RIGHT, ACT AS A BUTTON (CONFIGUI or BG'S)
	local cuberight = CreateFrame("Frame", "TukuiCubeRight", TukuiBar1)
	cuberight:CreatePanel("Default", 10, 10, "BOTTOM", irightlv, "TOP", 0, 0)
	if C["bags"].enable then
		cuberight:EnableMouse(true)
		cuberight:SetScript("OnMouseDown", function(self)
			ToggleKeyRing()
		end)
	end
end

-- HORIZONTAL LINE LEFT
local ltoabl = CreateFrame("Frame", "TukuiLineToABLeft", TukuiBar1)
ltoabl:CreatePanel("Default", 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
ltoabl:ClearAllPoints()
ltoabl:Point("BOTTOMLEFT", ileftlv, "BOTTOMLEFT", 0, 0)
ltoabl:Point("RIGHT", TukuiBar1, "BOTTOMLEFT", -1, 17)
ltoabl:SetFrameStrata("BACKGROUND")
ltoabl:SetFrameLevel(1)

-- HORIZONTAL LINE RIGHT
local ltoabr = CreateFrame("Frame", "TukuiLineToABRight", TukuiBar1)
ltoabr:CreatePanel("Default", 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
ltoabr:ClearAllPoints()
ltoabr:Point("LEFT", TukuiBar1, "BOTTOMRIGHT", 1, 17)
ltoabr:Point("BOTTOMRIGHT", irightlv, "BOTTOMRIGHT", 0, 0)
ltoabr:SetFrameStrata("BACKGROUND")
ltoabr:SetFrameLevel(1)

-- MOVE/HIDE SOME ELEMENTS IF CHAT BACKGROUND IS ENABLED
local movechat = 0
if C.chat.background then movechat = 10 ileftlv:SetAlpha(0) irightlv:SetAlpha(0) end

-- INFO LEFT (FOR STATS)
local ileft = CreateFrame("Frame", "TukuiInfoLeft", TukuiBar1)
ileft:CreatePanel("Default", T.InfoLeftRightWidth, 23, "LEFT", ltoabl, "LEFT", 14 - movechat, 0)
ileft:SetFrameLevel(2)
ileft:SetFrameStrata("BACKGROUND")

-- INFO MIDDLELEFTR (FOR STATS)
local imiddleleftr = CreateFrame("Frame", "TukuiInfoMiddleLeftR", UIParent)
imiddleleftr:CreatePanel("Default", (TukuiBar1:GetWidth() * 0.23), 23, "TOPLEFT", TukuiBar1, "BOTTOMLEFT", 0, -4)
imiddleleftr:SetFrameLevel(2)
imiddleleftr:SetFrameStrata("BACKGROUND")

-- INFO MIDDLE (FOR STATS)
local imiddle = CreateFrame("Frame", "TukuiInfoMiddle", TukuiBar1)
imiddle:CreatePanel("Default", (TukuiBar1:GetWidth() * 0.5), 23, "TOP", TukuiBar1, "BOTTOM", 0, -4)
imiddle:SetFrameLevel(2)
imiddle:SetFrameStrata("BACKGROUND")

-- INFO MIDDLERIGHTL (FOR STATS)
local imiddlerightl = CreateFrame("Frame", "TukuiInfoMiddleRightL", UIParent)
imiddlerightl:CreatePanel("Default", (TukuiBar1:GetWidth() * 0.23), 23, "TOPRIGHT", TukuiBar1, "BOTTOMRIGHT", 0, -4)
imiddlerightl:SetFrameLevel(2)
imiddlerightl:SetFrameStrata("BACKGROUND")


-- INFO RIGHT (FOR STATS)
local iright = CreateFrame("Frame", "TukuiInfoRight", TukuiBar1)
iright:CreatePanel("Default", T.InfoLeftRightWidth, 23, "RIGHT", ltoabr, "RIGHT", -14 + movechat, 0)
iright:SetFrameLevel(2)
iright:SetFrameStrata("BACKGROUND")

-- BOTTOM VIEWPORT
local bbar = CreateFrame("Frame", "TukuiBottomBar", UIParent)
bbar:CreatePanel(bbar, (GetScreenWidth() * 1) * 2, 20, "BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(-2))
bbar:SetFrameLevel(0)

-- TOP VIEWPORT
--local tbar = CreateFrame("Frame", "TukuiTopBar", UIParent)
--tbar:CreatePanel(tbar, (GetScreenWidth() * 1) * 2, 20, "TOP", UIParent, "TOP", 0, TukuiDB.Scale(2))
--tbar:SetFrameLevel(0)

if C.chat.background then
	-- Alpha horizontal lines because all panels is dependent on this frame.
	ltoabl:SetAlpha(0)
	ltoabr:SetAlpha(0)
	
	-- CHAT BG LEFT
	local chatleftbg = CreateFrame("Frame", "TukuiChatBackgroundLeft", TukuiInfoLeft)
	chatleftbg:CreatePanel("Transparent", T.InfoLeftRightWidth + 12, 177, "BOTTOM", TukuiInfoLeft, "BOTTOM", 0, -6)

	-- CHAT BG RIGHT
	local chatrightbg = CreateFrame("Frame", "TukuiChatBackgroundRight", TukuiInfoRight)
	chatrightbg:CreatePanel("Transparent", T.InfoLeftRightWidth + 12, 177, "BOTTOM", TukuiInfoRight, "BOTTOM", 0, -6)
	
	-- LEFT TAB PANEL
	local tabsbgleft = CreateFrame("Frame", "TukuiTabsLeftBackground", TukuiBar1)
	tabsbgleft:CreatePanel("Default", T.InfoLeftRightWidth, 23, "TOP", chatleftbg, "TOP", 0, -6)
	tabsbgleft:SetFrameLevel(2)
	tabsbgleft:SetFrameStrata("BACKGROUND")
	tabsbgleft:EnableMouse(true)
	tabsbgleft:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" then
			ToggleFrame(ChatMenu)
		end
	end)
		
	-- RIGHT TAB PANEL
	local tabsbgright = CreateFrame("Frame", "TukuiTabsRightBackground", TukuiBar1)
	tabsbgright:CreatePanel("Default", T.InfoLeftRightWidth, 23, "TOPLEFT", chatrightbg, "TOPLEFT", 6, -6)
	tabsbgright:SetFrameLevel(2)
	tabsbgright:SetFrameStrata("BACKGROUND")
	tabsbgright:EnableMouse(true)
	tabsbgright:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" then
		ShowHelm(not ShowingHelm())
		end
	end)
	
	-- [[ Create new horizontal line for chat background ]] --
	-- HORIZONTAL LINE LEFT
	local ltoabl2 = CreateFrame("Frame", "TukuiLineToABLeftAlt", TukuiBar1)
	ltoabl2:CreatePanel("Default", 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
	ltoabl2:ClearAllPoints()
	ltoabl2:Point("RIGHT", TukuiInfoMiddle, "LEFT", 0, 16)
	ltoabl2:Point("BOTTOMLEFT", chatleftbg, "BOTTOMRIGHT", 0, 16)

	-- HORIZONTAL LINE RIGHT
	local ltoabr2 = CreateFrame("Frame", "TukuiLineToABRightAlt", TukuiBar1)
	ltoabr2:CreatePanel("Default", 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
	ltoabr2:ClearAllPoints()
	ltoabr2:Point("LEFT", TukuiInfoMiddle, "RIGHT", 0, 16)
	ltoabr2:Point("BOTTOMRIGHT", chatrightbg, "BOTTOMLEFT", 0, 16)
end

if TukuiMinimap then
	local minimapstatsleft = CreateFrame("Frame", "TukuiMinimapStatsLeft", TukuiMinimap)
	--minimapstatsleft:CreatePanel("Default", ((TukuiMinimap:GetWidth() + 4) / 2) -3, 19, "TOPLEFT", TukuiMinimap, "BOTTOMLEFT", 0, -2)
	minimapstatsleft:CreatePanel("Default", TukuiMinimap:GetWidth(), 19, "TOPLEFT", TukuiMinimap, "BOTTOMLEFT", 0, -2)

	--local minimapstatsright = CreateFrame("Frame", "TukuiMinimapStatsRight", TukuiMinimap)
	--minimapstatsright:CreatePanel("Default", ((TukuiMinimap:GetWidth() + 4) / 2) -3, 19, "TOPRIGHT", TukuiMinimap, "BOTTOMRIGHT", 0, -2)
end

--BATTLEGROUND STATS FRAME
if C["datatext"].battleground == true then
	local bgframe = CreateFrame("Frame", "TukuiInfoLeftBattleGround", UIParent)
	bgframe:CreatePanel("Default", 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframe:SetAllPoints(ileft)
	bgframe:SetFrameStrata("LOW")
	bgframe:SetFrameLevel(0)
	bgframe:EnableMouse(true)
end

if IsAddOnLoaded("Skada") then
	local f=CreateFrame"Frame"
	f:RegisterEvent("PLAYER_LOGIN")
	f:SetScript("OnEvent", function(self)
		local skada=_G["SkadaBarWindow"..Skada.db.profile.windows[1].name]
		if skada:IsShown() then 
			ChatFrame4:Hide() 
		else 
			ChatFrame4:Show() 
		end
		skada:HookScript("OnShow", function() ChatFrame4:Hide() end)
		skada:HookScript("OnHide", function() ChatFrame4:Show() end)
		self:UnregisterEvent("PLAYER_LOGIN")
	end)
end

if IsAddOnLoaded("Recount") then
	local f=CreateFrame"Frame"
	f:RegisterEvent("PLAYER_LOGIN")
	f:SetScript("OnEvent", function(self)
		if Recount.MainWindow:IsShown() then
			ChatFrame4:Hide()
		else 
			ChatFrame4:Show()
		end
		Recount.MainWindow:HookScript("OnShow", function() ChatFrame4:Hide() end)
		Recount.MainWindow:HookScript("OnHide", function() ChatFrame4:Show() end)
		self:UnregisterEvent("PLAYER_LOGIN")
	end)
end
-- Toggle Button
local toggleskada = CreateFrame("Frame", "TukuiSkadaToggle", UIParent)
local toggletext = toggleskada:CreateFontString(nil, "OVERLAY", nil)
toggletext:SetFont(C.media.font,C["datatext"].fontsize, "OUTLINE")
toggletext:SetText(hexa.."S"..hexb)
toggletext:SetPoint("CENTER", 2, 0.5)
TukuiTabsRightBackground:Point("TOPRIGHT", TukuiChatBackgroundRight, "TOPRIGHT", -31, 0)
toggleskada:CreatePanel(toggleskada, 23, 23, "TOPLEFT", TukuiTabsRightBackground, "TOPRIGHT", 2, 0)
toggleskada:SetFrameLevel(TukuiTabsRightBackground:GetFrameLevel())
toggleskada:EnableMouse(true)
toggleskada:SetScript("OnEnter", function(self) toggleskada:SetBackdropBorderColor(unpack(C["media"].altclasscolor)) 
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 6)
	GameTooltip:ClearAllPoints()
	GameTooltip:ClearLines()
	GameTooltip:AddLine("L: Toggle Skada/Recount")
	GameTooltip:AddLine("R: Toggle RBR")
	GameTooltip:Show()
end)
toggleskada:SetScript("OnLeave", function(self) toggleskada:SetBackdropBorderColor(unpack(C["media"].bordercolor)) 
	GameTooltip:Hide() 
end)
toggleskada:SetScript("OnMouseDown", function(self, btn)
	if btn == "LeftButton" then
		if IsAddOnLoaded("Skada") then
			Skada:ToggleWindow()
		elseif IsAddOnLoaded("Recount") then
			if Recount.MainWindow:IsShown() then
				Recount.MainWindow:Hide() 
			else 
				Recount.MainWindow:Show()
				Recount:RefreshMainWindow() 
			end
		end
	elseif btn == "RightButton" then
		if RaidBuffReminder:IsShown() then
			RaidBuffReminder:Hide()
		else
			RaidBuffReminder:Show()
		end 
	end
end)
