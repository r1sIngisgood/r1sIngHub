if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services//
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
--\\

if not isfolder("r1sIngHub") then makefolder("r1sIngHub") end
if not isfolder("r1sIngHub"..[[\]].."Anime Adventures") then makefolder("r1sIngHub"..[[\]].."Anime Adventures") end
if not isfolder("r1sIngHub"..[[\]].."configs") then makefolder("r1sIngHub"..[[\]].."configs") end
if not isfile("r1sIngHub"..[[\]].."configs"..[[\]]..Players.LocalPlayer.Name.."_AnimeAdventures.json") then writefile("r1sIngHub"..[[\]].."configs"..[[\]]..""..Players.LocalPlayer.Name.."_AnimeAdventures.json","") end

local SERVER_READY = workspace:WaitForChild("SERVER_READY")
repeat task.wait() until SERVER_READY.Value
task.wait(6)
-- Game Stuff//
local units_module = require(ReplicatedStorage.src.Data.Units)
local maps_module = ReplicatedStorage.src.Data.Maps
local levels_module = ReplicatedStorage.src.Data.Levels
local worlds_module = ReplicatedStorage.src.Data.Worlds
local worlds_module_table = {}
local maps_module_table = {}
for _,obj in pairs(worlds_module:GetDescendants()) do
    if obj:IsA("ModuleScript") then
        local req = require(obj)
        for i,v in pairs(req) do
            worlds_module_table[i] = v
        end
    end
end
for _,obj in pairs(maps_module:GetDescendants()) do
    if obj:IsA("ModuleScript") then
        local req = require(obj)
        for i,v in pairs(req) do
            maps_module_table[i] = v
        end
    end
end
local workspace_data_folder = workspace:FindFirstChild("_DATA")
local value_game_started = nil
local value_game_finished = nil
local value_voting_finished = nil
if workspace_data_folder then
    value_game_started = workspace_data_folder:FindFirstChild("GameStarted")
    value_game_finished = workspace_data_folder:FindFirstChild("GameFinished")
    local workspace_votestart_folder = workspace_data_folder:FindFirstChild("VoteStart")
    if workspace_votestart_folder then
        value_voting_finished = workspace_votestart_folder:WaitForChild("VotingFinished")
    end
end
local value_wave_num = workspace:FindFirstChild("_wave_num")
local value_wave_time = workspace:FindFirstChild("_wave_time")
local value_is_lobby = workspace:WaitForChild("_MAP_CONFIG"):FindFirstChild("IsLobby")
local client_to_server_folder = ReplicatedStorage.endpoints["client_to_server"]
local remote_place = client_to_server_folder["spawn_unit"]
local remote_sell_ingame = client_to_server_folder["sell_unit_ingame"]
local remote_upgrade_ingame = client_to_server_folder["upgrade_unit_ingame"]
local remote_unequip_all_units = client_to_server_folder["unequip_all"]
local remote_equip_unit = client_to_server_folder["equip_unit"]
local remote_sell_unit_ingame = client_to_server_folder["sell_unit_ingame"]
local remote_use_active_attack = client_to_server_folder["use_active_attack"]
local remote_get_level_data = workspace:FindFirstChild("_MAP_CONFIG"):FindFirstChild("GetLevelData")
local remote_vote_start = client_to_server_folder["vote_start"]
task.spawn(function()
    if value_voting_finished ~= nil then
        repeat task.wait(1)
            remote_vote_start:InvokeServer()
        until value_voting_finished == true
    end
end)
local current_map
if remote_get_level_data then
    current_map = remote_get_level_data:InvokeServer()
else
    current_map = nil
end
local map_list = {}
local map_vanity_names = {
    story = {},
    portal = {},
    raid = {},
    infinite = {},
    legend = {}
}
local sorted_map_types = {
    story = {},
    portal = {},
    raid = {},
    infinite = {},
    legend = {},
}
local map_dropdowns = {}
local function update_map_dropdowns()
    for i,v in pairs(map_dropdowns) do
        v:SetValues()
    end
end
for i,v in pairs(levels_module:GetDescendants()) do
    if v:IsA("ModuleScript") and v.Name ~= "Levels_Rest" then
        local req = require(v)
        for d,c in pairs(req) do
            if c.portal_group and c.portal_group ~= "christmas" and c.portal_group ~= "csm" then
                --print(c.id.." is portal")
                sorted_map_types.portal[c.id] = true
                map_vanity_names.portal[c.id] = c.name
            end
            if c.is_raid and not c._IS_EVENT_RAID and c.name ~= "Universal Tournament" then
                --print(c.id.." is raid")
                sorted_map_types.raid[c.map] = true
                map_vanity_names.raid[c.map] = worlds_module_table[c.world].name
            end
            if c.infinite then
                if c.map ~= "madoka" and not c.is_raid then --  WHY THE FUCK IS THERE MADOKA EVENT INF IN LEVELS PLEASE TELL ME DEVS
                    --print(c.id.." is infinite")
                    sorted_map_types.infinite[c.map] = true
                    map_vanity_names.infinite[c.map] = worlds_module_table[c.world].name
                end
            end
        end
    end
