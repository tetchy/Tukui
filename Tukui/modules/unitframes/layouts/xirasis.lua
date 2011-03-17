local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if not(C["unitframes"].layout == "Xirasis") then return end
if not C["unitframes"].enable == true then return end

print("Xirasis layout enabled")

local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}



------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

local font1 = C["media"].uffont
local font2 = C["media"].font
local normTex = C["media"].normTex
local glowTex = C["media"].glowTex
local bubbleTex = C["media"].bubbleTex

local backdrop = {
	bgFile = C["media"].blank,
	insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult},
}

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	-- set our own colours
	self.colors = T.oUF_colors
	
	-- register click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- menu
	self.menu = T.SpawnMenu
	
	-- backdrop for every units
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)
	
	-- glow border
	self:CreateShadow("Default")
	
	-- Invisible frame health/power.
	local InvFrame = CreateFrame("Frame", nil, self)
	InvFrame:SetFrameStrata("HIGH")
	InvFrame:SetFrameLevel(5)
	InvFrame:SetAllPoints()
	
	-- symbols, more symbols!
	local RaidIcon = InvFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- Credit to hankthetank for textures
	RaidIcon:SetHeight(20)
	RaidIcon:SetWidth(20)
	RaidIcon:SetPoint("TOP", 0, 11)
	self.RaidIcon = RaidIcon
	
	------------------------------------------------------------------------
	--	Player and Target units layout (mostly mirror'd)
	------------------------------------------------------------------------
	
	if (unit == "player" or unit == "target") then
		-- panel creation time!
		local panel = CreateFrame("Frame", nil, self)
		panel:CreatePanel("Default", 250, 36 , 	"BOTTOM", self, "BOTTOM", 0, 0)
		panel:SetFrameLevel(2)
		panel:SetFrameStrata("MEDIUM")
		panel:SetAlpha(0)
		self.panel = panel
		self.shadow:SetAlpha(0)
	
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(36)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		health:SetFrameLevel(3)
	
		-- health bar BG
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		-- health border
		local healthborder = CreateFrame("Frame", nil, self)
		healthborder:CreatePanel("Default", 1, 1, "CENTER", health, "CENTER", 0, 0)
		healthborder:ClearAllPoints()
		healthborder:Point("TOPLEFT", health, -2, 2)
		healthborder:Point("BOTTOMRIGHT", health, 2, -2)
		healthborder:SetFrameLevel(2)
		healthborder:SetFrameStrata("MEDIUM")
		
		health.value = T.SetFontString(health, font1, 12)
		health.value:Point("TOPRIGHT", health, "TOPRIGHT", -4, -6)
		health.value:SetShadowColor(0, 0, 0)
		health.value:SetShadowOffset(1.25, -1.25)
		health.PostUpdate = T.PostUpdateHealth
		
		self.Health= health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.2, .2, .2, 1)
			healthBG:SetVertexColor(0.01, 0.01, 0.01, 1)
		else
			health.colorDisconnected = true
			health.colorTapping = true
			health.colorClass = true
			health.colorReaction = true
		end
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Size(125, 5)
		if unit == "player" then
			power:Point("RIGHT", health, "BOTTOMRIGHT", -10, -2)
		elseif unit == "target" then
			power:Point("LEFT", health, "BOTTOMLEFT", 10, -2)
		end
		power:SetFrameLevel(4)
		power:SetStatusBarTexture(normTex)
		
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		-- power border
		local powerborder = CreateFrame("Frame", nil, self)
		powerborder:CreatePanel("Default", 1, 1, "CENTER", power, "CENTER", 0, 0)
		powerborder:ClearAllPoints()
		powerborder:Point("TOPLEFT", power, -2, 2)
		powerborder:Point("BOTTOMRIGHT", power, 2, -2)
		powerborder:SetFrameLevel(4)
		powerborder:SetFrameStrata("MEDIUM")
		
		power.value = T.SetFontString(health, font1, 12)
		power.value:Point("TOPLEFT", health, "TOPLEFT", 4, -6)
		power.value:SetShadowColor(0, 0, 0)
		power.value:SetShadowOffset(1.25, -1.25)
		power.PreUpdate  = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
		
		self.Power = power
		self.Power.bg = powerBG
		
		power.frequentUpdates = true
		power.colorDisconnected = true
		
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			power.colorTapping = true
			power.colorClass = true
			powerBG.multiplier = 0.1				
		else
			power.colorPower = true
		end
		
		-- portraits
		if (C["unitframes"].charportrait == true) then
            local portrait = CreateFrame("PlayerModel", nil, health)
            portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end -- change the 0.15 to the alphavalue you want
			if C["unitframes"].unicolor == true then
				portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.10) end
			end
            portrait:SetAllPoints(health)
			portrait:SetFrameLevel(3)
            table.insert(self.__elements, T.HidePortrait)
            self.Portrait = portrait
        end
		
		if T.myclass == "PRIEST" and C["unitframes"].weakenedsoulbar then
			local ws = CreateFrame("StatusBar", self:GetName().."_WeakenedSoul", power)
			ws:SetAllPoints(power)
			ws:SetStatusBarTexture(C.media.normTex)
			ws:GetStatusBarTexture():SetHorizTile(false)
			ws:SetBackdrop(backdrop)
			ws:SetBackdropColor(unpack(C.media.backdropcolor))
			ws:SetStatusBarColor(191/255, 10/255, 10/255)
			
			self.WeakenedSoul = ws
		end
		
		if (unit == "player") then
			-- combat icon
			local Combat = health:CreateTexture(nil, "OVERLAY")
			Combat:Height(19)		
			Combat:Width(19)	
			Combat:SetPoint("BOTTOMLEFT", 2, 2)
			Combat:SetVertexColor(0.69, 0.31, 0.31)
			self.Combat = Combat
		
			-- custom info (low mana warning)
			FlashInfo = CreateFrame("Frame", "TukuiFlashInfo", self)
			FlashInfo:SetScript("OnUpdate", T.UpdateManaLevel)
			FlashInfo.parent = self
			FlashInfo:SetAllPoints(panel)
			FlashInfo.ManaLevel = T.SetFontString(FlashInfo, font1, 12)
			FlashInfo.ManaLevel:SetPoint("CENTER", panel, "CENTER", 0, 0)
			self.FlashInfo = FlashInfo
		
			-- pvp status text
			local status = T.SetFontString(panel, font1, 12)
			status:SetPoint("CENTER", panel, "CENTER", 0, 0)
			status:SetTextColor(0.69, 0.31, 0.31, 0)
			self.Status = status
			self:Tag(status, "[pvp]")
		
			-- leader icon
			local Leader = InvFrame:CreateTexture(nil, "OVERLAY")
			Leader:Height(14)
			Leader:Width(14)
			Leader:Point("TOPLEFT", 2, 8)
			self.Leader = Leader
		
			-- master looter
			local MasterLooter = InvFrame:CreateTexture(nil, "OVERLAY")
			MasterLooter:Height(14)
			MasterLooter:Width(14)
			self.MasterLooter = MasterLooter
			self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)
			
			-- experience bar on power via mouseover for player currently levelling a character
			if T.level ~= MAX_PLAYER_LEVEL then
				local Experience = CreateFrame("StatusBar", self:GetName().."_Experience", self)
				Experience:SetStatusBarTexture(normTex)
				Experience:SetStatusBarColor(0, 0.4, 1, .8)
				Experience:SetBackdrop(backdrop)
				Experience:SetBackdropColor(unpack(C["media"].backdropcolor))
				Experience:Width(power:GetWidth())
				Experience:Height(power:GetHeight())
				Experience:Point("TOPLEFT", power, 0, 0)
				Experience:Point("BOTTOMRIGHT", power, 0, 0)
				Experience:SetFrameLevel(10)
				Experience:SetAlpha(0)				
				Experience:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
				Experience:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
				Experience.Tooltip = true						
				Experience.Rested = CreateFrame('StatusBar', nil, self)
				Experience.Rested:SetParent(Experience)
				Experience.Rested:SetAllPoints(Experience)
				local Resting = Experience:CreateTexture(nil, "OVERLAY")
				Resting:SetHeight(28)
				Resting:SetWidth(28)
				if T.myclass == "SHAMAN" or T.myclass == "DEATHKNIGHT" or T.myclass == "PALADIN" or T.myclass == "WARLOCK" or T.myclass == "DRUID" then
					Resting:SetPoint("LEFT", -18, 76)
				else
					Resting:SetPoint("LEFT", -18, 68)
				end
				Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
				Resting:SetTexCoord(0, 0.5, 0, 0.421875)
				self.Resting = Resting
				self.Experience = Experience
			end
			
			-- reputation bar for max level character
			local Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self)
			Reputation:SetStatusBarTexture(normTex)
			Reputation:SetBackdrop(backdrop)
			Reputation:SetBackdropColor(unpack(C["media"].backdropcolor))
			Reputation:Width(TukuiInfoMiddle:GetWidth() - 4)
			Reputation:Height(TukuiInfoMiddle:GetHeight() - 4)
			Reputation:Point("TOPLEFT", TukuiInfoMiddle, 2, -2)
			Reputation:Point("BOTTOMRIGHT", TukuiInfoMiddle, -2, 2)
			Reputation:SetFrameLevel(TukuiInfoMiddle:GetFrameLevel() + 1)
			Reputation:SetAlpha(1)
				
			Reputation.Text = T.SetFontString(Reputation, C.media.font, 12)
			Reputation.Text:SetPoint("CENTER")
			Reputation.Text:SetAlpha(0)
			Reputation:HookScript("OnEnter", function(self) Reputation.Text:SetAlpha(1) end)
			Reputation:HookScript("OnLeave", function(self) Reputation.Text:SetAlpha(0) end)

			Reputation.PostUpdate = T.UpdateReputationColor
			Reputation.Tooltip = true
			self.Reputation = Reputation
			
			-- Vengeance bar for tanks
			local Vengeance = CreateFrame("StatusBar", self:GetName().."_Vengeance", self)
			--local Vengeance = CreateFrame("StatusBar", "TukuiVengeance", TukuiInfoMiddle)
			--Vengeance:SetFrameStrata("TOOLTIP")
			Vengeance:SetFrameLevel(10)
			Vengeance:SetPoint("TOPLEFT", TukuiInfoMiddle, TukuiDB.Scale(2), TukuiDB.Scale(-2))
			Vengeance:SetPoint("BOTTOMRIGHT", TukuiInfoMiddle, TukuiDB.Scale(-2), TukuiDB.Scale(2))
			Vengeance:SetStatusBarTexture(normTex)
			Vengeance:GetStatusBarTexture():SetHorizTile(false)
			Vengeance:SetStatusBarColor(.6, .2, .2 )
			Vengeance:SetBackdrop({bgFile = C.media.blank})
			Vengeance:SetBackdropColor(0, 0, 0, 0)
			
			Vengeance.Text = T.SetFontString(Vengeance, C.media.font, 12)
			Vengeance.Text:SetPoint("CENTER")
			
			Vengeance.bg = Vengeance:CreateTexture(nil, 'BORDER')
			Vengeance.bg:SetAllPoints(Vengeance)
			Vengeance.bg:SetTexture(unpack(C["media"].backdropcolor))
			
			self.Vengeance = Vengeance
			
			-- show druid mana when shapeshifted in bear, cat or whatever
			if T.myclass == "DRUID" then
				CreateFrame("Frame"):SetScript("OnUpdate", function() T.UpdateDruidMana(self) end)
				local DruidMana = T.SetFontString(health, font1, 12)
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana
			end
		
			if C["unitframes"].classbar then
				if T.myclass == "DRUID" then			
					local eclipseBar = CreateFrame('Frame', nil, self)
					eclipseBar:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 1)
					if T.lowversion then
						eclipseBar:Size(186, 8)
					else
						eclipseBar:Size(103, 8)
					end
					eclipseBar:SetFrameStrata("MEDIUM")
					eclipseBar:SetFrameLevel(8)
					eclipseBar:SetTemplate("Default")
					eclipseBar:SetBackdropBorderColor(0,0,0,0)
					eclipseBar:SetScript("OnShow", function() T.EclipseDisplay(self, false) end)
					eclipseBar:SetScript("OnUpdate", function() T.EclipseDisplay(self, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
					eclipseBar:SetScript("OnHide", function() T.EclipseDisplay(self, false) end)
					
					local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
					lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
					lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					lunarBar:SetStatusBarTexture(normTex)
					lunarBar:SetStatusBarColor(.30, .52, .90)
					eclipseBar.LunarBar = lunarBar

					local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
					solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
					solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					solarBar:SetStatusBarTexture(normTex)
					solarBar:SetStatusBarColor(.80, .82,  .60)
					eclipseBar.SolarBar = solarBar

					local eclipseBarText = eclipseBar:CreateFontString(nil, 'OVERLAY')
					eclipseBarText:SetPoint('TOP', health)
					eclipseBarText:SetPoint('BOTTOM', health)
					eclipseBarText:SetFont(font1, 12)
					eclipseBar.PostUpdatePower = T.EclipseDirection
					
					-- hide "low mana" text on load if eclipseBar is show
					if eclipseBar and eclipseBar:IsShown() then FlashInfo.ManaLevel:SetAlpha(0) end

					self.EclipseBar = eclipseBar
					self.EclipseBar.Text = eclipseBarText
				end

				-- set holy power bar or shard bar
				if (T.myclass == "WARLOCK" or T.myclass == "PALADIN") then
					self.shadow:Point("TOPLEFT", -4, 11)
		
					local bars = CreateFrame("Frame", nil, self)
					bars:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 15, -2)
					if T.lowversion then
						bars:Width(186)
					else
						--bars:Width(128)
						bars:Width(103)
					end
					bars:Height(5)
					bars:SetFrameLevel(4)
					bars:SetTemplate("Default")
					bars:SetBackdropBorderColor(0,0,0,0)
					
					-- holy power border
					local holyborder = CreateFrame("Frame", nil, self)
					holyborder:CreatePanel("Default", 1, 1, "CENTER", bars, "CENTER", 0, 0)
					holyborder:ClearAllPoints()
					holyborder:Point("TOPLEFT", bars, -2, 2)
					holyborder:Point("BOTTOMRIGHT", bars, 2, -2)
					holyborder:SetFrameLevel(4)
					holyborder:SetFrameStrata("MEDIUM")
					
					for i = 1, 3 do					
						bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, self)
						bars[i]:Height(5)		
						bars[i]:SetFrameLevel(4)
						bars[i]:SetStatusBarTexture(normTex)
						bars[i]:GetStatusBarTexture():SetHorizTile(false)

						bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
						
						if T.myclass == "WARLOCK" then
							bars[i]:SetStatusBarColor(255/255,101/255,101/255)
							bars[i].bg:SetTexture(255/255,101/255,101/255)
						elseif T.myclass == "PALADIN" then
							bars[i]:SetStatusBarColor(228/255,225/255,16/255)
							bars[i].bg:SetTexture(228/255,225/255,16/255)
						end
						
						if i == 1 then
							bars[i]:SetPoint("LEFT", bars)
							if T.lowversion then
								bars[i]:Width(62)
							else
								bars[i]:Width(100/3) -- setting SetWidth here just to fit fit 250 perfectly
							end
							bars[i].bg:SetAllPoints(bars[i])
						else
							bars[i]:Point("LEFT", bars[i-1], "RIGHT", 1, 0)
							if T.lowversion then
								bars[i]:Width(61)
							else
								bars[i]:Width(100/3) -- setting SetWidth here just to fit fit 250 perfectly
							end
							bars[i].bg:SetAllPoints(bars[i])
						end
						
						bars[i].bg:SetTexture(normTex)					
						bars[i].bg:SetAlpha(.15)
					end
					
					if T.myclass == "WARLOCK" then
						bars.Override = T.UpdateShards				
						self.SoulShards = bars
					elseif T.myclass == "PALADIN" then
						bars.Override = T.UpdateHoly
						self.HolyPower = bars
					end
				end

				-- deathknight runes
				if T.myclass == "DEATHKNIGHT" then
					-- rescale top shadow border
					self.shadow:Point("TOPLEFT", -4, 11)
					
					local Runes = CreateFrame("Frame", nil, self)
					Runes:Point("BOTTOMLEFT", self, "TOPLEFT", 15,-2)
					Runes:Height(5)
					if T.lowversion then
						Runes:SetWidth(186)
					else
						Runes:SetWidth(106)
					end
					Runes:SetBackdrop(backdrop)
					Runes:SetBackdropColor(0, 0, 0)

					-- Rune border
					local runeborder = CreateFrame("Frame", nil, self)
					runeborder:CreatePanel("Default", 1, 1, "CENTER", Runes, "CENTER", 0, 0)
					runeborder:ClearAllPoints()
					runeborder:Point("TOPLEFT", Runes, -2, 2)
					runeborder:Point("BOTTOMRIGHT", Runes, 2, -2)
					runeborder:SetFrameLevel(4)
					runeborder:SetFrameStrata("MEDIUM")
					
					
					for i = 1, 6 do
						Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, health)
						Runes[i]:SetHeight(5)
						if T.lowversion then
							if i == 1 then
								Runes[i]:SetWidth(31)
							else
								Runes[i]:SetWidth(30)
							end
						else
							if i == 1 then
								Runes[i]:SetWidth(100/6)
							else
								Runes[i]:SetWidth(100/6)
							end
						end
						if (i == 1) then
							Runes[i]:Point("BOTTOMLEFT", Runes, "TOPLEFT", 0, -5)
						else
							Runes[i]:Point("TOPLEFT", Runes[i-1], "TOPRIGHT", 1, 0)
						end
						Runes[i]:SetStatusBarTexture(normTex)
						Runes[i]:GetStatusBarTexture():SetHorizTile(false)
					end

					self.Runes = Runes
				end
				
				-- shaman totem bar
				if T.myclass == "SHAMAN" then
					-- rescale top shadow border
					self.shadow:Point("TOPLEFT", -4, 12)
					
					local TotemBar = {}
					TotemBar.Destroy = true
					for i = 1, 4 do
						TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
						if (i == 1) then
						   TotemBar[i]:Point("BOTTOMLEFT", self, "TOPLEFT", 0, 1)
						else
						   TotemBar[i]:Point("TOPLEFT", TotemBar[i-1], "TOPRIGHT", 1, 0)
						end
						TotemBar[i]:SetStatusBarTexture(normTex)
						TotemBar[i]:Height(8)
						if T.lowversion then
							if i == 1 then
								TotemBar[i]:SetWidth(45)
							else
								TotemBar[i]:SetWidth(46)
							end
						else
							if i == 4 then
								TotemBar[i]:SetWidth(61)
							else
								TotemBar[i]:SetWidth(62)
							end
						end
						TotemBar[i]:SetBackdrop(backdrop)
						TotemBar[i]:SetBackdropColor(0, 0, 0)
						TotemBar[i]:SetMinMaxValues(0, 1)

						TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
						TotemBar[i].bg:SetAllPoints(TotemBar[i])
						TotemBar[i].bg:SetTexture(normTex)
						TotemBar[i].bg.multiplier = 0.3
					end
					self.TotemBar = TotemBar
				end
			end
			
			-- scripts for pvp status and low mana
			self:SetScript("OnEnter", function(self)
				if self.EclipseBar and self.EclipseBar:IsShown() then
					self.EclipseBar.Text:Hide()
				end
				FlashInfo.ManaLevel:SetAlpha(0)
				status:SetAlpha(1)
				UnitFrame_OnEnter(self)
			end)
			self:SetScript("OnLeave", function(self) 
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Show()
				end
				FlashInfo.ManaLevel:SetAlpha(1)
				status:SetAlpha(0) 
				UnitFrame_OnLeave(self) 
			end)
		end
		
		if (unit == "target") then			
			-- Unit name on target
			local Name = health:CreateFontString(nil, "OVERLAY")
			Name:Point("CENTER", panel, "CENTER", 0, -10)
			Name:SetJustifyH("LEFT")
			Name:SetShadowColor(0, 0, 0)
			Name:SetShadowOffset(1.25, -1.25)
			Name:SetFont(font1, 12)
			if C["unitframes"].unicolor == true then
				self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
				Name:Point("RIGHT", panel, "RIGHT", 0, -4)
				Name:SetJustifyH("RIGHT")
			else
				self:Tag(Name, '[Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
				Name:Point("RIGHT", panel, "RIGHT", 0, -4)
				Name:SetJustifyH("RIGHT")
			end
			self.Name = Name
			
			-- combo points on target
			local CPoints = {}
			CPoints.unit = PlayerFrame.unit
			for i = 1, 5 do
				CPoints[i] = self:CreateTexture(nil, "OVERLAY")
				CPoints[i]:Height(12)
				CPoints[i]:Width(12)
				CPoints[i]:SetTexture(bubbleTex)
				if i == 1 then
					if T.lowversion then
						CPoints[i]:Point("TOPRIGHT", 15, 1.5)
					else
						CPoints[i]:Point("TOPLEFT", -15, 1.5)
					end
					CPoints[i]:SetVertexColor(0.69, 0.31, 0.31)
				else
					CPoints[i]:Point("TOP", CPoints[i-1], "BOTTOM", 1)
				end
			end
			CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
			CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
			CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
			CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
			self.CPoints = CPoints
		end
		
		-- buff stuff
		if (unit == "target" and C["unitframes"].targetauras) or (unit == "player" and C["unitframes"].playerauras) then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)
			
			if (T.myclass == "SHAMAN" or T.myclass == "DEATHKNIGHT" or T.myclass == "PALADIN" or T.myclass == "WARLOCK") and (C["unitframes"].playerauras) and (unit == "player") then
				if T.lowversion then
					buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 34)
				else
					buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 34)
				end
			else
				if T.lowversion then
					buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 26)
				else
					buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 30)
				end
			end
			
			if T.lowversion then
				buffs:SetHeight(21.5)
				buffs:SetWidth(186)
				buffs.size = 21.5
				buffs.num = 8
				
				debuffs:SetHeight(21.5)
				debuffs:SetWidth(186)
				debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 0, 2)
				debuffs.size = 21.5	
				debuffs.num = 24
			else				
				buffs:SetHeight(26)
				buffs:SetWidth(252)
				buffs.size = 26
				buffs.num = 9
				
				debuffs:SetHeight(26)
				debuffs:SetWidth(252)
				debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", -2, 2)
				debuffs.size = 26
				debuffs.num = 27
			end
						
			buffs.spacing = 2
			buffs.initialAnchor = 'TOPLEFT'
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs	
						
			debuffs.spacing = 2
			debuffs.initialAnchor = 'TOPRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			
			-- an option to show only our debuffs on target
			if unit == "target" then
				debuffs.onlyShowPlayer = C.unitframes.onlyselfdebuffs
			end
			
			self.Debuffs = debuffs
		end
		
		-- add combat feedback support
		if C["unitframes"].combatfeedback == true then
			local CombatFeedbackText 
			if T.lowversion then
				CombatFeedbackText = T.SetFontString(health, font1, 12, "OUTLINE")
			else
				CombatFeedbackText = T.SetFontString(health, font1, 14, "OUTLINE")
			end
			CombatFeedbackText:SetPoint("CENTER", 0, 1)
			CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
			self.CombatFeedbackText = CombatFeedbackText
		end
		
		-- healcomm
		if C["unitframes"].healcomm then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			if T.lowversion then
				mhpb:SetWidth(186)
			else
				mhpb:SetWidth(250)
			end
			mhpb:SetStatusBarTexture(normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
			mhpb:SetMinMaxValues(0,1)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetWidth(250)
			ohpb:SetStatusBarTexture(normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end
		
		-- player aggro
		if C["unitframes"].playeraggro == true then
			table.insert(self.__elements, T.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
		end
	end
	
	------------------------------------------------------------------------
	--	Target of Target unit layout
	------------------------------------------------------------------------
	if (unit == "targettarget") then
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(18)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		health:SetFrameLevel(2)
		
		-- health border
		local healthborder = CreateFrame("Frame", nil, self)
		healthborder:CreatePanel("Default", 1, 1, "CENTER", health, "CENTER", 0, 0)
		healthborder:Point("TOPLEFT", health, -2, 2)
		healthborder:Point("BOTTOMRIGHT", health, 2, -2)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.2, .2, .2, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true
		end
		
		-- Unit Name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("RIGHT", health, "RIGHT", -4, 0)
		Name:SetFont(font1, 12)
		Name:SetJustifyH("RIGHT")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, 1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		-- portraits
		if (C["unitframes"].charportrait == true) then
            local portrait = CreateFrame("PlayerModel", nil, health)
            portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end -- change the 0.15 to the alphavalue you want
			if C["unitframes"].unicolor == true then
				portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.10) end
			end
            portrait:SetAllPoints(health)
			portrait:SetFrameLevel(3)
            table.insert(self.__elements, T.HidePortrait)
            self.Portrait = portrait
        end
		
		if C["unitframes"].totdebuffs == true and T.lowversion ~= true then
			local debuffs = CreateFrame("Frame", nil, health)
			debuffs:SetHeight(20)
			debuffs:SetWidth(127)
			debuffs.size = 20
			debuffs.spacing = 2
			debuffs.num = 6
			
			debuffs:SetPoint("TOPLEFT", health, "TOPLEFT", -0.5, 24)
			debuffs.initialAnchor = "TOPLEFT"
			debuffs["growth-y"] = "UP"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			self.Debuffs = debuffs
		end
	end
	
	return self
end	-- END!

------------------------------------------------------------------------
--	Default position of Tukui unitframes
------------------------------------------------------------------------

oUF:RegisterStyle('Tukui', Shared)

-- player
local player = oUF:Spawn('player', "TukuiPlayer")
player:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "TOPLEFT", 0,28)
player:Size(250, 36)

-- target
local target = oUF:Spawn('target', "TukuiTarget")
target:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", 0, 28)
target:Size(250, 36)

-- tot
local tot = oUF:Spawn('targettarget', "TukuiTargetTarget")
tot:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0, 28)
tot:Size(186, 18)

-- this is just a fake party to hide Blizzard frame if no Tukui raid layout are loaded.
local party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)

------------------------------------------------------------------------
-- Right-Click on unit frames menu. 
-- Doing this to remove SET_FOCUS eveywhere.
-- SET_FOCUS work only on default unitframes.
-- Main Tank and Main Assist, use /maintank and /mainassist commands.
------------------------------------------------------------------------

do
	UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "CONVERT_TO_PARTY", "CONVERT_TO_RAID", "LEAVE", "CANCEL" };
	UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
	UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
	UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
	UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
	UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
	UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
end