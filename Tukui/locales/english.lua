-- localization for enUS and enGB
local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

L.chat_BATTLEGROUND_GET = "[BG]"
L.chat_BATTLEGROUND_LEADER_GET = "[BG]"
L.chat_BN_WHISPER_GET = "From"
L.chat_GUILD_GET = "[G]"
L.chat_OFFICER_GET = "[O]"
L.chat_PARTY_GET = "[P]"
L.chat_PARTY_GUIDE_GET = "[P]"
L.chat_PARTY_LEADER_GET = "[P]"
L.chat_RAID_GET = "[R]"
L.chat_RAID_LEADER_GET = "[R]"
L.chat_RAID_WARNING_GET = "[W]"
L.chat_WHISPER_GET = "From"
L.chat_FLAG_AFK = "[AFK]"
L.chat_FLAG_DND = "[DND]"
L.chat_FLAG_GM = "[GM]"
L.chat_ERR_FRIEND_ONLINE_SS = "is now |cff298F00online|r"
L.chat_ERR_FRIEND_OFFLINE_S = "is now |cffff0000offline|r"

L.chat_general = "General"
L.chat_trade = "Trade"
L.chat_defense = "LocalDefense"
L.chat_recrutment = "GuildRecruitment"
L.chat_lfg = "LookingForGroup"

L.disband = "Disbanding group."

L.datatext_download = "Download: "
L.datatext_bandwidth = "Bandwidth: "
L.datatext_guild = "Guild"
L.datatext_noguild = "No Guild - |r|cffC495DDTukui|r: |cffFF99FFSno"
L.datatext_bags = "Bags: "
L.datatext_friends = "Friends"
L.datatext_online = "Online: "
L.datatext_armor = "Armor"
L.datatext_earned = "Earned:"
L.datatext_spent = "Spent:"
L.datatext_deficit = "Deficit:"
L.datatext_profit = "Profit:"
L.datatext_timeto = "Time to"
L.datatext_friendlist = "Friends list:"
L.datatext_playersp = "sp"
L.datatext_playerap = "ap"
L.datatext_playerhaste = "haste"
L.datatext_dps = "dps"
L.datatext_hps = "hps"
L.datatext_playerarp = "arp"
L.datatext_session = "Session: "
L.datatext_character = "Character: "
L.datatext_server = "Server: "
L.datatext_totalgold = "Total: "
L.datatext_savedraid = "Saved Raid(s)"
L.datatext_currency = "Currency:"
L.datatext_fps = " fps & "
L.datatext_ms = " ms"
L.datatext_playercrit = " crit"
L.datatext_playerheal = " heal"
L.datatext_avoidancebreakdown = "Avoidance Breakdown"
L.datatext_lvl = "lvl"
L.datatext_boss = "Boss"
L.datatext_miss = "Miss"
L.datatext_dodge = "Dodge"
L.datatext_block = "Block"
L.datatext_parry = "Parry"
L.datatext_playeravd = "avd: "
L.datatext_servertime = "Server Time: "
L.datatext_localtime = "Local Time: "
L.datatext_mitigation = "Mitigation By Level: "
L.datatext_healing = "Healing : "
L.datatext_damage = "Damage : "
L.datatext_honor = "Honor : "
L.datatext_killingblows = "Killing Blows : "
L.datatext_ttstatsfor = "Stats for "
L.datatext_ttkillingblows = "Killing Blows:"
L.datatext_tthonorkills = "Honorable Kills:"
L.datatext_ttdeaths = "Deaths:"
L.datatext_tthonorgain = "Honor Gained:"
L.datatext_ttdmgdone = "Damage Done:"
L.datatext_tthealdone = "Healing Done:"
L.datatext_basesassaulted = "Bases Assaulted:"
L.datatext_basesdefended = "Bases Defended:"
L.datatext_towersassaulted = "Towers Assaulted:"
L.datatext_towersdefended = "Towers Defended:"
L.datatext_flagscaptured = "Flags Captured:"
L.datatext_flagsreturned = "Flags Returned:"
L.datatext_graveyardsassaulted = "Graveyards Assaulted:"
L.datatext_graveyardsdefended = "Graveyards Defended:"
L.datatext_demolishersdestroyed = "Demolishers Destroyed:"
L.datatext_gatesdestroyed = "Gates Destroyed:"
L.datatext_totalmemusage = "Total Memory Usage:"
L.datatext_control = "Controlled by:"

L.Slots = {
	[1] = {1, "Head", 1000},
	[2] = {3, "Shoulder", 1000},
	[3] = {5, "Chest", 1000},
	[4] = {6, "Waist", 1000},
	[5] = {9, "Wrist", 1000},
	[6] = {10, "Hands", 1000},
	[7] = {7, "Legs", 1000},
	[8] = {8, "Feet", 1000},
	[9] = {16, "Main Hand", 1000},
	[10] = {17, "Off Hand", 1000},
	[11] = {18, "Ranged", 1000}
}

L.popup_disableui = "Tukui doesn't work for this resolution, do you want to disable Tukui? (Cancel if you want to try another resolution)"
L.popup_install = "First time running Tukui V13 with this Character. You must reload your UI to set Action Bars, Variables and Chat Frames."
L.popup_reset = "Warning! This will reset everything to Tukui default. Do you want to proceed?"
L.popup_2raidactive = "2 raid layouts are active, please select a layout."
L.popup_install_yes = "Yeah! (recommended!)"
L.popup_install_no = "No, it sux so hard"
L.popup_reset_yes = "Yeah baby!"
L.popup_reset_no = "No, or else I'll QQ in the forums!"