end
for i,v in pairs(worlds_module_table) do
    if string.find(i, "legend") then
        sorted_map_types.legend[v.map] = true
        map_vanity_names.legend[v.map] = v.name
    elseif not v.raid_world then
        sorted_map_types.story[v.map] = true
        map_vanity_names.story[v.map] = v.name
    end
end
--summer temp fix cuz idk how to get it from elsewhere TODO: Find a module with every level including summer
for i,v in pairs(maps_module_table) do
    if string.find(i, "summer") then
        sorted_map_types.portal[v.id] = true
        map_vanity_names.portal[v.id] = v.name
    end
end
--\\
--\\

-- UI//
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local lib_SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()
local ui_window = lib:CreateWindow({Title = "r1sIngHub", Center = true, AutoShow = true})
local ui_tabs = {
    macro = ui_window:AddTab("Macro"),
    farm_settings = ui_window:AddTab("Farm Settings"),
    ui_settings = ui_window:AddTab("UI Settings")
}

--[[local ui_settings_discordgroupbox = ui_tabs.ui_settings:AddRightGroupbox("Discord Config")
local ui_settings_discordwebhook_input = ui_settings_discordgroupbox:AddInput("discord_webhook_input", {Default = "",Numeric = false,Finished=true,Text="Webhook Link",Tooltip="Paste in ur link and press ENTER.",Placeholder="https://discord.com/api/webhooks/..."})
local ui_settings_discordwebhookping_toggle = ui_settings_discordgroupbox:AddToggle("discord_webhook_ping_toggle", {Text="Ping id",Default=false,Tooltip='Pings the id you pasted when sending the webhook'})
local ui_settings_discordwebhookping_input = ui_settings_discordgroupbox:AddInput("discord_webhook_ping_id_input",{Default="",Numeric=true,Finished=true,Text="Discord User Id",Tooltip="Paste discord user id and press ENTER"})
local ui_settings_discordwebhookresult_toggle = ui_settings_discordgroupbox:AddToggle("discord_webhook_result_toggle", {Text="Send results",Default=false,Tooltip='Sends results upon completion/failure'})]]
--\\

local ui_farm_autounits_groupbox = ui_tabs.farm_settings:AddRightGroupbox("Auto Units")
local ui_farm_autounits_autohomura_toggle = ui_farm_autounits_groupbox:AddToggle("auto_homura_toggle",{Text="Auto Homura",Default = false,Tooltip="Homura will timestop if she has an enemy in range."})
local ui_farm_autounits_buffdivider = ui_farm_autounits_groupbox:AddDivider()
local ui_farm_autounits_bufflabel = ui_farm_autounits_groupbox:AddLabel("Buff")
local ui_farm_autounits_autoerwin_toggle = ui_farm_autounits_groupbox:AddToggle("auto_erwin_toggle",{Text="Auto Erwin 100%",Default = false,Tooltip="Auto Erwin buff 100%"})
local ui_farm_autounits_autoerwincurse_toggle = ui_farm_autounits_groupbox:AddToggle("erwin_curse_toggle",{Text="Erwin Curse?",Default = false,Tooltip="Changes delay to 8 seconds instead of 15"})
local ui_farm_autounits_autoerwinmanual_toggle = ui_farm_autounits_groupbox:AddToggle("manual_erwin_delay_toggle",{Text="Manual Erwin Delay",Default = false,Tooltip="Manually control the delay"})
local ui_farm_autounits_autoerwinmanual_slider = ui_farm_autounits_groupbox:AddSlider("manual_erwin_delay_slider", {Text="Manual Delay",Default = 15,Min=0,Max=15,Rounding=0,Compact=true})
local ui_farm_autounits_erwinwenda_divider = ui_farm_autounits_groupbox:AddDivider()
local ui_farm_autounits_autowenda_toggle = ui_farm_autounits_groupbox:AddToggle("auto_wenda_toggle",{Text="Auto Wenda 100%",Default = false,Tooltip="Auto Wenda buff 100%"})
local ui_farm_autounits_autowendacurse_toggle = ui_farm_autounits_groupbox:AddToggle("wenda_curse_toggle",{Text="Wenda Curse?",Default = false,Tooltip="Changes delay to 8 seconds instead of 15"})
local ui_farm_autounits_autowendamanual_toggle = ui_farm_autounits_groupbox:AddToggle("manual_wenda_delay_toggle",{Text="Manual Wenda Delay",Default = false,Tooltip="Manually control the delay"})
local ui_farm_autounits_autowendamanual_slider = ui_farm_autounits_groupbox:AddSlider("manual_wenda_delay_slider", {Text="Manual Delay",Default = 15,Min=0,Max=15,Rounding=0,Compact=true})

