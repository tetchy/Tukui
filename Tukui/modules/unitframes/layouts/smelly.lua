local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if not(C["unitframes"].layout == "Smelly") then return end
if not C["unitframes"].enable == true then return end

print("Smelly layout enabled")

local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}
------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

local font = C["media"].uffont
local fontsize = C["media"].uffontsize
local fontflags = C["media"].uffontflags

local normTex = C["media"].normTex
local glowTex = C["media"].glowTex
local bubbleTex = C["media"].bubbleTex

local backdrop = {
	bgFile = C["media"].blank,
	insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult},
}

local ufSize = C["unitframes"]["sizes"]

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	-- set our own colors
	self.colors = T.oUF_colors
	
	-- register click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- menu? lol
	self.menu = T.SpawnMenu

	-- backdrop for every units
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)

	-- this is the glow border
	self:SetTemplate("ThickBorder")
	
	
	-- get frame sizes from config.lua
	local frameWidth, frameHeight
	if (unit and unit:find("arena%d") and C["arena"].unitframes == true) then
		frameWidth, frameHeight = ufSize["arena"].width, ufSize["arena"].height
	elseif (unit and unit:find("boss%d") and C["unitframes"].showboss == true) then
		frameWidth, frameHeight = ufSize["boss"].width, ufSize["boss"].height
	elseif (self:GetParent():GetName():match"TukuiMainTank" or self:GetParent():GetName():match"TukuiMainAssist") then
		frameWidth, frameHeight = ufSize["maintank"].width, ufSize["maintank"].height
	elseif unit=="player" or unit=="target" or unit=="targettarget" or unit=="focus"or unit=="focustarget" or unit=="pet" or unit=="pettarget" then
		frameWidth, frameHeight = ufSize[unit].width, ufSize[unit].height
	end
	
	--Cut off a few pixels for border
	frameWidth = frameWidth - 4
	frameHeight = frameHeight - 4
		
	------------------------------------------------------------------------
	--	Features we want for all units at the same time
	------------------------------------------------------------------------
	
	-- here we create an invisible frame for all element we want to show over health/power.
	local InvFrame = CreateFrame("Frame", nil, self)
	InvFrame:SetFrameStrata("HIGH")
	InvFrame:SetFrameLevel(5)
	InvFrame:SetAllPoints()
	
	-- symbols, now put the symbol on the frame we created above.
	local RaidIcon = InvFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
	RaidIcon:SetHeight(20)
	RaidIcon:SetWidth(20)
	RaidIcon:SetPoint("TOP", 0, 11)
	self.RaidIcon = RaidIcon
	
	------------------------------------------------------------------------
	--	Player and Target units layout (mostly mirror'd)
	------------------------------------------------------------------------
	
	if (unit == "player" or unit == "target") then	
		-- health bar
		local health = CreateFrame('StatusBar', self:GetName().."_Health", self)
		health:Height(frameHeight)
		health:Width(frameWidth)
		health:SetPoint("TOP", 0, -2)
		health:SetStatusBarTexture(normTex)
		
		-- create a panel for text
		local panel = CreateFrame("Frame", self:GetName().."_Panel", self)
		panel:SetFrameStrata("MEDIUM")
		panel:SetFrameLevel(12)
		panel:SetAllPoints(health)
		self.panel = panel
		
		-- health bar background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(normTex)
	
		health.value = T.SetFontString(panel, font, fontsize, fontflags)
		if unit == "target" then 
			health.value:Point("RIGHT", panel, "RIGHT", -4, 1)
		else
			health.value:Point("LEFT", panel, "LEFT", 4, 1)
		end
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG

		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C.unitframes.unicregcolor))
			healthBG:SetVertexColor(unpack(C.unitframes.unicbgcolor))
		else
			health.colorDisconnected = true
			health.colorTapping = true
			health.colorClass = true
			health.colorReaction = true
			healthBG.multiplier = 0.3
		end

		-- power
		powerBorder = CreateFrame("frame", self:GetName().."_PowerBorder", self)
		powerBorder:CreatePanel("Default", (frameWidth/2)-10, 10, "LEFT", self, "BOTTOM", 5, 0)
		powerBorder:SetFrameStrata("MEDIUM")
		powerBorder:SetFrameLevel(4)
		powerBorder:SetBackdropColor(0,0,0)
		if unit == "target" then
			powerBorder:ClearAllPoints()
			powerBorder:SetPoint("RIGHT", self, "BOTTOM", -5, 0)
		end
		
		local power = CreateFrame('StatusBar', self:GetName().."_Power", self)
		power:SetFrameLevel(powerBorder:GetFrameLevel()+1)
		power:Point("BOTTOMLEFT", powerBorder, "BOTTOMLEFT", 2, 2)
		power:Point("TOPRIGHT", powerBorder, "TOPRIGHT", -2, -2)
		power:SetStatusBarTexture(normTex)
		
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = T.SetFontString(panel, font, fontsize, fontflags)
		if unit == "target" then
			power.value:Point("LEFT", panel, "LEFT", 4, 1)
		else
			power.value:Point("RIGHT", panel, "RIGHT", -2, 1)
		end
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
			power.colorPower = true
			powerBG.multiplier = 0.3				
		else
			power.colorPower = true
		end

		-- portraits
		if (C["unitframes"].charportrait == true) then
			local portrait = CreateFrame("PlayerModel", self:GetName().."_Portrait", self)
			portrait:SetFrameLevel(3)
			portrait:SetAlpha(C.unitframes.portraitalpha)
			portrait:SetAllPoints(health)
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
		
		--[[ leaving here just in case someone want to use it, we now use our own Alt Power Bar.
		-- alt power bar
		local AltPowerBar = CreateFrame("StatusBar", self:GetName().."_AltPowerBar", self.Health)
		AltPowerBar:SetFrameLevel(0)
		AltPowerBar:SetFrameStrata("LOW")
		AltPowerBar:SetHeight(5)
		AltPowerBar:SetStatusBarTexture(C.media.normTex)
		AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
		AltPowerBar:SetStatusBarColor(163/255,  24/255,  24/255)
		AltPowerBar:EnableMouse(true)

		AltPowerBar:Point("LEFT", TukuiInfoLeft, 2, -2)
		AltPowerBar:Point("RIGHT", TukuiInfoLeft, -2, 2)
		AltPowerBar:Point("TOP", TukuiInfoLeft, 2, -2)
		AltPowerBar:Point("BOTTOM", TukuiInfoLeft, -2, 2)
		
		AltPowerBar:SetBackdrop({
			bgFile = C["media"].blank, 
			edgeFile = C["media"].blank, 
			tile = false, tileSize = 0, edgeSize = 1, 
			insets = { left = 0, right = 0, top = 0, bottom = T.Scale(-1)}
		})
		AltPowerBar:SetBackdropColor(0, 0, 0)

		self.AltPowerBar = AltPowerBar
		]]--
			
		if (unit == "player") then
			-- combat icon
			local Combat = health:CreateTexture(nil, "OVERLAY")
			Combat:Height(19)
			Combat:Width(19)
			Combat:SetPoint("LEFT",0,1)
			Combat:SetVertexColor(0.69, 0.31, 0.31)
			self.Combat = Combat

			-- custom info (low mana warning)
			FlashInfo = CreateFrame("Frame", "TukuiFlashInfo", self)
			FlashInfo:SetScript("OnUpdate", T.UpdateManaLevel)
			FlashInfo.parent = self
			FlashInfo:SetAllPoints(panel)
			FlashInfo.ManaLevel = T.SetFontString(FlashInfo, font, fontsize, fontflags)
			FlashInfo.ManaLevel:SetPoint("CENTER", panel, "CENTER", 0, 0)
			self.FlashInfo = FlashInfo
			
			-- pvp status text
			local status = T.SetFontString(panel, font, fontsize, fontflags)
			status:SetPoint("CENTER", panel, "CENTER", 0, 0)
			status:SetTextColor(0.69, 0.31, 0.31)
			status:Hide()
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
			
			-- show druid mana when shapeshifted in bear, cat or whatever
			if T.myclass == "DRUID" then
				CreateFrame("Frame"):SetScript("OnUpdate", function() T.UpdateDruidMana(self) end)
				local DruidMana = T.SetFontString(health, font, fontsize, fontflags)
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana
			end
			
			if C["unitframes"].classbar then
				if T.myclass == "DRUID" then			
					local eclipseBar = CreateFrame('Frame', nil, self)
					eclipseBar:Point("RIGHT", self, "BOTTOM", -5, 0)
					eclipseBar:Size((frameWidth/2)-10, powerBorder:GetHeight())
					eclipseBar:SetFrameStrata("MEDIUM")
					eclipseBar:SetFrameLevel(powerBorder:GetFrameLevel())
					eclipseBar:SetTemplate("Default")
					eclipseBar:SetBackdropColor(0,0,0)
					eclipseBar:SetScript("OnShow", function() T.EclipseDisplay(self, false) end)
					eclipseBar:SetScript("OnUpdate", function() T.EclipseDisplay(self, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
					eclipseBar:SetScript("OnHide", function() T.EclipseDisplay(self, false) end)
					
					local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
					lunarBar:Point('LEFT', eclipseBar, 'LEFT', 2, 0)
					lunarBar:Size(eclipseBar:GetWidth()-4, eclipseBar:GetHeight()-4)
					lunarBar:SetStatusBarTexture(normTex)
					lunarBar:SetStatusBarColor(.30, .52, .90)
					eclipseBar.LunarBar = lunarBar

					local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
					solarBar:Point('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
					solarBar:Size(eclipseBar:GetWidth()-4, eclipseBar:GetHeight()-4)
					solarBar:SetStatusBarTexture(normTex)
					solarBar:SetStatusBarColor(.80, .82,  .60)
					eclipseBar.SolarBar = solarBar

					local eclipseBarText = eclipseBar:CreateFontString(nil, 'OVERLAY')
					eclipseBarText:SetPoint('TOP', panel)
					eclipseBarText:SetPoint('BOTTOM', panel)
					eclipseBarText:SetFont(font, fontsize, fontflags)
					eclipseBar.PostUpdatePower = T.EclipseDirection
					
					-- hide "low mana" text on load if eclipseBar is show
					if eclipseBar and eclipseBar:IsShown() then FlashInfo.ManaLevel:SetAlpha(0) end

					self.EclipseBar = eclipseBar
					self.EclipseBar.Text = eclipseBarText
				end

				-- set holy power bar or shard bar
				if (T.myclass == "WARLOCK" or T.myclass == "PALADIN") then
					local bars = CreateFrame("Frame", nil, self)
					bars:SetFrameStrata("MEDIUM")
					bars:SetFrameLevel(powerBorder:GetFrameLevel())
					bars:Point("RIGHT", self, "BOTTOM", -5, 0)
					bars:Size((frameWidth/2)-10, powerBorder:GetHeight())
					bars:SetTemplate("ThickBorder")
					bars:SetBackdropColor(0,0,0)
					
					for i = 1, 3 do					
						bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, self)
						bars[i]:Height(bars:GetHeight()-4)
						bars[i]:Width((bars:GetWidth()-5)/3)
						bars[i]:SetFrameLevel(bars:GetFrameLevel()+1)
						
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
							bars[i]:SetPoint("LEFT", bars, "LEFT", 2, 0)
							--bars[i]:Width(bars[i]:GetWidth()-1)
							bars[i].bg:SetAllPoints(bars[i])
						else
							bars[i]:Point("LEFT", bars[i-1], "RIGHT", 1, 0)
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
					
					local Runes = CreateFrame("Frame", nil, self)
					Runes:SetFrameStrata("MEDIUM")
					Runes:SetFrameLevel(powerBorder:GetFrameLevel())
					Runes:Point("RIGHT", self, "BOTTOM", -5, 0)
					Runes:Size((frameWidth/2)-10, powerBorder:GetHeight())
					Runes:SetTemplate("Default")
					Runes:SetBackdropColor(0, 0, 0)

					for i = 1, 6 do
						Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, health)
						Runes[i]:Height(Runes:GetHeight()-4)
						Runes[i]:Width((Runes:GetWidth()-7)/6)
						Runes[i]:SetFrameLevel(Runes:GetFrameLevel()+1)
						if (i == 1) then
							Runes[i]:Point("LEFT", Runes, "LEFT", 2, 0)
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
					
					local TotemFrame = CreateFrame("Frame", self:GetName().."_TotemFrame", self)
					TotemFrame:SetPoint("RIGHT", self, "BOTTOM", -5, 0)
					TotemFrame:Width(frameWidth/2-10)
					TotemFrame:Height(powerBorder:GetHeight())
					TotemFrame:SetTemplate("Default")
					TotemFrame:SetFrameLevel(4)
					TotemFrame:SetBackdropColor(0,0,0)
					
					local TotemBar = {}
					TotemBar.Destroy = true
					for i = 1, 4 do
						TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
						if (i == 1) then
							TotemBar[i]:SetPoint("LEFT", TotemFrame, "LEFT", 2, 0)					
						else
							TotemBar[i]:SetPoint("TOPLEFT", TotemBar[i-1], "TOPRIGHT", TukuiDB.Scale(1), 0)
						end
						TotemBar[i]:SetStatusBarTexture(normTex)
						TotemBar[i]:Height(TotemFrame:GetHeight()-4)
						TotemBar[i]:Width((TotemFrame:GetWidth()-5) / 4)
						if i%2 == 1 then TotemBar[i]:Width(TotemBar[i]:GetWidth()-1) end
						
						TotemBar[i]:SetFrameLevel(TotemFrame:GetFrameLevel()+1)
						TotemBar[i]:SetMinMaxValues(0, 1)

						TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
						TotemBar[i].bg:SetAllPoints(TotemBar[i])
						TotemBar[i].bg:SetTexture(normTex)
						TotemBar[i].bg.multiplier = 0.3
					end
					self.TotemBar = TotemBar
				end
			end
			
			-- script for pvp status and low mana
			self:SetScript("OnEnter", function(self)
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Hide()
				end
				FlashInfo.ManaLevel:Hide() 
				status:Show()
				UnitFrame_OnEnter(self) 
			end)
			self:SetScript("OnLeave", function(self) 
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Show()
				end
				FlashInfo.ManaLevel:Show()
				status:Hide() 
				UnitFrame_OnLeave(self) 
			end)
		end
		
		if (unit == "target") then			
			-- Unit name on target
			local Name = panel:CreateFontString(nil, "OVERLAY")
			Name:Point("LEFT", panel, "LEFT", 4, 1)
			Name:SetJustifyH("LEFT")
			Name:SetFont(font, fontsize, fontflags)

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

		if (unit == "target" and C["unitframes"].targetauras) or (unit == "player" and C["unitframes"].playerauras) then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)
			
			if (T.myclass == "SHAMAN" or T.myclass == "DEATHKNIGHT" or T.myclass == "PALADIN" or T.myclass == "WARLOCK") and (C["unitframes"].playerauras) and (unit == "player") then
				buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 38)
			else
				buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 30)
			end

			buffs.size = 23
			buffs.num = 10
			buffs.rows = 1
			buffs.spacing = 3
			buffs:Height((buffs.size+buffs.spacing)*buffs.rows)
			buffs:Width(((buffs.size*buffs.num) + (buffs.spacing*(buffs.num-1)))/buffs.rows)

			
			debuffs.size = 23
			debuffs.num = 10
			debuffs.rows = 1
			debuffs.spacing = 3
			debuffs:Height((debuffs.size+debuffs.spacing)*debuffs.rows)
			debuffs:Width(((debuffs.size*(debuffs.num/debuffs.rows)) + (debuffs.spacing*((debuffs.num/debuffs.rows)-1))))
			debuffs:SetPoint("BOTTOMRIGHT", buffs, "TOPRIGHT", 0, 0)
			
			buffs.initialAnchor = 'TOPLEFT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs	

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
			if C.unitframes.cbposition == true then
				if unit == "player" then
					castbar:Point("BOTTOM", TukuiBar1, "TOP",  0, 5)
					castbar:SetWidth(TukuiBar1:GetWidth()-4)
					castbar:SetHeight(20)
				else
					castbar:Point("BOTTOM", TukuiBar1, "TOP",  0, 32)
					castbar:SetWidth(TukuiBar1:GetWidth()-4)
					castbar:SetHeight(20)
				end
			else
				castbar:Point("TOP", self, "BOTTOM",  0, -11)
				castbar:SetWidth(frameWidth)
				castbar:SetHeight(12)
			end
			
			castbar.border = CreateFrame("frame", nil, castbar)
			castbar.border:SetPoint("TOPLEFT", castbar, "TOPLEFT", -2, 2)
			castbar.border:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", 2, -2)
			castbar.border:SetTemplate("ThickBorder")
			castbar.border:SetFrameStrata("BACKGROUND")
			castbar.border:SetFrameLevel(0)
			
			castbar.CustomTimeText = T.CustomCastTimeText
			castbar.CustomDelayText = T.CustomCastDelayText
			castbar.PostCastStart = T.CheckCast
			castbar.PostChannelStart = T.CheckChannel

			castbar.time = T.SetFontString(castbar, font, fontsize, fontflags)
			castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")

			castbar.Text = T.SetFontString(castbar, font, fontsize, fontflags)
			castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			if C["unitframes"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:Size(26)
				castbar.button:SetTemplate("ThickBorder")

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
			CombatFeedbackText = T.SetFontString(panel, font, fontsize, fontflags)
			CombatFeedbackText:SetPoint("CENTER", health, "CENTER", 0, 1)
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
		
		if C["unitframes"].healcomm then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetWidth(frameWidth)
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
		local health = CreateFrame('StatusBar', self:GetName().."_Health", self)
		health:Height(frameHeight)
		health:Width(frameWidth)
		health:SetPoint("TOP", 0, -2)
		health:SetStatusBarTexture(normTex)
		
		-- create a panel for text
		local panel = CreateFrame("Frame", self:GetName().."_Panel", self)
		panel:SetFrameStrata("MEDIUM")
		panel:SetFrameLevel(12)
		panel:SetAllPoints(health)
		self.panel = panel
		
		-- health bar background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(normTex)
				
		self.Health = health
		self.Health.bg = healthBG

		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C.unitframes.unicregcolor))
			healthBG:SetVertexColor(unpack(C.unitframes.unicbgcolor))		
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
		end
		
		-- Unit name
		local Name = panel:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", panel, "CENTER", 0, 1)
		Name:SetFont(font, fontsize, fontflags)
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort]')
		self.Name = Name
		
		-- portraits
		if (C["unitframes"].charportrait == true) then
			local portrait = CreateFrame("PlayerModel", self:GetName().."_Portrait", self)
			portrait:SetFrameLevel(3)
			portrait:SetAlpha(C.unitframes.portraitalpha)
			portrait:SetAllPoints(health)
			table.insert(self.__elements, T.HidePortrait)
			self.Portrait = portrait
		end
	end
	
	------------------------------------------------------------------------
	--	Pet unit layout
	------------------------------------------------------------------------
	
	if (unit == "pet") or (unit == "pettarget") then
		-- create panel if higher version
		local panel = CreateFrame("Frame", nil, self)
		panel:SetFrameLevel(2)
		panel:SetFrameStrata("MEDIUM")
		panel:SetBackdropBorderColor(unpack(C["media"].bordercolor))
		self.panel = panel
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(frameHeight-5)
		health:SetWidth(frameWidth)
		health:SetPoint("TOP", 0, -2)
		health:SetStatusBarTexture(normTex)
		
		panel:SetAllPoints(health)
		
		health.PostUpdate = T.PostUpdatePetColor
				
		self.Health = health
		self.Health.bg = healthBG
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(normTex)
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C.unitframes.unicregcolor))
			healthBG:SetVertexColor(unpack(C.unitframes.unicbgcolor))	
		else
			health.colorDisconnected = true	
			health.colorClass = true
			health.colorReaction = true	
			if T.myclass == "HUNTER" then
				health.colorHappiness = true
			end
		end
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(4)
		power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -1)
		power:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -1)
		power:SetStatusBarTexture(normTex)
		
		power.frequentUpdates = true
		power.colorPower = true
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
				
		self.Power = power
		self.Power.bg = powerBG
				
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", panel, "CENTER", 0, 1)
		Name:SetFont(font, fontsize, fontflags)
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort] [Tukui:diffcolor][level]')
		self.Name = Name
		
		if (C["unitframes"].unitcastbar == true) and (unit=="pet") then
			local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			castbar:SetStatusBarTexture(normTex)
			self.Castbar = castbar
			
			castbar.border = CreateFrame("frame", nil, castbar)
			castbar.border:SetPoint("BOTTOM", self, "TOP", 0, 3)
			castbar.border:Width(frameWidth+4)
			castbar.border:Height(13)
			castbar.border:SetTemplate("ThickBorder")
			castbar.border:SetFrameStrata("BACKGROUND")
			castbar.border:SetFrameLevel(0)
			
			castbar.bg = castbar:CreateTexture(nil, "BORDER")
			castbar.bg:SetAllPoints(castbar)
			castbar.bg:SetTexture(normTex)
			castbar.bg:SetVertexColor(0.15, 0.15, 0.15)
			castbar:SetFrameLevel(6)
			castbar:Point("TOPLEFT", castbar.border, 2, -2)
			castbar:Point("BOTTOMRIGHT", castbar.border, -2, 2)
			
				
			castbar.CustomTimeText = T.CustomCastTimeText
			castbar.CustomDelayText = T.CustomCastDelayText
			castbar.PostCastStart = T.CheckCast
			castbar.PostChannelStart = T.CheckChannel

			castbar.time = T.SetFontString(castbar, font, fontsize, fontflags)
			castbar.time:Point("RIGHT", castbar, "RIGHT", -1, 1)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")

			castbar.Text = T.SetFontString(castbar, font, fontsize, fontflags)
			castbar.Text:Point("LEFT", castbar, "LEFT", 1, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
				
			self.Castbar.Time = castbar.time
		end
		
		-- update pet name, this should fix "UNKNOWN" pet names on pet unit, health and bar color sometime being "grayish".
		self:RegisterEvent("UNIT_PET", T.updateAllElements)
	end


	------------------------------------------------------------------------
	--	Focus unit layout
	------------------------------------------------------------------------
	
	if (unit == "focus") then
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(frameHeight-4)
		health:Width(frameWidth)
		health:SetPoint("TOP", 0,-2)
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		health.colorDisconnected = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(normTex)

		health.value = T.SetFontString(health, font, fontsize, fontflags)
		health.value:Point("LEFT", 2, 0)
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C.unitframes.unicregcolor))
			healthBG:SetVertexColor(unpack(C.unitframes.unicbgcolor))	
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
	
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(3)
		power:Width(frameWidth)
		power:Point("TOP", health, "BOTTOM", 0, -1)
		power:SetStatusBarTexture(normTex)
		
		power.frequentUpdates = true
		power.colorPower = true
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = T.SetFontString(health, font, fontsize, fontflags)
		power.value:Point("RIGHT", -2, 0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font, fontsize, fontflags, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(0,0)
		
		self:Tag(Name, '[Tukui:diffcolor][Tukui:namelong]')
		self.Name = Name

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
		castbar:SetPoint("LEFT", 2, 0)
		castbar:SetPoint("RIGHT", -24, 0)
		castbar:SetPoint("BOTTOM", 0, -22)
		
		castbar:SetHeight(16)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("ThickBorder")
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].bordercolor))
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, font, fontsize, fontflags)
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, font, fontsize, fontflags)
		castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel
								
		castbar.button = CreateFrame("Frame", nil, castbar)
		castbar.button:Height(castbar:GetHeight()+4)
		castbar.button:Width(castbar:GetHeight()+4)
		castbar.button:Point("LEFT", castbar, "RIGHT", 4, 0)
		castbar.button:SetTemplate("ThickBorder")
		castbar.button:SetBackdropBorderColor(unpack(C["media"].bordercolor))
		castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
		castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
		castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
		castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
		self.Castbar.Icon = castbar.icon
	end
	
	------------------------------------------------------------------------
	--	Focus target unit layout
	------------------------------------------------------------------------

	if (unit == "focustarget") then
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(frameHeight-4)
		health:Width(frameWidth)
		health:SetPoint("TOP", 0,-2)
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		health.colorDisconnected = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(normTex)

		health.value = T.SetFontString(health, font, fontsize, fontflags)
		health.value:Point("LEFT", 2, 0)
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C.unitframes.unicregcolor))
			healthBG:SetVertexColor(unpack(C.unitframes.unicbgcolor))	
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
	
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(3)
		power:Width(frameWidth)
		power:Point("TOP", health, "BOTTOM", 0, -1)
		power:SetStatusBarTexture(normTex)
		
		power.frequentUpdates = true
		power.colorPower = true
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = T.SetFontString(health, font, fontsize, fontflags, "OUTLINE")
		power.value:Point("RIGHT", -2, 0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font, fontsize, fontflags, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(0,0)
		
		self:Tag(Name, '[Tukui:diffcolor][Tukui:namelong]')
		self.Name = Name

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
		castbar:SetPoint("LEFT", 2, 0)
		castbar:SetPoint("RIGHT", -24, 0)
		castbar:SetPoint("TOP", 0, 22)
		
		castbar:SetHeight(16)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("ThickBorder")
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].bordercolor))
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, font, fontsize, fontflags)
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, font, fontsize, fontflags)
		castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel
								
		castbar.button = CreateFrame("Frame", nil, castbar)
		castbar.button:Height(castbar:GetHeight()+4)
		castbar.button:Width(castbar:GetHeight()+4)
		castbar.button:Point("LEFT", castbar, "RIGHT", 4, 0)
		castbar.button:SetTemplate("ThickBorder")
		castbar.button:SetBackdropBorderColor(unpack(C["media"].bordercolor))
		castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
		castbar.icon:Point("TOPLEFT", castbar.button, 2, -2)
		castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
		castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
		self.Castbar.Icon = castbar.icon
	end

	------------------------------------------------------------------------
	--	Arena or boss units layout (both mirror'd)
	------------------------------------------------------------------------
	
	if (unit and unit:find("arena%d") and C["arena"].unitframes == true) or (unit and unit:find("boss%d") and C["unitframes"].showboss == true) then
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(frameHeight-4)
		health:Width(frameWidth)
		health:SetPoint("TOP", 0, -2)
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		health.colorDisconnected = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(normTex)

		health.value = T.SetFontString(health, font, fontsize, fontflags)
		health.value:Point("LEFT", 2, 0)
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C.unitframes.unicregcolor))
			healthBG:SetVertexColor(unpack(C.unitframes.unicbgcolor))	
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
	
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(3)
		power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -1)
		power:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -1)
		power:SetStatusBarTexture(normTex)
		
		power.frequentUpdates = true
		power.colorPower = true
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = T.SetFontString(health, font, fontsize, fontflags)
		power.value:Point("RIGHT", -2, 0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font, fontsize, fontflags, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(0,0)
		Name.frequentUpdates = 0.2
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong]')
		self.Name = Name
		
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
			buffs:Point("RIGHT", self, "LEFT", -4, 0)
			buffs.size = 26
			buffs.num = 3
			buffs.spacing = 2
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
			Trinketbg:SetTemplate("ThickBorder")
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
		castbar:SetPoint("LEFT", 24, 0)
		castbar:SetPoint("RIGHT", -2, 0)
		castbar:SetPoint("BOTTOM", 0, -22)
		
		castbar:SetHeight(16)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("ThickBorder")
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].bordercolor))
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, font, fontsize, fontflags)
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, font, fontsize, fontflags)
		castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel
								
		castbar.button = CreateFrame("Frame", nil, castbar)
		castbar.button:Height(castbar:GetHeight()+4)
		castbar.button:Width(castbar:GetHeight()+4)
		castbar.button:Point("RIGHT", castbar, "LEFT",-4, 0)
		castbar.button:SetTemplate("Default")
		castbar.button:SetBackdropBorderColor(unpack(C["media"].bordercolor))
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
	
	if (self:GetParent():GetName():match"TukuiMainTank" or self:GetParent():GetName():match"TukuiMainAssist") then
		-- Right-click focus on maintank or mainassist units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(20)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(normTex)
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C.unitframes.unicregcolor))
			healthBG:SetVertexColor(unpack(C.unitframes.unicbgcolor))	
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font, fontsize, fontflags, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(0,0)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort]')
		self.Name = Name
	end
	
	return self
