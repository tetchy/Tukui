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

local font1 = C["media"].uffontp
local font2 = C["media"].font
local normTex = C["media"].normTex
local glowTex = C["media"].glowTex
local bubbleTex = C["media"].bubbleTex
local fontsize = 10

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
		
		health.value = T.SetFontString(health, font1, fontsize, 'THINOUTLINE')
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
		
		power.value = T.SetFontString(health, font1, fontsize, 'THINOUTLINE')
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
				portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end
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
			-- Unit name on target
			if C["unitframes"].showownname == true then
				local Name = health:CreateFontString(nil, "OVERLAY")
				Name:Point("BOTTOMLEFT", health, "BOTTOMLEFT", 4, 4)
				Name:SetJustifyH("LEFT")
				Name:SetFont(font1, fontsize, 'THINOUTLINE')
				--Name:SetShadowColor(0, 0, 0)
				--Name:SetShadowOffset(1.25, -1.25)
				
				self:Tag(Name, '[Tukui:diffcolor][level] [Tukui:getnamecolor][Tukui:namelong][shortclassification]')
				self.Name = Name
			end
			
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
			FlashInfo.ManaLevel = T.SetFontString(FlashInfo, font1, fontsize, 'THINOUTLINE')
			FlashInfo.ManaLevel:SetPoint("CENTER", panel, "CENTER", 0, 0)
			self.FlashInfo = FlashInfo
		
			-- pvp status text
			local status = T.SetFontString(panel, font1, fontsize, 'THINOUTLINE')
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
				Experience:Width(TukuiInfoMiddle:GetWidth() - 4)
				Experience:Height(TukuiInfoMiddle:GetHeight() - 4)
				Experience:Point("TOPLEFT", TukuiInfoMiddle, 2, -2)
				Experience:Point("BOTTOMRIGHT", TukuiInfoMiddle, -2, 2)
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
					Resting:SetPoint("LEFT", -38, 38)
				else
					Resting:SetPoint("LEFT", -38, 38)
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
				
			Reputation.Text = T.SetFontString(Reputation, C.media.font, fontsize)
			Reputation.Text:SetPoint("CENTER")
			Reputation.Text:SetAlpha(1)
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
			
			Vengeance.Text = T.SetFontString(Vengeance, font1, fontsize)
			Vengeance.Text:SetPoint("CENTER")
			
			Vengeance.bg = Vengeance:CreateTexture(nil, 'BORDER')
			Vengeance.bg:SetAllPoints(Vengeance)
			Vengeance.bg:SetTexture(unpack(C["media"].backdropcolor))
			
			self.Vengeance = Vengeance
			
			-- show druid mana when shapeshifted in bear, cat or whatever
			if T.myclass == "DRUID" then
				CreateFrame("Frame"):SetScript("OnUpdate", function() T.UpdateDruidMana(self) end)
				local DruidMana = T.SetFontString(health, font1, fontsize, 'THINOUTLINE')
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana
			end
		
			if C["unitframes"].classbar then
				if T.myclass == "DRUID" then			
					local eclipseBar = CreateFrame('Frame', nil, self)
					eclipseBar:Point("BOTTOMLEFT", self, "TOPLEFT", 15, -2)
					if T.lowversion then
						eclipseBar:Size(186, 5)
					else
						eclipseBar:Size(103, 5)
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
					
					local lunarborder = CreateFrame("Frame", nil, eclipseBar)
					lunarborder:CreatePanel("Default", 1, 1, "CENTER", eclipseBar, "CENTER", 0, 0)
					lunarborder:ClearAllPoints()
					lunarborder:Point("TOPLEFT", eclipseBar, -2, 2)
					lunarborder:Point("BOTTOMRIGHT", eclipseBar, 2, -2)
					lunarborder:SetFrameLevel(4)
					lunarborder:SetFrameStrata("MEDIUM")

					local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
					solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
					solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
					solarBar:SetStatusBarTexture(normTex)
					solarBar:SetStatusBarColor(.80, .82,  .60)
					eclipseBar.SolarBar = solarBar

					local eclipseBarText = eclipseBar:CreateFontString(nil, 'OVERLAY')
					eclipseBarText:SetPoint('TOP', health)
					eclipseBarText:SetPoint('BOTTOM', health)
					eclipseBarText:SetFont(font1, fontsize, 'THINOUTLINE')
					eclipseBarText:SetShadowColor(0, 0, 0)
					eclipseBarText:SetShadowOffset(1.25, -1.25)
					eclipseBarText.frequentUpdates = 0.2
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
					self.shadow:Point("TOPLEFT", -4, 11)
					
					--local TotemBar = {}
					--TotemBar.Destroy = true
					local TotemBar = CreateFrame("Frame", nil, self)
					TotemBar:Point("BOTTOMLEFT", self, "TOPLEFT", 15, -2)
					TotemBar:Height(5)
					TotemBar:SetFrameLevel(4)
					if T.lowversion then
						TotemBar:SetWidth(186)
					else
						TotemBar:SetWidth(103)
					end
					TotemBar:SetBackdrop(backdrop)
					TotemBar:SetBackdropColor(0, 0, 0)
					
					-- Totembar Border
					local totemborder = CreateFrame("Frame", nil, self)
					totemborder:CreatePanel("Default", 1, 1, "CENTER", TotemBar, "CENTER", 0, 0)
					totemborder:ClearAllPoints()
					totemborder:Point("TOPLEFT", TotemBar, -2, 2)
					totemborder:Point("BOTTOMRIGHT", TotemBar, 2, -2)
					totemborder:SetFrameLevel(4)
					totemborder:SetFrameStrata("MEDIUM")
					
					for i = 1, 4 do
						TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, health)
						if (i == 1) then
						   TotemBar[i]:Point("BOTTOMLEFT", TotemBar, "TOPLEFT", 0, -5)
						else
						   TotemBar[i]:Point("TOPLEFT", TotemBar[i-1], "TOPRIGHT", 1, 0)
						end
						TotemBar[i]:SetStatusBarTexture(normTex)
						TotemBar[i]:Height(5)
						if T.lowversion then
							if i == 1 then
								TotemBar[i]:SetWidth(100/4)
							else
								TotemBar[i]:SetWidth(100/4)
							end
						else
							if i == 4 then
								TotemBar[i]:SetWidth(100/4)
							else
								TotemBar[i]:SetWidth(100/4)
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
			Name:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", 0, 4)
			Name:SetJustifyH("RIGHT")
			Name:SetFont(font1, fontsize, 'THINOUTLINE')
			Name:SetShadowColor(0, 0, 0)
			Name:SetShadowOffset(1.25, -1.25)
			
			self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
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
					CPoints[i]:Point("TOPLEFT", -15, 1.5)
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
				buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 34)
			else
				buffs:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 30)
			end


			buffs:SetHeight(26)
			buffs:SetWidth(250)
			buffs.size = 26.5
			buffs.num = 9
				
			debuffs:SetHeight(26)
			debuffs:SetWidth(250)
			debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 5, 2)
			debuffs.size = 26.5
			debuffs.num = 27
						
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
		
		-- cast bar for player and target
		if (C["unitframes"].unitcastbar == true) then
			-- castbar of player and target
			local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			castbar:SetStatusBarTexture(normTex)
			
			castbar.bg = castbar:CreateTexture(nil, "BORDER")
			castbar.bg:SetAllPoints(castbar)
			castbar.bg:SetTexture(normTex)
			castbar.bg:SetVertexColor(0.15, 0.15, 0.15)
			castbar:SetFrameLevel(6)
			castbar:Point("TOP", self, "BOTTOM", 0, -11)
			castbar:Size(250, 18)
						
			local cbborder = CreateFrame("Frame", nil, castbar)
			TukuiDB.CreatePanel(cbborder, 1, 1, "CENTER", castbar, "CENTER", 0, 0)
			cbborder:ClearAllPoints()
			cbborder:SetPoint("TOPLEFT", castbar, TukuiDB.Scale(-2), TukuiDB.Scale(2))
			cbborder:SetPoint("BOTTOMRIGHT", castbar, TukuiDB.Scale(2), TukuiDB.Scale(-2))
			
			castbar.CustomTimeText = T.CustomCastTimeText
			castbar.CustomDelayText = T.CustomCastDelayText
			castbar.PostCastStart = T.CheckCast
			castbar.PostChannelStart = T.CheckChannel

			castbar.time = T.SetFontString(castbar, font1, fontsize)
			castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")

			castbar.Text = T.SetFontString(castbar, font1, fontsize)
			castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			castbar.Text:SetWidth(200)
			
			if C["unitframes"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:Size(26)
				castbar.button:SetTemplate("Default")
				castbar.button:CreateShadow("Default")

				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
				castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
			
				if unit == "player" then
					castbar.button:SetPoint("LEFT", -46.5, 26.5)
				elseif unit == "target" then
					castbar.button:SetPoint("RIGHT", 46.5, 26.5)
				end
			end
			
			-- cast bar latency on player
			if unit == "player" and C["unitframes"].cblatency == true then
				castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
				castbar.safezone:SetTexture(normTex)
				castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
				castbar.SafeZone = castbar.safezone
			end
					
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- add combat feedback support
		if C["unitframes"].combatfeedback == true then
			local CombatFeedbackText 
			if T.lowversion then
				CombatFeedbackText = T.SetFontString(health, font1, fontsize, "OUTLINE")
			else
				CombatFeedbackText = T.SetFontString(health, font1, fontsize, "OUTLINE")
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
			mhpb:SetFrameLevel(3)
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
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Size(100, 5)
		power:Point("LEFT", health, "BOTTOMLEFT", 10, -2)
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
		
		power.value = T.SetFontString(health, font1, fontsize, 'THINOUTLINE')
		power.value:Point("LEFT", health, "LEFT", 4, 0)
		power.PreUpdate = T.PreUpdatePower
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
		
		-- Unit Name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("RIGHT", health, "RIGHT", -4, 0)
		Name:SetJustifyH("RIGHT")
		Name:SetFont(font1, fontsize, 'THINOUTLINE')
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		Name.frequentUpdates = 0.2
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		-- portraits
		if (C["unitframes"].charportrait == true) then
            local portrait = CreateFrame("PlayerModel", nil, health)
            portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end -- change the 0.15 to the alphavalue you want
			if C["unitframes"].unicolor == true then
				portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end
			end
            portrait:SetAllPoints(health)
			portrait:SetFrameLevel(3)
            table.insert(self.__elements, T.HidePortrait)
            self.Portrait = portrait
        end
		
		if C["unitframes"].totdebuffs == true and T.lowversion ~= true then
			local debuffs = CreateFrame("Frame", nil, health)
			debuffs:SetHeight(20)
			debuffs:SetWidth(186)
			debuffs.size = 20
			debuffs.spacing = 2
			debuffs.num = 6
			
			debuffs:SetPoint("TOPLEFT", health, "TOPLEFT", -3, 24)
			debuffs.initialAnchor = "TOPLEFT"
			debuffs["growth-y"] = "UP"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			self.Debuffs = debuffs
		end
	end
	
	------------------------------------------------------------------------
	--	Pet unit layout
	------------------------------------------------------------------------
	
	if (unit == "pet") then
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
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Size(50, 5)
		power:Point("BOTTOM", health, "BOTTOM", -8, -4)
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
		
		power.value = T.SetFontString(health, font1, fontsize, 'THINOUTLINE')
		power.value:Point("LEFT", health, "LEFT", 4, 0)
		power.PreUpdate = T.PreUpdatePower
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
		
		-- Unit Name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("RIGHT", health, "RIGHT", -4, 0)
		Name:SetJustifyH("RIGHT")
		Name:SetFont(font1, fontsize, 'THINOUTLINE')
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		Name.frequentUpdates = 0.2
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		-- portraits
		if (C["unitframes"].charportrait == true) then
            local portrait = CreateFrame("PlayerModel", nil, health)
            portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) 
		end 
		if C["unitframes"].unicolor == true then
			portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.10) end
		end
            portrait:SetAllPoints(health)
			portrait:SetFrameLevel(3)
            table.insert(self.__elements, T.HidePortrait)
            self.Portrait = portrait
        end
	
		if (C["unitframes"].unitcastbar == true) then
			local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			castbar:SetStatusBarTexture(normTex)
			self.Castbar = castbar
		
			if not T.lowversion then
				castbar.bg = castbar:CreateTexture(nil, "BORDER")
				castbar.bg:SetAllPoints(castbar)
				castbar.bg:SetTexture(normTex)
				castbar.bg:SetVertexColor(0.15, 0.15, 0.15)
				castbar:SetFrameLevel(6)
				castbar:Point("TOPLEFT", health, 2, -2)
				castbar:Point("BOTTOMRIGHT", health, -2, 2)
				castbar.CustomTimeText = T.CustomCastTimeText
				castbar.CustomDelayText = T.CustomCastDelayText
				castbar.PostCastStart = T.CheckCast
				castbar.PostChannelStart = T.CheckChannel

				castbar.time = T.SetFontString(castbar, font1, fontsize)
				castbar.time:Point("RIGHT", health, "RIGHT", -4, 0)
				castbar.time:SetTextColor(0.84, 0.75, 0.65)
				castbar.time:SetJustifyH("RIGHT")

				castbar.Text = T.SetFontString(castbar, font1, fontsize)
				castbar.Text:Point("LEFT", health, "LEFT", 4, 0)
				castbar.Text:SetTextColor(0.84, 0.75, 0.65)
				
				self.Castbar.Time = castbar.time
			end
		end
		
		-- update pet frame 
		self:RegisterEvent("UNIT_PET", T.updateALLElements)
	end
	
	
	------------------------------------------------------------------------
	--	Focus unit layout
	------------------------------------------------------------------------
	
	if (unit == "focus") then
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(29)
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
		
		health.value = T.SetFontString(health, font1, fontsize, 'THINOUTLINE')
		health.value:Point("RIGHT", health, "RIGHT", -4, 0)
		health.PostUpdate = T.PostUpdateHealth
		
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth then
			health.Smooth = true
		end
		
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
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Size(100, 5)
		power:Point("LEFT", health, "BOTTOMLEFT", 10, -2)
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
		
		power.value = T.SetFontString(health, font1, fontsize, 'THINOUTLINE')
		power.value:Point("LEFT", health, "LEFT", 4, 0)
		power.PreUpdate = T.PreUpdatePower
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
		
		-- Unit Name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", -4, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, fontsize, 'THINOUTLINE')
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		Name.frequentUpdates = 0.2
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		-- portraits
		if (C["unitframes"].charportrait == true) then
            local portrait = CreateFrame("PlayerModel", nil, health)
            portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end -- change the 0.15 to the alphavalue you want
			if C["unitframes"].unicolor == true then
				portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end
			end
            portrait:SetAllPoints(health)
			portrait:SetFrameLevel(3)
            table.insert(self.__elements, T.HidePortrait)
            self.Portrait = portrait
        end

		-- create debuff for arena units
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(26)
		debuffs:SetWidth(200)
		debuffs:Point('RIGHT', self, 'LEFT', -4, 0)
		debuffs.size = 26
		debuffs.num = 5
		debuffs.spacing = 2
		debuffs.initialAnchor = 'RIGHT'
		debuffs["growth-x"] = "LEFT"
		debuffs.PostCreateIcon = T.PostCreateAura
		debuffs.PostUpdateIcon = T.PostUpdateAura
		self.Debuffs = debuffs
		
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
		castbar:SetPoint("LEFT", 0, 0)
		castbar:SetPoint("RIGHT", -23, 0)
		castbar:SetPoint("BOTTOM", 0, -30)
		
		castbar:SetHeight(18)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("Default")
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, font1, fontsize)
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, font1, fontsize)
		castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		castbar.Text:SetWidth(150)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel
								
		castbar.button = CreateFrame("Frame", nil, castbar)
		castbar.button:Height(23)
		castbar.button:Width(22)
		castbar.button:Point("LEFT", castbar, "RIGHT", 4, 0)
		castbar.button:SetTemplate("Default")
		castbar.button:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
		castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
		castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
		castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
		self.Castbar.Icon = castbar.icon
	end
	
	------------------------------------------------------------------------
	-- Focus target unit layout
	------------------------------------------------------------------------
	
	if (unit == "focustarget") then
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
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Size(100, 5)
		power:Point("LEFT", health, "BOTTOMLEFT", 10, -2)
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
		
		power.value = T.SetFontString(health, font1, fontsize, 'THINOUTLINE')
		power.value:Point("LEFT", health, "LEFT", 4, 0)
		power.PreUpdate = T.PreUpdatePower
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
		
		-- Unit Name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("RIGHT", health, "RIGHT", -4, 0)
		Name:SetJustifyH("RIGHT")
		Name:SetFont(font1, fontsize, 'THINOUTLINE')
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		Name.frequentUpdates = 0.2
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		-- portraits
		if (C["unitframes"].charportrait == true) then
            local portrait = CreateFrame("PlayerModel", nil, health)
            portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end -- change the 0.15 to the alphavalue you want
			if C["unitframes"].unicolor == true then
				portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end
			end
            portrait:SetAllPoints(health)
			portrait:SetFrameLevel(3)
            table.insert(self.__elements, T.HidePortrait)
            self.Portrait = portrait
        end
		
		if C["unitframes"].totdebuffs == true and T.lowversion ~= true then
			local debuffs = CreateFrame("Frame", nil, health)
			debuffs:SetHeight(20)
			debuffs:SetWidth(186)
			debuffs.size = 20
			debuffs.spacing = 2
			debuffs.num = 6
			
			debuffs:SetPoint("TOPLEFT", health, "TOPLEFT", -2, 24)
			debuffs.initialAnchor = "TOPLEFT"
			debuffs["growth-y"] = "UP"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			self.Debuffs = debuffs
		end
	end
	
	------------------------------------------------------------------------
	--	Arena or boss units layout (both mirror'd)
	------------------------------------------------------------------------
	
	if (unit and unit:find("arena%d") and C["arena"].unitframes == true) or (unit and unit:find("boss%d") and C["unitframes"].showboss == true) then
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(24)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		health:SetFrameLevel(3)
		
		-- health bar background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
	
		health.value = T.SetFontString(health, font1, fontsize, 'THINOUTLINE')
		health.value:Point("RIGHT", health, "RIGHT", -4, 0)
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
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
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true -- false
			health.colorReaction = true			
		end

		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Size(100, 5)
		power:Point("RIGHT", health, "BOTTOMRIGHT", -10, -2)
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
		
		-- ugly ass code block, clean this later
		local healthborder = CreateFrame("Frame", nil, self)
		healthborder:CreatePanel("Default", 1, 1, "CENTER", health, "CENTER", 0, 0)
		healthborder:ClearAllPoints()
		healthborder:Point("TOPLEFT", health, -2, 2)
		healthborder:Point("BOTTOMRIGHT", health, 2, -2)
		healthborder:SetFrameLevel(2)
		healthborder:SetFrameStrata("MEDIUM")
		
		power.value = T.SetFontString(health, font1, fontsize, 'THINOUTLINE')
		power.value:Point("LEFT", health, "LEFT", 4, 0)
		power.PreUpdate = T.PreUpdatePower
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
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, fontsize, 'THINOUTLINE')
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		Name.frequentUpdates = 0.2
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong]')
		self.Name = Name
		
		-- portraits
		if (C["unitframes"].charportrait == true) then
            local portrait = CreateFrame("PlayerModel", nil, health)
            portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end -- change the 0.15 to the alphavalue you want
			if C["unitframes"].unicolor == true then
				portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.20) end
			end
            portrait:SetAllPoints(health)
			portrait:SetFrameLevel(3)
            table.insert(self.__elements, T.HidePortrait)
            self.Portrait = portrait
        end
		
		if (unit and unit:find("boss%d")) then
			-- alt power bar
			local AltPowerBar = CreateFrame("StatusBar", nil, self.Health)
			AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
			AltPowerBar:Height(4)
			AltPowerBar:SetStatusBarTexture(C.media.normTex)
			AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
			AltPowerBar:SetStatusBarColor(1, 0, 0)

			AltPowerBar:SetPoint("LEFT")
			AltPowerBar:SetPoint("RIGHT")
			AltPowerBar:SetPoint("TOP", self.Health, "TOP")
			
			AltPowerBar:SetBackdrop({
			  bgFile = C["media"].blank, 
			  edgeFile = C["media"].blank, 
			  tile = false, tileSize = 0, edgeSize = T.Scale(1), 
			  insets = { left = 0, right = 0, top = 0, bottom = T.Scale(-1)}
			})
			AltPowerBar:SetBackdropColor(0, 0, 0)

			self.AltPowerBar = AltPowerBar
			
			-- create buff at left of unit if they are boss units
			local buffs = CreateFrame("Frame", nil, self)
			buffs:SetHeight(26)
			buffs:SetWidth(252)
			buffs:Point("RIGHT", self, "LEFT", -5, 0)
			buffs.size = 26
			buffs.num = 3
			buffs.spacing = 3
			buffs.initialAnchor = 'RIGHT'
			buffs["growth-x"] = "LEFT"
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs
			
			-- because it appear that sometime elements are not correct.
			self:HookScript("OnShow", T.updateAllElements)
		end

		-- create debuff for arena units
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(26)
		debuffs:SetWidth(200)
		debuffs:SetPoint('LEFT', self, 'RIGHT', T.Scale(4), 0)
		debuffs.size = 26
		debuffs.num = 5
		debuffs.spacing = 2
		debuffs.initialAnchor = 'LEFT'
		debuffs["growth-x"] = "RIGHT"
		debuffs.PostCreateIcon = T.PostCreateAura
		debuffs.PostUpdateIcon = T.PostUpdateAura
		self.Debuffs = debuffs
				
		-- trinket feature via trinket plugin
		if (C.arena.unitframes) and (unit and unit:find('arena%d')) then
			local Trinketbg = CreateFrame("Frame", nil, self)
			Trinketbg:SetHeight(26)
			Trinketbg:SetWidth(26)
			Trinketbg:SetPoint("RIGHT", self, "LEFT", -6, 0)				
			Trinketbg:SetTemplate("Default")
			Trinketbg:SetFrameLevel(0)
			self.Trinketbg = Trinketbg
			
			local Trinket = CreateFrame("Frame", nil, Trinketbg)
			Trinket:SetAllPoints(Trinketbg)
			Trinket:SetPoint("TOPLEFT", Trinketbg, T.Scale(2), T.Scale(-2))
			Trinket:SetPoint("BOTTOMRIGHT", Trinketbg, T.Scale(-2), T.Scale(2))
			Trinket:SetFrameLevel(1)
			Trinket.trinketUseAnnounce = true
			self.Trinket = Trinket
		end
		
		-- boss & arena frames cast bar!
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
		castbar:SetPoint("LEFT", 23, 0)
		castbar:SetPoint("RIGHT", 0, 0)
		castbar:SetPoint("BOTTOM", 0, -27)
		
		castbar:SetHeight(16)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("Default")
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, font1, fontsize)
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, font1, fontsize)
		castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel
								
		castbar.button = CreateFrame("Frame", nil, castbar)
		castbar.button:Height(castbar:GetHeight()+4)
		castbar.button:Width(castbar:GetHeight()+4)
		castbar.button:Point("RIGHT", castbar, "LEFT",-5, 0)
		castbar.button:SetTemplate("Default")
		castbar.button:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
		castbar.icon:Point("TOPLEFT", castbar.button, T.Scale(2), T.Scale(-2))
		castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
		castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
		self.Castbar.Icon = castbar.icon
	end

	------------------------------------------------------------------------
	--	Main tanks and Main Assists layout (both mirror'd)
	------------------------------------------------------------------------
	
	if(self:GetParent():GetName():match"TukuiMainTank" or self:GetParent():GetName():match"TukuiMainAssist") then
		-- Right-click focus on maintank or mainassist units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(20)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		-- health border
		local healthborder = CreateFrame("Frame", nil, self)
		healthborder:CreatePanel("Default", 1, 1, "CENTER", health, "CENTER", 0, 0)
		healthborder:ClearAllPoints()
		healthborder:Point("TOPLEFT", health, -2, 2)
		healthborder:Point("BOTTOMRIGHT", health, 2, -2)
		healthborder:SetFrameLevel(2)
		healthborder:SetFrameStrata("MEDIUM")
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, fontsize, 'THINOUTLINE')
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort]')
		self.Name = Name
	end
	
	return self