local ui_farm_settings_tabbox = ui_tabs.farm_settings:AddLeftTabbox()
local ui_farm_settings_portals_tab = ui_farm_settings_tabbox:AddTab("Portals")
local ui_farm_settings_portals_autoportal_toggle = ui_farm_settings_portals_tab:AddToggle("portals_autoportal_toggle",{Text="Enable Auto Next Portal",Default = false,Tooltip="Toggle Auto Next Portal Feature"})
local ui_farm_settings_portals_portalid_input = ui_farm_settings_portals_tab:AddInput("portals_portalid_input",{Default="portal_summer",Numeric=false,Finished=true,Text="Portal Item Id",Placeholder="portal_summer for summer event"})
local ui_farm_settings_portals_tiers_dropdown = ui_farm_settings_portals_tab:AddDropdown("portals_tiers_multidropdown",{Values={'1','2','3','4','5','6','7','8','9','10','11','12'},Default=0,Multi=true,Text="Portal Tiers",Tooltip="Choose what portal tiers you want to pick"})
local ui_farm_settings_portals_ignoremods_dropdown = ui_farm_settings_portals_tab:AddDropdown("portals_ignoremods_multidropdown",{Values={"double_cost","fast_enemies","short_range","shield_enemies","tank_enemies"},Default=0,Multi=true,Text="Ignore Modifiers",Tooltip="Choose what modifiers you want to ignore"})
local ui_farm_settings_portals_divider1 = ui_farm_settings_portals_tab:AddDivider()
local ui_farm_settings_portals_help_label = ui_farm_settings_portals_tab:AddLabel("If you don't know what portal id to use here you go:\nSummer Event: portal_summer",true)
--TODO: Add built-in auto portal choose for summer portals

-- Misc Functions//
local function checkJSON(str)
    local result = pcall(function()
        HttpService:JSONDecode(str)
    end)
    return result
end
function string_insert(str1, str2, pos) return str1:sub(1,pos)..str2..str1:sub(pos+1) end
local function cfgbeautify(str) return string.gsub(string.gsub(str,"r1sIngHub"..[[\]].."Anime Adventures"..[[\]],""),".json","") end
local function isdotjson(file) return string.sub(file, -5) == ".json" end
local function string_to_cframe(str) return CFrame.new(table.unpack(str:gsub(" ",""):split(","))) end
local function string_to_vector3(str) return Vector3.new(table.unpack(str:gsub(" ",""):split(","))) end
local config_ignore_list = {"macro_create_input", "MenuKeybind", "macro_record_toggle"}

-- Config Functions/
local function Save_Configuration()
    local success, err = pcall(function()
        local options_table = {toggle_table = {}, map_dropdowns = {}, input_table = {}}
        for option_name, val in pairs(getgenv().Options) do
            if string.find(option_name, "macro_map") and not table.find(config_ignore_list, option_name) then
                options_table.map_dropdowns[option_name] = val.Value
            elseif string.find(option_name, "multidropdown") and not table.find(config_ignore_list, option_name) then
                options_table[option_name] = val.Value
            elseif string.find(option_name, "input") and not table.find(config_ignore_list, option_name) then
                options_table.input_table[option_name] = ""..val.Value
            elseif not table.find(config_ignore_list, option_name) then
                options_table[option_name] = val.Value
            end
        end
        for toggle_name, val in pairs(getgenv().Toggles) do
            options_table.toggle_table[toggle_name] = val.Value
        end
        local jsonencoded_options_table = HttpService:JSONEncode(options_table)
        writefile("r1sIngHub"..[[\]].."configs"..[[\]]..Players.LocalPlayer.Name.."_AnimeAdventures.json", jsonencoded_options_table)
    end)
    if err then
        error("CONFIG SAVE ERROR:\n"..err)
    end
end
local function Load_Configuration()
    local success, err = pcall(function()
        local config_file 
        config_file = HttpService:JSONDecode(readfile("r1sIngHub"..[[\]].."configs"..[[\]]..Players.LocalPlayer.Name.."_AnimeAdventures.json"))
        for option_name, val in pairs(config_file) do
            if option_name == "toggle_table" and val then
                for toggle_name, toggle_value in pairs(val) do
                    if getgenv().Toggles[toggle_name] then
                        getgenv().Toggles[toggle_name]:SetValue(toggle_value)
                    end
                end
            elseif option_name == "map_dropdowns" and val then
                for dropdown_name, dropdown_value in pairs(val) do
                    getgenv().Options[dropdown_name]:SetValue(dropdown_value)
                end
            else
                local option = getgenv().Options[option_name]
                if option and val then
                    option:SetValue(val)
                end
            end
        end
    end)
    if err then
        error("CONFIG LOAD ERROR:\n"..err)
    end
end
--\
local ui_settings_lefttabbox = ui_tabs.ui_settings:AddLeftTabbox()
local ui_settings_lefttabbox_ui = ui_settings_lefttabbox:AddTab("UI Settings")
ui_settings_lefttabbox_ui:AddButton("Unload", function()
    lib:Unload()
    lib.Unloaded = true
    Save_Configuration()
end)
ui_settings_lefttabbox_ui:AddLabel("UI Keybind"):AddKeyPicker("MenuKeybind", {Default = "End", NoUI = true, Text = "UI Keybind"})
lib.ToggleKeybind = getgenv().Options.MenuKeybind
--\\

-- Macro //
local filelist = listfiles("r1sIngHub"..[[\]].."Anime Adventures")
local macro_list = {}
local macro_units_list = {}
local chosen_macro_contents
for _,file in ipairs(filelist) do
    local cfgname = cfgbeautify(file)
    if isdotjson(file) then
        table.insert(macro_list, cfgname)
    else
        lib:Notify(cfgname.." is not a json file and wasnt loaded.")
    end
end

