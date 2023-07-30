
repeat task.wait() until game:IsLoaded()
if not isfolder("r1sIngHub") then makefolder("r1sIngHub") end
if not isfolder("r1sIngHub/Anime Adventures") then makefolder("r1sIngHub/Anime Adventures") end

-- UI//
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local lib_SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()
local ui_window = lib:CreateWindow({Title = "r1sIngHub", Center = true, AutoShow = true})
local ui_tabs = {
    macro = ui_window:AddTab("Macro"),
    ui_settings = ui_window:AddTab("UI Settings")
}
local ui_settings_lefttabbox = ui_tabs.ui_settings:AddLeftTabbox()
local ui_settings_lefttabbox_ui = ui_settings_lefttabbox:AddTab("UI Settings")
ui_settings_lefttabbox_ui:AddButton("Unload", function() lib:Unload() end)
ui_settings_lefttabbox_ui:AddLabel("UI Keybind"):AddKeyPicker("MenuKeybind", {Default = "End", NoUI = true, Text = "UI Keybind"})
lib.ToggleKeybind = getgenv().Options.MenuKeybind
--//

-- Services//
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
--\\

-- Game Stuff//
local client_to_server_folder = ReplicatedStorage.endpoints["client_to_server"]
--\\

-- Misc Functions//
local function checkJSON(str)
    local result = pcall(function()
        HttpService:JSONDecode(str)
    end)
    return result
end
--\\

-- Macro //
local filelist = listfiles("r1sIngHub"..[[\]].."Anime Adventures")
local macro_list = {}
local chosen_macro_contents
local function cfgbeautify(str) return string.gsub(string.gsub(str,"r1sIngHub"..[[\]].."Anime Adventures"..[[\]],""),".json","") end
local function isdotjson(file) return string.sub(file, -5) == ".json" end
print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-")
for _,file in ipairs(filelist) do
    local cfgname = cfgbeautify(file)
    if isdotjson(file) then
        table.insert(macro_list, cfgname)
    else
        lib:Notify(cfgname.." is not a json file and wasnt loaded.")
    end
end

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
end,DoubleClick = false,Tooltip = "Updates macro dropdown if you manually added/removed any"})

local ui_macro_delete_button = ui_macro_leftgroupbox:AddButton({Text = "Delete Selected Macro",
Func = function()
    delfile("r1sIngHub"..[[\]].."Anime Adventures"..[[\]]..getgenv().Options.current_macro_dropdown.Value..".json")
    table.remove(getgenv().Options.current_macro_dropdown.Values, table.find(getgenv().Options.current_macro_dropdown.Values,getgenv().Options.current_macro_dropdown.Value))
    getgenv().Options.current_macro_dropdown:SetValues()
    getgenv().Options.current_macro_dropdown:SetValue()
end, DoubleClick = false,Tooltip = "Delete's selected macro"})

local ui_macro_divider1 = ui_macro_leftgroupbox:AddDivider()
local ui_macro_label1 = ui_macro_leftgroupbox:AddLabel("Macro")
local ui_macro_play_toggle = ui_macro_leftgroupbox:AddToggle("macro_play_toggle", {Text = "Play Macro", Default = false, Tooltip = "Plays macro, dumbass"})
local ui_macro_play_stepdelay = ui_macro_leftgroupbox:AddSlider("macro_play_stepdelay_slider", {Text = "Step Delay", Default = 0.1, Min = 0.1, Max = 1, Rounding = 2, Compact = false, HideMax = false})
local ui_macro_play_progress_label = ui_macro_leftgroupbox:AddLabel("", true)
local ui_macro_divider2 = ui_macro_leftgroupbox:AddDivider()
local ui_macro_label2 = ui_macro_leftgroupbox:AddLabel("Macro Record")
local ui_macro_record_toggle = ui_macro_leftgroupbox:AddToggle("macro_record_toggle", {Text = "Enable", Default = false, Tooltip = "Enables Macro Record"})

local function Choose_Macro(macro_name)
    if type(macro_name) ~= "string" then return end
    if not isfile("r1sIngHub/Anime Adventures/"..macro_name..".json") then
        getgenv().Options.current_macro_dropdown:SetValues()
        return
    end
    local macro_file_contents = readfile("r1sIngHub/Anime Adventures/"..macro_name..".json")
    if checkJSON(macro_file_contents) then
        chosen_macro_contents = {HttpService:JSONDecode(readfile("r1sIngHub/Anime Adventures/"..macro_name..".json"))}
        local stepCount = 0
        for i,v in pairs(chosen_macro_contents[1]) do
            stepCount += 1
        end
        table.insert(chosen_macro_contents, stepCount)
    else
        chosen_macro_contents = ""
        lib:Notify("This macro is empty (or broken). Just letting you know.")
    end
