
local T, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

------------------------------------------------------------------------
-- Chat Animation Functions
------------------------------------------------------------------------
T.ToggleSlideChatL = function()
	if T.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		T.SlideOut(ChatLBackground)	
		T.ChatLIn = false
		ElvuiInfoLeftLButton.text:SetTextColor(unpack(C["media"].valuecolor))
	else
		T.SlideIn(ChatLBackground)
		T.ChatLIn = true
		ElvuiInfoLeftLButton.text:SetTextColor(1,1,1,1)
	end
end

T.ToggleSlideChatR = function()
	if T.RightChat ~= true then return end
	if T.ChatRIn == true then
		T.SlideOut(ChatRBackground)		
		T.ChatRIn = false
		T.ChatRightShown = false
		ElvuiInfoRightRButton.text:SetTextColor(unpack(C["media"].valuecolor))
	else
		T.SlideIn(ChatRBackground)
		T.ChatRIn = true
		T.ChatRightShown = true
		ElvuiInfoRightRButton.text:SetTextColor(1,1,1,1)
	end
end

--Bindings For Chat Sliders
function ChatLeft_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if T.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		T.ToggleSlideChatL()
	else
		T.ToggleSlideChatL()
	end		
end

function ChatRight_HotkeyPressed(keystate)
	if keystate == "up" then return end
	T.ToggleSlideChatR()		
end

function ChatBoth_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if T.ChatLIn == true then
		T.ToggleSlideChatR()
		T.ToggleSlideChatL()
	else
		T.ToggleSlideChatR()
		T.ToggleSlideChatL()
	end
end

--Fixes chat windows not displaying
ChatLBackground.anim_o:HookScript("OnFinished", function()
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local tab = _G[format("ChatFrame%sTab", i)]
		local id = chat:GetID()
		local point = GetChatWindowSavedPosition(id)
		local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
		chat:SetParent(tab)
	end
end)

ChatLBackground.anim_o:HookScript("OnPlay", function()
	if T.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end		
	end
end)

ChatLBackground.anim:HookScript("OnFinished", function()
	if T.RightChat ~= true then return end
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local id = chat:GetID()
		local point = GetChatWindowSavedPosition(id)
		local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
		chat:SetParent(UIParent)
		
		if i == T.RightChatWindowID then
			chat:SetParent(_G[format("ChatFrame%sTab", i)])
		else
			chat:SetParent(UIParent)
		end
	end
	ElvuiInfoLeft.shadow:SetBackdropBorderColor(0,0,0,1)
	ElvuiInfoLeft:SetScript("OnUpdate", function() end)
	T.StopFlash(ElvuiInfoLeft.shadow)
end)

ChatRBackground.anim_o:HookScript("OnPlay", function()
	if T.RightChat ~= true or not T.RightChatWindowID then return end
	local chat = _G[format("ChatFrame%s", T.RightChatWindowID)]
	chat:SetParent(_G[format("ChatFrame%sTab", T.RightChatWindowID)])
	chat:SetFrameStrata("LOW")
end)

ChatRBackground.anim:HookScript("OnFinished", function()
	if T.RightChat ~= true or not T.RightChatWindowID then return end
	local chat = _G[format("ChatFrame%d", T.RightChatWindowID)]
	chat:SetParent(UIParent)
	chat:SetFrameStrata("LOW")
	ElvuiInfoRight.shadow:SetBackdropBorderColor(0,0,0,1)
	ElvuiInfoRight:SetScript("OnUpdate", function() end)
	T.StopFlash(ElvuiInfoRight.shadow)
end)

--Setup Button Scripts
ElvuiInfoLeftLButton:SetScript("OnMouseDown", function(self, btn)
	if btn == "RightButton" then
		if T.ChatLIn == true then
			for i = 1, NUM_CHAT_WINDOWS do
				local chat = _G[format("ChatFrame%s", i)]
				local tab = _G[format("ChatFrame%sTab", i)]
				chat:SetParent(tab)
			end
			T.ToggleSlideChatR()
			T.ToggleSlideChatL()
		else
			T.ToggleSlideChatR()
			T.ToggleSlideChatL()
		end	
	else
		if T.ChatLIn == true then
			for i = 1, NUM_CHAT_WINDOWS do
				local chat = _G[format("ChatFrame%s", i)]
				local tab = _G[format("ChatFrame%sTab", i)]
				chat:SetParent(tab)
			end
			T.ToggleSlideChatL()
		else
			T.ToggleSlideChatL()
		end		
	end
end)

ElvuiInfoRightRButton:SetScript("OnMouseDown", function(self, btn)
	if T.RightChat ~= true then return end
	if btn == "RightButton" then
		T.ToggleSlideChatR()
		T.ToggleSlideChatL()
	else
		T.ToggleSlideChatR()
	end
end)