local equipped_units = {}
local player_unit_inventory = {}
repeat
    for i,v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "xp") then
            if v["equipped_slot"] then
                table.insert(equipped_units, v)
            end
        end
    end
until #equipped_units > 0

repeat
for i,v in pairs(getgc(true)) do
    if type(v) == "table" and rawget(v, "xp") then
        table.insert(player_unit_inventory, v)
    end
end
until #player_unit_inventory > 0

local ui_macro_leftgroupbox = ui_tabs.macro:AddLeftGroupbox("Macro Config")
local ui_macro_choosemacro = ui_macro_leftgroupbox:AddDropdown("current_macro_dropdown", {
    Values = macro_list,
    Default = 0,
    Multi = false,
    Text = "Select",
    Tooltip = "Select Macro Here"
})
local ui_create_macro_input = ui_macro_leftgroupbox:AddInput("macro_create_input", {
    Default = "",
    Numeric = false,
    Finished = true,
    Text = "Create Macro",
    Tooltip = "Enter macro name and press ENTER",
    Placeholder = "Name Macro Here"
})
local ui_macro_dropdown_update = ui_macro_leftgroupbox:AddButton({Text = "Update Macro List",
Func = function()
    filelist = listfiles("r1sIngHub"..[[\]].."Anime Adventures")
    macro_list = {}
    for _,file in ipairs(filelist) do
        local cfgname = cfgbeautify(file)
        if isdotjson(file) then
            table.insert(macro_list, cfgname)
        else
            lib:Notify(cfgname.." is not a json file and wasnt loaded.")
        end
    end
    getgenv().Options.current_macro_dropdown:SetValues(macro_list)
    update_map_dropdowns()
end,DoubleClick = false,Tooltip = "Updates macro dropdown if you manually added/removed any"})

local ui_macro_delete_button = ui_macro_leftgroupbox:AddButton({Text = "Delete Selected Macro",
Func = function()
    delfile("r1sIngHub"..[[\]].."Anime Adventures"..[[\]]..getgenv().Options.current_macro_dropdown.Value..".json")
    table.remove(getgenv().Options.current_macro_dropdown.Values, table.find(getgenv().Options.current_macro_dropdown.Values,getgenv().Options.current_macro_dropdown.Value))
    getgenv().Options.current_macro_dropdown:SetValues()
    getgenv().Options.current_macro_dropdown:SetValue()
    Save_Configuration()
end, DoubleClick = false,Tooltip = "Delete's selected macro"})
local ui_macro_units_list_label = ui_macro_leftgroupbox:AddLabel("Unit List:", true)
local ui_macro_units_equip_button = ui_macro_leftgroupbox:AddButton({Text = "Equip Macro Units",
Func = function()
    if chosen_macro_contents == "" then lib:Notify("This macro is broken/empty.") return end
    if macro_units_list == {} then lib:Notify("This macro is empty. Can't equip nil units xddd") return end
    remote_unequip_all_units:InvokeServer()
    task.wait(0.5)
    for i,unit_name in pairs(macro_units_list) do
        local has_unit = false
        for id,unit_table in pairs(player_unit_inventory) do
            if unit_table["unit_id"] == unit_name then
                has_unit = unit_table
            end
        end
        if has_unit ~= false then
            remote_equip_unit:InvokeServer(has_unit["uuid"])
        else
            lib:Notify("You do not have "..unit_name.." for this macro.")
        end
        task.wait(0.5)
    end
end,DoubleClick = false,Tooltip = "Equips units that selected macro uses"})

local ui_macro_divider1 = ui_macro_leftgroupbox:AddDivider()
local ui_macro_label1 = ui_macro_leftgroupbox:AddLabel("Macro")
local ui_macro_play_toggle = ui_macro_leftgroupbox:AddToggle("macro_play_toggle", {Text = "Play Macro", Default = false, Tooltip = "Plays macro, dumbass"})
local ui_macro_play_stepdelay = ui_macro_leftgroupbox:AddSlider("macro_play_stepdelay_slider", {Text = "Step Delay", Default = 0.1, Min = 0.1, Max = 1, Rounding = 2, Compact = false, HideMax = false})
local ui_macro_play_progress_label = ui_macro_leftgroupbox:AddLabel("", true)
local ui_macro_divider2 = ui_macro_leftgroupbox:AddDivider()
local ui_macro_label2 = ui_macro_leftgroupbox:AddLabel("Macro Record")
local ui_macro_record_toggle = ui_macro_leftgroupbox:AddToggle("macro_record_toggle", {Text = "Enable", Default = false, Tooltip = "Enables Macro Record"})

local ui_macro_righttabbox = ui_tabs.macro:AddRightTabbox()
local ui_macro_rightgroupbox = ui_tabs.macro:AddRightGroupbox("Infinite")
local ui_macro_righttabbox_tabs = {
    story = ui_macro_righttabbox:AddTab("Story"),
    infinite_tower = ui_macro_righttabbox:AddTab("INF Tower"),
    raid = ui_macro_righttabbox:AddTab("Raids"),
    legend = ui_macro_righttabbox:AddTab("Legend"),
    portal = ui_macro_righttabbox:AddTab("Portals"),
}

