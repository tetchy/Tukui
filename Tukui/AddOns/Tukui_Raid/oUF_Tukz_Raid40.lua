local ADDON_NAME, ns = ...
local oUF = oUFTukui or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["unitframes"].enable == true then return end

local font2 = C["media"].uffontp
local font1 = C["media"].font

local function Shared(self, unit)
	self.colors = T.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = T.SpawnMenu
	
	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -2, left = -2, bottom = -2, right = -2}})
	self:SetBackdropColor(0.1, 0.1, 0.1)
	
	local health = CreateFrame('StatusBar', nil, self)
	health:Height(21)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(C["media"].normTex)
	self.Health = health

	health.bg = self.Health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(self.Health)
	health.bg:SetTexture(C["media"].blank)
	health.bg:SetTexture(0.3, 0.3, 0.3)
	
	-- health border
	local healthborder = CreateFrame("Frame", nil, self)
	healthborder:CreatePanel("Default", 1, 1, "CENTER", health, "CENTER", 0, 0)
	healthborder:ClearAllPoints()
	healthborder:Point("TOPLEFT", health, -2, 2)
	healthborder:Point("BOTTOMRIGHT", health, 2, -2)
	healthborder:SetFrameLevel(2)
	healthborder:SetFrameStrata("MEDIUM")
	
	health.bg.multiplier = (0.3)
	self.Health.bg = health.bg
	
	health.PostUpdate = T.PostUpdatePetColor
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
		power.colorClass = true
		power.bg.multiplier = 0.1				
	else
		power.colorPower = true
	end
		
	local name = health:CreateFontString(nil, 'OVERLAY')
	name:SetFont(font2, 10, "THINOUTLINE")
	name:Point("CENTER", self, "CENTER", 0, 2)
	name:SetJustifyH("CENTER")
	name:SetWidth(((TukuiChatBackgroundLeft:GetWidth() / 5) - 7))
	self:Tag(name, '[Tukui:dead][Tukui:afk][Tukui:getnamecolor][Tukui:nameshort]')
	self.Name = name
	
	if C["unitframes"].showsymbols == true then
		RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:Height(14*T.raidscale)
		RaidIcon:Width(14*T.raidscale)
		RaidIcon:SetPoint("CENTER", self, "CENTER", 0, 12)
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end
	
	if C["unitframes"].aggro == true then
		table.insert(self.__elements, T.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
    end
	
	local leader = health:CreateTexture(nil, "OVERLAY")
    leader:Height(12)
    leader:Width(12)
    leader:SetPoint("TOPLEFT", 0, 6)
	self.Leader = leader
	
	local MasterLooter = health:CreateTexture(nil, "OVERLAY")
    MasterLooter:Height(12)
    MasterLooter:Width(12)
	self.MasterLooter = MasterLooter
    self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)
	
	local LFDRole = health:CreateTexture(nil, "OVERLAY")
    LFDRole:Height(6*T.raidscale)
    LFDRole:Width(6*T.raidscale)
	LFDRole:Point("BOTTOMLEFT", 0, 0)
	LFDRole:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\lfdicons.blp")
	self.LFDRole = LFDRole
	
	local ReadyCheck = health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(20*T.raidscale)
	ReadyCheck:Width(20*T.raidscale)
	ReadyCheck:SetPoint('CENTER')
	self.ReadyCheck = ReadyCheck
	
	--local picon = self.Health:CreateTexture(nil, 'OVERLAY')
	--picon:SetPoint('CENTER', self.Health)
	--picon:SetSize(16, 16)
	--picon:SetTexture[[Interface\AddOns\Tukui\media\textures\picon]]
	--picon.Override = T.Phasing
	--self.PhaseIcon = picon
	
	
	-- self.DebuffHighlightAlpha = 1
	-- self.DebuffHighlightBackdrop = true
	-- self.DebuffHighlightFilter = true

	if C["unitframes"].showsmooth == true then
		health.Smooth = true
	end
	
	if C["unitframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["unitframes"].raidalphaoor}
		self.Range = range
	end
	
	-- Debuff Highlight
		local dbh = self.Health:CreateTexture(nil, "OVERLAY", Healthbg)
		dbh:SetAllPoints(self)
		dbh:SetTexture(TukuiCF["media"].normTex)
		dbh:SetBlendMode("ADD")
		dbh:SetVertexColor(0,0,0,0)
		self.DebuffHighlight = dbh
		self.DebuffHighlightFilter = true
		self.DebuffHighlightAlpha = 0.6
	-- end	
	
	

	return self
end

oUF:RegisterStyle('TukuiDpsR40', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiDpsR40")

	local raid = self:SpawnHeader("oUF_TukuiDpsRaid40", nil, "custom [@raid26,exists] show;hide", 
		'oUF-initialConfigFunction', [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute('initial-width'))
			self:SetHeight(header:GetAttribute('initial-height'))
		]],
		'initial-width', ((TukuiChatBackgroundLeft:GetWidth() / 5) - 7),
		'initial-height', T.Scale(20*T.raidscale),
		"showRaid", true, 
		"groupFilter", "1,2,3,4,5,6,7,8", 
		"groupingOrder", "1,2,3,4,5,6,7,8", 
		"groupBy", "GROUP", 
		"xoffset", T.Scale(7),
		"yOffset", T.Scale(-7),
		"maxColumns", 8,
		"unitsPerColumn", 5,
		"columnSpacing", T.Scale(10),
		"columnAnchorPoint", "BOTTOM",
		"Point", "LEFT"
	)
	raid:SetPoint('BOTTOMLEFT', TukuiChatBackgroundLeft, "TOPLEFT", 2, 10*T.raidscale)
end)

-- only show 5 groups in raid (25 mans raid)
local MaxGroup = CreateFrame("Frame")
MaxGroup:RegisterEvent("PLAYER_ENTERING_WORLD")
MaxGroup:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MaxGroup:SetScript("OnEvent", function(self)
	local inInstance, instanceType = IsInInstance()
	local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
	if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
		oUF_TukuiDpsRaid40:SetAttribute("groupFilter", "1,2,3,4,5")
	else
		oUF_TukuiDpsRaid40:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
	end
end)