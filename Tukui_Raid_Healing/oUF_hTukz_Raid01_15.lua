local ADDON_NAME, ns = ...
local oUF = oUFTukui or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["unitframes"].enable == true or C["unitframes"].gridonly == true then return end

local font2 = C["media"].uffontp
local font1 = C["media"].font
local normTex = C["media"].normTex

local function Shared(self, unit)
	self.colors = T.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = T.SpawnMenu
	
	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -2, left = -2, bottom = -2, right = -2}})
	self:SetBackdropColor(0.1, 0.1, 0.1)
	
	local health = CreateFrame('StatusBar', nil, self)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:Height(36)
	health:SetStatusBarTexture(normTex)
	self.Health = health
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(normTex)
	health.bg:SetTexture(0.3, 0.3, 0.3)
	health.bg.multiplier = 0.3
	self.Health.bg = health.bg
	
	-- health border
	local healthborder = CreateFrame("Frame", nil, self)
	healthborder:CreatePanel("Default", 1, 1, "CENTER", health, "CENTER", 0, 0)
	healthborder:ClearAllPoints()
	healthborder:Point("TOPLEFT", health, -2, 2)
	healthborder:Point("BOTTOMRIGHT", health, 2, -2)
	healthborder:SetFrameLevel(2)
	healthborder:SetFrameStrata("MEDIUM")
		
	health.value = health:CreateFontString(nil, "OVERLAY")
	health.value:Point("CENTER", self, "CENTER", 0, -10)
	health.value:SetFont(font2, 10*T.raidscale, "THINOUTLINE")
	health.value:SetTextColor(1,1,1)
	self.Health.value = health.value
	
	health.PostUpdate = T.PostUpdateHealthRaid
	
	health.frequentUpdates = true
	
	if C.unitframes.unicolor == true then
		health.colorDisconnected = false
		health.colorClass = false
		health:SetStatusBarColor(.3, .3, .3, 1)
		health.bg:SetVertexColor(.1, .1, .1, 1)		
	else
		health.colorDisconnected = true
		health.colorClass = true
		health.colorReaction = true			
	end
	
	if C["unitframes"].showpower == true then
		local power = CreateFrame("StatusBar", nil, self)
		power:Size(45, 5)
		power:Point("CENTER", health, "BOTTOM", 0, -2)
		power:SetFrameLevel(4)
		--power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -1)
		--power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -1)
		power:SetStatusBarTexture(C["media"].normTex)
		self.Power = power
		
		power.frequentUpdates = true
		power.colorDisconnected = true

		power.bg = self.Power:CreateTexture(nil, "BORDER")
		power.bg:SetAllPoints(power)
		power.bg:SetTexture(C["media"].normTex)
		power.bg:SetAlpha(1)
		power.bg.multiplier = 0.4
		
		--power border
		local powerborder = CreateFrame("Frame", nil, self)
		powerborder:CreatePanel("Default", 1, 1, "CENTER", power, "CENTER", 0, 0)
		powerborder:ClearAllPoints()
		powerborder:Point("TOPLEFT", power, -2, 2)
		powerborder:Point("BOTTOMRIGHT", power, 2, -2)
		powerborder:SetFrameLevel(4)
		powerborder:SetFrameStrata("MEDIUM")
		
		self.Power.bg = power.bg
		if C.unitframes.unicolor == true then
			power.colorClass = false
			power.colorPower = true
			power.bg.multiplier = 0.1				
		else
			power.colorPower = true
		end
	end
	
	local name = health:CreateFontString(nil, "OVERLAY")
    name:SetPoint("CENTER", health, 0, 2)
	name:SetFont(font2, 10, "THINOUTLINE")
	name:SetWidth(((TukuiChatBackgroundLeft:GetWidth() / 5) - 7))
	self:Tag(name, '[Tukui:dead][Tukui:afk][Tukui:getnamecolor][Tukui:nameshort]')
	self.Name = name
	
    local leader = health:CreateTexture(nil, "OVERLAY")
    leader:Height(12)
    leader:Width(12)
    leader:SetPoint("TOPLEFT", 0, 6)
	self.Leader = leader
	
     local LFDRole = health:CreateTexture(nil, "OVERLAY")
     LFDRole:Height(6)
     LFDRole:Width(6)
	 LFDRole:Point("BOTTOMRIGHT", 0, 0)
	 LFDRole:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\lfdicons.blp")
	 self.LFDRole = LFDRole
	
    local MasterLooter = health:CreateTexture(nil, "OVERLAY")
    MasterLooter:Height(12)
    MasterLooter:Width(12)
	self.MasterLooter = MasterLooter
    self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)
	
	if C["unitframes"].aggro == true then
		table.insert(self.__elements, T.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
    end
	
	if C["unitframes"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:Height(14)
		RaidIcon:Width(14)
		RaidIcon:SetPoint('CENTER', self, 'TOP', 0, 0)
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(20*T.raidscale)
	ReadyCheck:Width(20*T.raidscale)
	ReadyCheck:SetPoint('CENTER')
	self.ReadyCheck = ReadyCheck
	
    --Debuff Highlight
		local dbh = self.Health:CreateTexture(nil, "OVERLAY", Healthbg)
		dbh:SetAllPoints(self)
		dbh:SetTexture(TukuiCF["media"].normTex)
		dbh:SetBlendMode("ADD")
		dbh:SetVertexColor(0,0,0,0)
		self.DebuffHighlight = dbh
		self.DebuffHighlightFilter = true
		self.DebuffHighlightAlpha = 0.6
	-- end	
	
	--local picon = self.Health:CreateTexture(nil, 'OVERLAY')
	--picon:SetPoint('CENTER', self.Health)
	--picon:SetSize(16, 16)
	--picon:SetTexture[[Interface\AddOns\Tukui\medias\textures\picon]]
	--picon.Override = T.Phasing
	--self.PhaseIcon = picon
	
	if C["unitframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["unitframes"].raidalphaoor}
		self.Range = range
	end
	
	if C["unitframes"].showsmooth == true then
		health.Smooth = true
	end
	
	if C["unitframes"].healcomm then
		local mhpb = CreateFrame('StatusBar', nil, self.Health)
		mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
		mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		mhpb:SetWidth(76*T.raidscale)
		mhpb:SetStatusBarTexture(normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, self.Health)
		ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
		ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		ohpb:SetWidth(76*T.raidscale)
		ohpb:SetStatusBarTexture(normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
	end
	
	if C["unitframes"].raidunitdebuffwatch == true then
		-- AuraWatch (corner icon)
		T.createAuraWatch(self,unit)
		
		-- Raid Debuffs (big middle icon)
		local RaidDebuffs = CreateFrame('Frame', nil, self)
		RaidDebuffs:Height(24*C["unitframes"].gridscale)
		RaidDebuffs:Width(24*C["unitframes"].gridscale)
		RaidDebuffs:Point('CENTER', health, 1,0)
		RaidDebuffs:SetFrameStrata(health:GetFrameStrata())
		RaidDebuffs:SetFrameLevel(health:GetFrameLevel() + 2)
		
		RaidDebuffs:SetTemplate("Default")
		
		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, 'OVERLAY')
		RaidDebuffs.icon:SetTexCoord(.1,.9,.1,.9)
		RaidDebuffs.icon:Point("TOPLEFT", 2, -2)
		RaidDebuffs.icon:Point("BOTTOMRIGHT", -2, 2)
		
		-- just in case someone want to add this feature, uncomment to enable it
		--[[
		if C["unitframes"].auratimer then
			RaidDebuffs.cd = CreateFrame('Cooldown', nil, RaidDebuffs)
			RaidDebuffs.cd:SetPoint("TOPLEFT", T.Scale(2), T.Scale(-2))
			RaidDebuffs.cd:SetPoint("BOTTOMRIGHT", T.Scale(-2), T.Scale(2))
			RaidDebuffs.cd.noOCC = true -- remove this line if you want cooldown number on it
		end
		--]]
		
		RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, 'OVERLAY')
		RaidDebuffs.count:SetFont(C["media"].uffont, 9*C["unitframes"].gridscale, "THINOUTLINE")
		RaidDebuffs.count:SetPoint('BOTTOMRIGHT', RaidDebuffs, 'BOTTOMRIGHT', 0, 2)
		RaidDebuffs.count:SetTextColor(1, .9, 0)
		
		RaidDebuffs:FontString('time', C["media"].uffont, 9*C["unitframes"].gridscale, "THINOUTLINE")
		RaidDebuffs.time:SetPoint('CENTER')
		RaidDebuffs.time:SetTextColor(1, .9, 0)
		
		self.RaidDebuffs = RaidDebuffs
    end

	return self
end

oUF:RegisterStyle('TukuiHealR01R15', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiHealR01R15")

	local raid = self:SpawnHeader("oUF_TukuiHealRaid0115", nil, "custom [@raid16,exists] hide;show", 
	'oUF-initialConfigFunction', [[
		local header = self:GetParent()
		self:SetWidth(header:GetAttribute('initial-width'))
		self:SetHeight(header:GetAttribute('initial-height'))
	]],
	'initial-width', ((TukuiChatBackgroundLeft:GetWidth() / 5) - 7),
	'initial-height', T.Scale(36*T.raidscale),	
	"showParty", true, 
	"showPlayer", C["unitframes"].showplayerinparty, 
	"showRaid", true, 
	"groupFilter", "1,2,3,4,5,6,7,8", 
	"groupingOrder", "1,2,3,4,5,6,7,8", 
	"groupBy", "GROUP", 
	"xoffset", T.Scale(7),
	"yOffset", T.Scale(-7),
	"maxColumns", 5,
	"unitsPerColumn", 5,
	"columnSpacing", T.Scale(10),
	"columnAnchorPoint", "BOTTOM",
	"Point", "LEFT"
	)
	raid:SetPoint('BOTTOMLEFT', TukuiChatBackgroundLeft, "TOPLEFT", 2, 10*T.raidscale)
	
	local pets = {} 
		pets[1] = oUF:Spawn('partypet1', 'oUF_TukuiPartyPet1') 
		pets[1]:SetPoint('BOTTOMLEFT', raid, 'TOPLEFT', 0, 30*T.raidscale)
		pets[1]:Size(76, 20*T.raidscale)
	for i =2, 4 do 
		pets[i] = oUF:Spawn('partypet'..i, 'oUF_TukuiPartyPet'..i) 
		pets[i]:SetPoint('LEFT', pets[i-1], 'RIGHT', 7, 0)
		pets[i]:Size(76, 20*T.raidscale)
	end
		
	local RaidMove = CreateFrame("Frame")
	RaidMove:RegisterEvent("PLAYER_ENTERING_WORLD")
	RaidMove:RegisterEvent("RAID_ROSTER_UPDATE")
	RaidMove:RegisterEvent("PARTY_LEADER_CHANGED")
	RaidMove:RegisterEvent("PARTY_MEMBERS_CHANGED")
	RaidMove:SetScript("OnEvent", function(self)
		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			local numraid = GetNumRaidMembers()
			local numparty = GetNumPartyMembers()
			if numparty > 0 and numraid == 0 or numraid > 0 and numraid <= 5 then
				raid:SetPoint('BOTTOMLEFT', TukuiChatBackgroundLeft, "TOPLEFT", 2, 10*T.raidscale)
				for i,v in ipairs(pets) do v:Enable() end
			elseif numraid > 5 and numraid <= 10 then
				raid:SetPoint('BOTTOMLEFT', TukuiChatBackgroundLeft, "TOPLEFT", 2, 10*T.raidscale)
				for i,v in ipairs(pets) do v:Disable() end
			elseif numraid > 10 and numraid <= 15 then
				raid:SetPoint('BOTTOMLEFT', TukuiChatBackgroundLeft, "TOPLEFT", 2, 10*T.raidscale)
				for i,v in ipairs(pets) do v:Disable() end
			elseif numraid > 15 then
				for i,v in ipairs(pets) do v:Disable() end
			end
		end
	end)
end)