for i,v in pairs(sorted_map_types) do
    for map, state in pairs(v) do
        if i ~= "infinite" then
            local ui_macro_map_dropdown = ui_macro_righttabbox_tabs[i]:AddDropdown("macro_map_"..i.."_"..map.."_dropdown",
            {
                Values = macro_list,
                Default = 0,
                Multi = false,
                Text = map_vanity_names[i][map],
                Tooltip = ''
            })
            table.insert(map_dropdowns, ui_macro_map_dropdown)
        elseif i == "infinite" then
            local ui_macro_map_dropdown = ui_macro_rightgroupbox:AddDropdown("macro_map_"..i.."_"..map.."_dropdown",
            {
                Values = macro_list,
                Default = 0,
                Multi = false,
                Text = map_vanity_names[i][map],
                Tooltip = ''
            })
            table.insert(map_dropdowns, ui_macro_map_dropdown)
        end
    end
end

local function Choose_Macro(macro_name)
    if type(macro_name) ~= "string" or macro_name == "" then return end
    if not isfile("r1sIngHub"..[[\]].."Anime Adventures"..[[\]]..macro_name..".json") then
        getgenv().Options.current_macro_dropdown:SetValues()
        update_map_dropdowns()
        return
    end
    local macro_file_contents = readfile("r1sIngHub/Anime Adventures/"..macro_name..".json")
    if checkJSON(macro_file_contents) then
        macro_units_list = {}
        chosen_macro_contents = {HttpService:JSONDecode(readfile("r1sIngHub/Anime Adventures/"..macro_name..".json"))}
        local stepCount = 0
        for i,v in pairs(chosen_macro_contents[1]) do
            stepCount += 1
            if v["unit"] and not table.find(macro_units_list, v["unit"]) then
                table.insert(macro_units_list,v["unit"])
            end
        end
        table.insert(chosen_macro_contents, stepCount)
        table.insert(chosen_macro_contents, macro_units_list)
        local string_for_ui = "Unit List:\n"
        for i,v in pairs(macro_units_list) do
            string_for_ui = string_for_ui..i..": "..v.."\n"
        end
        ui_macro_units_list_label:SetText(string_for_ui)
        Save_Configuration()
    else
        chosen_macro_contents = ""
        ui_macro_units_list_label:SetText("Units List:")
        lib:Notify("This macro is empty (or broken). Just letting you know.")
    end
    update_map_dropdowns()
end
ui_macro_choosemacro:OnChanged(function()
    Choose_Macro(ui_macro_choosemacro.Value)
end)

local function Create_Macro(macro_name)
    if type(macro_name) ~= "string" or macro_name == "" then return end
    if not isfile("r1sIngHub"..[[\]].."Anime Adventures"..[[\]]..macro_name..".json") then
        writefile("r1sIngHub"..[[\]].."Anime Adventures"..[[\]]..macro_name..".json", "")
        table.insert(getgenv().Options.current_macro_dropdown.Values, macro_name)
        getgenv().Options.current_macro_dropdown:SetValues()
        getgenv().Options.current_macro_dropdown:SetValue(macro_name)
        update_map_dropdowns()
        Save_Configuration()
    end
end
ui_create_macro_input:OnChanged(function()
    if ui_create_macro_input.Value == "" or not ui_create_macro_input.Value then return end
    Create_Macro(ui_create_macro_input.Value)
end)
Load_Configuration()
local function auto_homura()
    while task.wait() do
        if ui_farm_autounits_autohomura_toggle.Value and not value_is_lobby.Value then
            local success,err = pcall(function()
                repeat task.wait() until workspace:WaitForChild("_UNITS")
                local plyr = Players.LocalPlayer
                for i, v in ipairs(workspace["_UNITS"]:GetChildren()) do
                    if v:FindFirstChild("_stats") then
                        if v._stats.id.Value == "homura_evolved" and v._stats.player.Value == plyr and v._stats.state.Value == 'attack' then
                            remote_use_active_attack:InvokeServer(v)
                        end
                    end
                end
            end)

            if err then
                warn(err)
            end
        end
    end
end
ui_farm_autounits_autohomura_toggle:OnChanged(function()
    if getgenv().Toggles.auto_homura_toggle.Value then
        task.spawn(coroutine.wrap(auto_homura))
    end
end)
local function auto_wenda()
    while task.wait() do
        if ui_farm_autounits_autowenda_toggle.Value and not value_is_lobby.Value then
            local plr = Players.LocalPlayer
            local delay
            if ui_farm_autounits_autowendamanual_toggle.Value then
                delay = ui_farm_autounits_autowendamanual_slider.Value
            else
                if ui_farm_autounits_autowendacurse_toggle.Value then
                    delay = 8
                else
                    delay = 15.4
                end
            end
            local unitlist = {}
            for _,v in pairs(workspace._UNITS:GetChildren()) do
                if v.Name == "wenda" and v:WaitForChild('_stats').player.Value == plr then
                    table.insert(unitlist, v)
                end
            end
            if #unitlist == 4 then
                remote_use_active_attack:InvokeServer(unitlist[1])
                task.wait(delay)
                remote_use_active_attack:InvokeServer(unitlist[3])
                task.wait(delay)
                remote_use_active_attack:InvokeServer(unitlist[2])
                task.wait(delay)
                remote_use_active_attack:InvokeServer(unitlist[4])
                task.wait(delay)
            end
        end
    end