end

------------------------------------------------------------------------
--	Default position of Tukui unitframes
------------------------------------------------------------------------

-- for lower reso
local adjustPet = 0
if T.myclass == "SHAMAN" or T.myclass == "PALADIN" or T.myclass == "WARLOCK" or T.myclass == "DEATHKNIGHT" or T.myclass == "DRUID" then adjustPet = 9 end

oUF:RegisterStyle('Tukui', Shared)

-- player
local player = oUF:Spawn('player', "TukuiPlayer")
player:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "BOTTOM", -134,250)
player:Size(ufSize.player.width, ufSize.player.height)

-- target
local target = oUF:Spawn('target', "TukuiTarget")
target:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "BOTTOM", 134,250)
target:Size(ufSize.target.width, ufSize.target.height)

-- focus
if C.unitframes.showfocustarget then
	local focus = oUF:Spawn('focus', "TukuiFocus")
	focus:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "BOTTOM", -134,400)
	focus:Size(ufSize.focus.width, ufSize.focus.height)
end

--focustarget
local focustarget = oUF:Spawn("focustarget", "TukuiFocusTarget")
focustarget:SetPoint("BOTTOM", focus, "TOP", 0, 5)
focustarget:Size(ufSize.focustarget.width, ufSize.focustarget.height)