L.merchant_repairnomoney = "You don't have enough money to repair!"
L.merchant_repaircost = "Your items have been repaired for"
L.merchant_trashsell = "Your vendor trash has been sold and you earned"

L.goldabbrev = "|cffffd700g|r"
L.silverabbrev = "|cffc7c7cfs|r"
L.copperabbrev = "|cffeda55fc|r"

L.error_noerror = "No error yet."

L.unitframes_ouf_offline = "Offline"
L.unitframes_ouf_dead = "Dead"
L.unitframes_ouf_ghost = "Ghost"
L.unitframes_ouf_lowmana = "LOW MANA"
L.unitframes_ouf_threattext = "Threat on current target:"
L.unitframes_ouf_offlinedps = "Offline"
L.unitframes_ouf_deaddps = "|cffff0000[DEAD]|r"
L.unitframes_ouf_ghostheal = "GHOST"
L.unitframes_ouf_deadheal = "DEAD"
L.unitframes_ouf_gohawk = "GO HAWK"
L.unitframes_ouf_goviper = "GO VIPER"
L.unitframes_disconnected = "D/C"
L.unitframes_ouf_wrathspell = "Wrath"
L.unitframes_ouf_starfirespell = "Starfire"

L.tooltip_count = "Count"

L.bags_noslots = "can't buy anymore slots!"
L.bags_costs = "Cost: %.2f gold"
L.bags_buyslots = "Buy new slot with /bags purchase yes"
L.bags_openbank = "You need to open your bank first."
L.bags_sort = "sort your bags or your bank, if open."
L.bags_stack = "fill up partial stacks in your bags or bank, if open."
L.bags_buybankslot = "buy bank slot. (need to have bank open)"
L.bags_search = "Search"
L.bags_sortmenu = "Sort"
L.bags_sortspecial = "Sort Special"
L.bags_stackmenu = "Stack"
L.bags_stackspecial = "Stack Special"
L.bags_showbags = "Show Bags"
L.bags_sortingbags = "Sorting finished."
L.bags_nothingsort= "Nothing to sort."
L.bags_bids = "Using bags: "
L.bags_stackend = "Restacking finished."
L.bags_rightclick_search = "Right-click to search."

L.chat_invalidtarget = "Invalid Target"

L.mount_wintergrasp = "Wintergrasp"

L.core_autoinv_enable = "Autoinvite ON: invite"
L.core_autoinv_enable_c = "Autoinvite ON: "
L.core_autoinv_disable = "Autoinvite OFF"
L.core_wf_unlock = "WatchFrame unlock"
L.core_wf_lock = "WatchFrame lock"
L.core_welcome1 = "Welcome to |cffC495DDTukui|r: |cffFF99FFSno's Edit|r, version "
L.core_welcome2 = "Type |cff00FFFF/uihelp|r for more info or visit www.tukui.org"

L.core_uihelp1 = "|cff00ff00General Slash Commands|r"
L.core_uihelp2 = "|cffFF0000/moveui|r - Unlock and move elements around the screen."
L.core_uihelp3 = "|cffFF0000/rl|r - Reloads your User Interface."
L.core_uihelp4 = "|cffFF0000/gm|r - Send GM tickets or shows WoW in-game help."
L.core_uihelp5 = "|cffFF0000/frame|r - Detect the frame name your mouse is currently on. (very useful for lua editors)"
L.core_uihelp6 = "|cffFF0000/heal|r - Enable healing raid layout."
L.core_uihelp7 = "|cffFF0000/dps|r - Enable Dps/Tank raid layout."
L.core_uihelp8 = "|cffFF0000/bags|r - For sorting, buying bank slot, or stacking items in your bags."
L.core_uihelp9 = "|cffFF0000/resetui|r - Reset Tukui to default."
L.core_uihelp10 = "|cffFF0000/rd|r - Disband raid."
L.core_uihelp11 = "|cffFF0000/ainv|r - Enable autoinvite via keyword on whisper. You can set your own keyword by typing `/ainv myword`"
L.core_uihelp100 = "(Scroll up for more commands ...)"

L.symbol_CLEAR = "Clear"
L.symbol_SKULL = "Skull"
L.symbol_CROSS = "Cross"
L.symbol_SQUARE = "Square"
L.symbol_MOON = "Moon"
L.symbol_TRIANGLE = "Triangle"
L.symbol_DIAMOND = "Diamond"
L.symbol_CIRCLE = "Circle"
L.symbol_STAR = "Star"

L.bind_combat = "You can't bind keys in combat."
L.bind_saved = "All keybindings have been saved."
L.bind_discard = "All newly set keybindings have been discarded."
L.bind_instruct = "Hover your mouse over any actionbutton to bind it. Press the escape key or right click to clear the current actionbuttons keybinding."
L.bind_save = "Save bindings"
L.bind_discardbind = "Discard bindings"

L.hunter_unhappy = "Your pet is unhappy!"
L.hunter_content = "Your pet is content!"
L.hunter_happy = "Your pet is happy!"

L.move_tooltip = "Move Tooltip"
L.move_minimap = "Move Minimap"
L.move_watchframe = "Move Quests"
L.move_gmframe = "Move Ticket"
L.move_buffs = "Move Player Buffs"
L.move_debuffs = "Move Player Debuffs"
L.move_shapeshift = "Move Shapeshift/Totem"
L.move_achievements = "Move Achievements"
L.move_roll = "Move Loot Roll Frame"
L.move_vehicle = "Move Vehicle Seat"