end
task.spawn(coroutine.wrap(auto_wenda))
local function auto_erwin()
    while task.wait() do
        if ui_farm_autounits_autoerwin_toggle.Value and not value_is_lobby.Value then
            local plr = Players.LocalPlayer
            local delay
            if ui_farm_autounits_autoerwinmanual_toggle.Value then
                delay = ui_farm_autounits_autoerwinmanual_slider.Value
            else
                if ui_farm_autounits_autoerwincurse_toggle.Value then
                    delay = 8
                else
                    delay = 15.4
                end
            end
            local unitlist = {}
            for _,v in pairs(workspace._UNITS:GetChildren()) do
                if v.Name == "erwin" and v:WaitForChild('_stats').player.Value == plr then
                    table.insert(unitlist, v)
                end
            end
            if #unitlist == 4 then
                remote_use_active_attack:InvokeServer(unitlist[1])
                task.wait(delay)
                remote_use_active_attack:InvokeServer(unitlist[3])
                task.wait(delay)
                remote_use_active_attack:InvokeServer(unitlist[2])
                task.wait(delay)
                remote_use_active_attack:InvokeServer(unitlist[4])
                task.wait(delay)
            end
        end
    end
end
task.spawn(coroutine.wrap(auto_erwin))

-- Auto Next Portal//
local function get_portals_by_id(id)
    local reg = getreg()
    local portals = {}
    for i,v in next, reg do
        if type(v) == 'function' then
            if getfenv(v).script then
                for _, v in pairs(debug.getupvalues(v)) do
                    if type(v) == 'table' then
                        if v["session"] then
                            for _, item in pairs(v["session"]["inventory"]['inventory_profile_data']['unique_items']) do
                                if item["item_id"]:match(id) then
                                    table.insert(portals, item)
                                end
                            end
                            return portals
                        end
                    end
                end
            end
        end
    end
end

local selected_portal = false
task.spawn(function()
    if value_game_finished then
        value_game_finished:GetPropertyChangedSignal("Value"):Connect(function()
            if value_game_finished.Value and ui_farm_settings_portals_autoportal_toggle.Value then
                task.wait(10)
                local portal_ignore_list = {}
                for z,b in pairs(ui_farm_settings_portals_tiers_dropdown.Value) do
                    portal_ignore_list[z] = ui_farm_settings_portals_ignoremods_dropdown.Value
                end
                for _,v in pairs(get_portals_by_id(ui_farm_settings_portals_portalid_input.Value)) do
                    for b,x in pairs(portal_ignore_list) do
                        if v['_unique_item_data']['_unique_portal_data']['portal_depth'] == tonumber(b) and not table.find(x, v['_unique_item_data']['_unique_portal_data']['challenge']) then
                            if selected_portal == false then
                                local args = {[1] = "replay",[2] = {["item_uuid"] = v["uuid"];}}
                                client_to_server_folder["set_game_finished_vote"]:InvokeServer(unpack(args))
                                selected_portal = true
                            end
                        end
                    end
                end
            end
        end)
    end
end)
--\\

-- MACRO PLAYING
local function get_unit_data_by_id(unit_id)
    for i,v in pairs(equipped_units) do
        if v["unit_id"] == unit_id then
            return v
        end
    end
end

local function get_unit_data_by_uuid(unit_uuid)
    for i,v in pairs(equipped_units) do
        local v_uuid = v["uuid"]
        if v_uuid == unit_uuid then
            return v
        end
    end
end