end	-- END!

------------------------------------------------------------------------
--	Default position of Tukui unitframes
------------------------------------------------------------------------

oUF:RegisterStyle('Tukui', Shared)

-- player
local player = oUF:Spawn('player', "TukuiPlayer")
player:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "TOPLEFT", 0,48)
player:Size(250, 36)

-- focus
local focus = oUF:Spawn('focus', "TukuiFocus")
focus:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "TOPLEFT", -90, 246)
focus:Size(200, 29)

-- focus target
local focustarget = oUF:Spawn('focustarget', "TukuiFocusTarget")
focustarget:SetPoint("BOTTOM", focus, "TOP", 0, 35)
focustarget:Size(200, 18)

-- target
local target = oUF:Spawn('target', "TukuiTarget")
target:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", 0, 48)
target:Size(250, 36)

-- tot
local tot = oUF:Spawn('targettarget', "TukuiTargetTarget")
tot:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0, 48)
tot:Size(186, 18)

-- pet
local pet = oUF:Spawn('pet', "TukuiPet")
pet:SetPoint("TOP", TukuiTargetTarget, "BOTTOM", 0, -15)
pet:Size(120, 18)

if C.arena.unitframes then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "TukuiArena"..i)
		if i == 1 then
			arena[i]:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", 200, 246)
		else
			arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 35)
		end
		arena[i]:Size(186, 26)
	end