end
ui_macro_choosemacro:OnChanged(function()
    Choose_Macro(getgenv().Options.current_macro_dropdown.Value)
end)

local function Create_Macro(macro_name)
    if type(macro_name) ~= "string" then return end
    if not isfile("r1sIngHub/Anime Adventures/"..macro_name..".json") then
        writefile("r1sIngHub/Anime Adventures/"..macro_name..".json", "")
        table.insert(getgenv().Options.current_macro_dropdown.Values, macro_name)
        getgenv().Options.current_macro_dropdown:SetValues()
        getgenv().Options.current_macro_dropdown:SetValue(macro_name)
    end
end
ui_create_macro_input:OnChanged(function()
    if getgenv().Options.macro_create_input.Value == "" or not getgenv().Options.macro_create_input.Value then return end
    Create_Macro(getgenv().Options.macro_create_input.Value)
end)

-- MACRO PLAYING
local macro_playing = false
ui_macro_play_toggle:OnChanged(function()
    if getgenv().Toggles.macro_play_toggle.Value then
        if chosen_macro_contents == nil then lib:Notify("Choose a macro first.") return end
        if type(chosen_macro_contents) ~= "table" then lib:Notify("This macro is broken or empty.") return end
        macro_playing = true
        task.spawn(function()
            local totalSteps = chosen_macro_contents[2]
            local stepTable = chosen_macro_contents[1]
            for i = 1, totalSteps do
                if not macro_playing then break end
                task.wait(getgenv().Options.macro_play_stepdelay_slider.Value)
                local cur_task = stepTable[""..i]["type"] or "?"
                ui_macro_play_progress_label:SetText("Progress: "..i.."/"..totalSteps.."\nCurrent task: "..cur_task)
                for n, step in pairs(stepTable[""..i]) do
                    print(i..": "..step)
                end
                print("-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=")
            end
            macro_playing = false
            getgenv().Toggles.macro_play_toggle:SetValue(false)
            lib:Notify("Macro '"..getgenv().Options.current_macro_dropdown.Value.."' Completed.")
        end)
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


local HasSpecial = function(string)
    return (string:match("%c") or string:match("%s") or string:match("%p") or tonumber(string:sub(1,1))) ~= nil
end

local GetPath = function(Instance)
	local Obj = Instance
	local string = {}
	local temp = {}
	local error = false
	
	while Obj ~= game do
		if Obj == nil then
			error = true
			break
		end
		table.insert(temp, Obj.Parent == game and Obj.ClassName or tostring(Obj))
		Obj = Obj.Parent
	end
	
	table.insert(string, "game:GetService(\"" .. temp[#temp] .. "\")")
	
	for i = #temp - 1, 1, -1 do
		table.insert(string, HasSpecial(temp[i]) and "[\"" .. temp[i] .. "\"]" or "." .. temp[i])
	end

	return (error and "nil -- Path contained invalid instance" or table.concat(string, ""))
end

local on_namecall = function(object, ...)
    local method = tostring(getnamecallmethod())
    local isRemoteMethod = method == "FireServer" or method == "InvokeServer"
    local args = {...}
    if object.Name ~= "CharacterSoundEvent" and method:match("Server") and isRemoteMethod and getgenv().Toggles.macro_record_toggle.Value then
        --warn("REMOTE EVENT CATCH: "..object.Name.." \n FIRED EVENT: "..tostring(GetPath(object)))

    end
    return game_namecall(object, ...)
end
game_metatable.__namecall = on_namecall

lib_SaveManager:SetLibrary(lib)
lib_SaveManager:BuildConfigSection(ui_tabs.ui_settings)
lib_SaveManager:LoadAutoloadConfig()
if type(getgenv().Options.current_macro_dropdown.Value) == "table" and getgenv().Options.current_macro_dropdown.Value ~= {} then
    chosen_macro_contents = {getgenv().Options.current_macro_dropdown.Value}
    local stepCount = 0
    for i,v in pairs(chosen_macro_contents[1]) do
        stepCount += 1
    end
    table.insert(chosen_macro_contents, stepCount)
end
--//

-- Misc//

--\\
--"1":{"money":550,"type":"spawn_unit","cframe":"-35.0240707, 65.4000015, 97.2440033, 1, 0, -0, -0, 1, -0, 0, 0, 1","unit":"speedwagon"}