local macro_playing = false
local function Play_Macro()
    if game.PlaceId == 8304191830 then lib:Notify("You can't play macro in a lobby, dumbo.") return end
    if chosen_macro_contents == nil then lib:Notify("Choose a macro first.") return end
    if type(chosen_macro_contents) ~= "table" then lib:Notify("This macro is broken or empty.") return end
    if not value_game_started.Value then
        repeat task.wait() until value_game_started.Value
    end
    macro_playing = true
    local totalSteps = chosen_macro_contents[2]
    local stepTable = chosen_macro_contents[1]
    for i = 1, totalSteps do
        if not macro_playing then warn("MACRO_PLAYING = FALSE") break end
        --warn("task.wait")
        task.wait(getgenv().Options.macro_play_stepdelay_slider.Value + 0.3)
        local plr_stats = Players.LocalPlayer._stats
        local plr_resource_val = plr_stats.resource
        local cur_task = stepTable[""..i]["type"] or "?"
        --warn(i.."/"..totalSteps.." : "..tostring(cur_task))
        ui_macro_play_progress_label:SetText("Progress: "..i.."/"..totalSteps.."\nCurrent task: "..cur_task)
        if cur_task == "spawn_unit" then
            local spawn_unit = stepTable[""..i]["unit"]
            local unit_data = get_unit_data_by_id(spawn_unit)
            local spawn_cframe = string_to_cframe(stepTable[""..i]["cframe"])
            local spawn_cost = stepTable[""..i]["money"]
            ui_macro_play_progress_label:SetText("Progress: "..tostring(i).."/"..tostring(totalSteps).."\nCurrent task: "..tostring(cur_task).."\nUnit: "..tostring(stepTable[""..i]["unit"]))
            if plr_resource_val.Value < spawn_cost then
                ui_macro_play_progress_label:SetText("Progress: "..tostring(i).."/"..tostring(totalSteps).."\nCurrent task: "..tostring(cur_task).."\nUnit: "..tostring(stepTable[""..i]["unit"]).."\nWaiting for: "..tostring(spawn_cost).." Y")
                --warn("waiting for value")
                repeat task.wait() until plr_resource_val.Value >= spawn_cost
            end
            remote_place:InvokeServer(unit_data["uuid"], spawn_cframe)
        elseif cur_task == "upgrade_unit_ingame" then
            local unit_upgrade_cost
            local unit_pos = string_to_vector3(stepTable[""..i]["pos"])
            local unit_obj = nil
            ui_macro_play_progress_label:SetText("Progress: "..i.."/"..tostring(totalSteps).."\nCurrent task: "..tostring(cur_task).."\nUnit: "..tostring(unit_obj.Name).."\nTrying to find unit object.")
            repeat task.wait()
                for _, unit in pairs(workspace._UNITS:GetChildren()) do
                    --warn(unit.Name)
                    if unit:FindFirstChild("_hitbox") and unit:FindFirstChild("_stats") then
                        --warn(tostring((unit._hitbox.Position - unit_pos).Magnitude))
                        if (unit._hitbox.Position - unit_pos).Magnitude <= 2 and unit._stats.player.Value == Players.LocalPlayer then
                            unit_obj = unit
                        end
                    end
                end
            until unit_obj ~= nil
            if unit_obj then
                local unit_data = get_unit_data_by_id(unit_obj._stats.id.Value)
                for _,v in pairs(units_module) do
                    if v["id"] == unit_data["unit_id"] then
                        unit_upgrade_cost = v["upgrade"][unit_obj._stats.upgrade.Value + 1]["cost"]
                    end
                end
                ui_macro_play_progress_label:SetText("Progress: "..i.."/"..tostring(totalSteps).."\nCurrent task: "..tostring(cur_task).."\nUnit: "..tostring(unit_obj.Name))
                if plr_resource_val.Value < unit_upgrade_cost then
                    ui_macro_play_progress_label:SetText("Progress: "..i.."/"..tostring(totalSteps).."\nCurrent task: "..tostring(cur_task).."\nUnit: "..tostring(unit_obj.Name).."\nWaiting for: "..tostring(unit_upgrade_cost).." Y")
                    repeat task.wait() --[[warn("waiting for value")]] until plr_resource_val.Value >= unit_upgrade_cost
                end
                remote_upgrade_ingame:InvokeServer(unit_obj)
            else
                --warn("Ray, kak ti eto delaesh, zaebal")
            end
        elseif cur_task == "sell_unit_ingame" then
            local unit_pos = string_to_cframe(stepTable[""..i]["pos"])
            local unit_obj
            for _, unit in pairs(workspace._UNITS:GetChildren()) do
                if unit:FindFirstChild("_hitbox") and unit:FindFirstChild("_stats") then
                    if (unit._hitbox.Position - unit_pos.Position).Magnitude <= 1 and unit._stats.player.Value == Players.LocalPlayer then
                        unit_obj = unit
                    end
                end
            end
            ui_macro_play_progress_label:SetText("Progress: "..i.."/"..totalSteps.."\nCurrent task: "..cur_task.."\nUnit: "..unit_obj.Name)
            remote_sell_ingame:InvokeServer(unit_obj)
        end
    end
    macro_playing = false
    lib:Notify("Macro '"..getgenv().Options.current_macro_dropdown.Value.."' Completed.")
    ui_macro_play_progress_label:SetText("Progress: COMPLETED")
end
ui_macro_play_toggle:OnChanged(function()
    if getgenv().Toggles.macro_play_toggle.Value then
        Play_Macro()
    else
        macro_playing = false
    end
end)
-- MACRO RECORDING
local game_metatable = getrawmetatable(game)
local game_namecall = game_metatable.__namecall

local makewriteable
if setreadonly ~= nil then
    makewriteable = function() setreadonly(game_metatable, false) end
elseif make_writeable ~= nil then
    makewriteable = function() make_writeable(game_metatable) end
end
makewriteable()