end

if C["unitframes"].showboss then
	for i = 1,MAX_BOSS_FRAMES do
		local t_boss = _G["Boss"..i.."TargetFrame"]
		t_boss:UnregisterAllEvents()
		t_boss.Show = T.dummy
		t_boss:Hide()
		_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
		_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
	end

	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = oUF:Spawn("boss"..i, "TukuiBoss"..i)
		if i == 1 then
			boss[i]:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", 200,246)
		else
			boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 34)             
		end
		boss[i]:Size(186, 26)
	end
end

local assisttank_width = 100
local assisttank_height  = 20
if C["unitframes"].maintank == true then
	local tank = oUF:SpawnHeader('TukuiMainTank', nil, 'raid',
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true,
		'groupFilter', 'MAINTANK',
		'yOffset', 7,
		'point' , 'BOTTOM',
		'template', 'oUF_TukuiMtt'
	)
	tank:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end
 
if C["unitframes"].mainassist == true then
	local assist = oUF:SpawnHeader("TukuiMainAssist", nil, 'raid',
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true,
		'groupFilter', 'MAINASSIST',
		'yOffset', 7,
		'point' , 'BOTTOM',
		'template', 'oUF_TukuiMtt'
	)
	if C["unitframes"].maintank == true then
		assist:SetPoint("TOPLEFT", TukuiMainTank, "BOTTOMLEFT", 2, -50)
	else
		assist:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