-- tot
local tot = oUF:Spawn('targettarget', "TukuiTargetTarget")
tot:SetPoint("LEFT", target, "RIGHT", 5, 0)
tot:Size(ufSize.targettarget.width, ufSize.targettarget.height)

-- pet
local pet = oUF:Spawn('pet', "TukuiPet")
pet:SetPoint("BOTTOMLEFT", player, "TOPLEFT", 0,5+adjustPet)
pet:Size(ufSize.pet.width, ufSize.pet.height)

-- pettarget
local pettarget = oUF:Spawn('pettarget', "TukuiPetTarget")
pettarget:SetPoint("BOTTOMRIGHT", player, "TOPRIGHT", 0,5+adjustPet)
pettarget:Size(ufSize.pettarget.width, ufSize.pettarget.height)


if C.arena.unitframes then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "TukuiArena"..i)
		if i == 1 then
			arena[i]:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", 0, 246)
		else
			arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 35)
		end
		arena[i]:Size(ufSize.arena.width, ufSize.arena.height)
	end
end

--Hide boss frames even if showboss is set to false.
for i = 1,MAX_BOSS_FRAMES do
	local t_boss = _G["Boss"..i.."TargetFrame"]
	t_boss:UnregisterAllEvents()
	t_boss.Show = T.dummy
	t_boss:Hide()
	_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
	_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
end

if C["unitframes"].showboss then
	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = oUF:Spawn("boss"..i, "TukuiBoss"..i)
		if i == 1 then
			boss[i]:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "BOTTOM", 134,400)
		else
			boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 35)             
		end
		boss[i]:Size(ufSize.boss.width, ufSize.boss.height)
	end
end

local assisttank_width = ufSize.maintank.width
local assisttank_height = ufSize.maintank.height
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