local current_record_step = 1
local current_macro_record_data = {}
local last_record_state = false
ui_macro_record_toggle:OnChanged(function()
    if getgenv().Toggles.macro_record_toggle.Value == false then
        if not isfile("r1sIngHub"..[[\]].."Anime Adventures"..[[\]]..tostring(getgenv().Options.current_macro_dropdown.Value)..".json") or not getgenv().Options.current_macro_dropdown.Value then return end
        if last_record_state == false then return end
        local new_file_content = HttpService:JSONEncode(current_macro_record_data)
        writefile("r1sIngHub"..[[\]].."Anime Adventures"..[[\]]..getgenv().Options.current_macro_dropdown.Value..".json", new_file_content)
        last_record_state = false
    else
        if not getgenv().Options.current_macro_dropdown.Value then lib:Notify("Choose a macro first!") return end
        if not isfile("r1sIngHub"..[[\]].."Anime Adventures"..[[\]]..getgenv().Options.current_macro_dropdown.Value..".json") then
            getgenv().Options.current_macro_dropdown:SetValues()
            lib:Notify("File doesnt exist?")
            return
        end
        last_record_state = true
    end
end)
local on_namecall = function(object, ...)
    local args = {...}
    local method = tostring(getnamecallmethod())
    local isRemoteMethod = method == "FireServer" or method == "InvokeServer"
    if object.Name ~= "CharacterSoundEvent" and method:match("Server") and isRemoteMethod and ui_macro_record_toggle.Value and lib.Unloaded ~= true then
        if object.Name == "spawn_unit" then
            local unit_data = get_unit_data_by_uuid(args[1])
            local unit_cframe = args[2]
            local unit_cost
            for a,b in pairs(units_module) do
                if b["id"] == unit_data["unit_id"] then
                    unit_cost = b["cost"]
                end
            end
            current_macro_record_data[""..current_record_step] = {type = "spawn_unit", money = unit_cost, unit = unit_data["unit_id"], cframe = tostring(unit_cframe)}
            current_record_step += 1
        end
        if object.Name == "upgrade_unit_ingame" then
            local unit_obj = args[1]
            local unit_data = get_unit_data_by_id(unit_obj._stats.id.Value)
            local unit_upgrade_cost
            for i,v in pairs(units_module) do
                if v["id"] == unit_data["unit_id"] then
                    unit_upgrade_cost = v["upgrade"][unit_obj._stats.upgrade.Value + 1]["cost"]
                end
            end
            current_macro_record_data[""..current_record_step] = {type = "upgrade_unit_ingame", money = unit_upgrade_cost, pos = tostring(unit_obj._hitbox.Position)}
            current_record_step += 1
        end
        if object.Name == "sell_unit_ingame" then
            local unit_obj = args[1]
            local unit_pos = unit_obj._hitbox.CFrame
            current_macro_record_data[""..current_record_step] = {type = "sell_unit_ingame", pos = tostring(unit_pos)}
            current_record_step += 1
        end
    end
    return game_namecall(object, ...)
end
game_metatable.__namecall = on_namecall

--lib_SaveManager:SetLibrary(lib)
--lib_SaveManager:BuildConfigSection(ui_tabs.ui_settings)
--lib_SaveManager:LoadAutoloadConfig()
if type(getgenv().Options.current_macro_dropdown.Value) == "table" and getgenv().Options.current_macro_dropdown.Value ~= {} then
    chosen_macro_contents = {getgenv().Options.current_macro_dropdown.Value}
    local stepCount = 0
    for i,v in pairs(chosen_macro_contents[1]) do
        stepCount += 1
    end
    table.insert(chosen_macro_contents, stepCount)
end
-- Macro Finding//
if remote_get_level_data then
    local level_data = remote_get_level_data:InvokeServer()
    local level_type = nil
    if level_data._is_actual_storymode then
        level_type = "story"
    elseif level_data.is_raid then
        level_type = "raid"
    elseif level_data.portal_group then
        level_type = "portal"
    elseif level_data._gamemode == "infinite" then
        level_type = "infinite"
    elseif string.find(level_data.world, "legend") then
        level_type = "legend"
    end
    print(level_type)
    local macro_dropdown_string_map = "macro_map_"..tostring(level_type).."_"..tostring(level_data.map).."_dropdown"
    local macro_dropdown_string_id  = "macro_map_"..tostring(level_type).."_"..tostring(level_data.id).."_dropdown"
    if getgenv().Options[macro_dropdown_string_map] then
        warn("Found "..macro_dropdown_string_map)
        if getgenv().Options[macro_dropdown_string_map].Value and getgenv().Options[macro_dropdown_string_map].Value ~= "" then
            warn("Found "..macro_dropdown_string_map.." Macro")
            getgenv().Options.current_macro_dropdown:SetValue(getgenv().Options[macro_dropdown_string_map].Value)
        end
    elseif getgenv().Options[macro_dropdown_string_id] then
        warn("Found "..macro_dropdown_string_id)
        if getgenv().Options[macro_dropdown_string_id].Value and getgenv().Options[macro_dropdown_string_id].Value ~= "" then
            warn("Found "..macro_dropdown_string_id.." Macro")
            getgenv().Options.current_macro_dropdown:SetValue(getgenv().Options[macro_dropdown_string_id].Value)
        end
    end
end

task.spawn(function()
    if type(getgenv().Options.current_macro_dropdown.Value) == "string" and getgenv().Options.current_macro_dropdown.Value ~= "" and getgenv().Toggles.macro_play_toggle.Value then
        if value_game_started then
            if not value_game_started.Value then
                repeat task.wait() until value_game_started.Value
            end
        end
        task.wait(1)
        Play_Macro()
    end
end)

-- Misc//
local antiAfkConnection
task.spawn(function()
    antiAfkConnection = Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
    end)
end)
task.spawn(function()
    repeat task.wait(1) until lib.Unloaded
    antiAfkConnection:Disconnect()
end)
--\\

task.spawn(function()
    task.wait(5)
    for _, macro_dropdown in pairs(map_dropdowns) do
        macro_dropdown:OnChanged(function()
            if macro_dropdown.Value ~= false then
                Save_Configuration()
            end
        end)
    end
end)