end


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

-- Testui Command
local testui = TestUI or function() end
TestUI = function(msg)
    if msg == "a" or msg == "arena" then
        TukuiArena1:Show(); TukuiArena1.Hide = function() end; TukuiArena1.unit = "player"
        TukuiArena2:Show(); TukuiArena2.Hide = function() end; TukuiArena2.unit = "player"
        TukuiArena3:Show(); TukuiArena3.Hide = function() end; TukuiArena3.unit = "player"
    elseif msg == "boss" or msg == "b" then
        TukuiBoss1:Show(); TukuiBoss1.Hide = function() end; TukuiBoss1.unit = "player"
        TukuiBoss2:Show(); TukuiBoss2.Hide = function() end; TukuiBoss2.unit = "player"
        TukuiBoss3:Show(); TukuiBoss3.Hide = function() end; TukuiBoss3.unit = "player"
    elseif msg == "buffs" then -- better dont test it ^^
        UnitAura = function()
            -- name, rank, texture, count, dtype, duration, timeLeft, caster
            return 139, 'Rank 1', 'Interface\\Icons\\Spell_Holy_Penance', 1, 'Magic', 0, 0, "player"
        end
        if(oUF) then
            for i, v in pairs(oUF.units) do
                if(v.UNIT_AURA) then
                    v:UNIT_AURA("UNIT_AURA", v.unit)
                end
            end
        end
    end
end
SlashCmdList.TestUI = TestUI
SLASH_TestUI1 = "/testui"