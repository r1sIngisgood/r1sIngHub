repeat task.wait() until game:IsLoaded()
if game.GameId ~= 4871329703 then return end

--Services//
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--\\

--Game Stuff//
local entityFolder = workspace.Entities
local animationIdList = {
    Weapons = {
        --Base katana
        "rbxassetid://14070072624",
        "rbxassetid://14070073772",
        "rbxassetid://14070074688",
        "rbxassetid://14070075681",
        "rbxassetid://14070076756",
        "rbxassetid://14070060393", --Crit

    },
    Misc = {
        "rbxassetid://14072096953",
        "rbxassetid://14079307927",
        "rbxassetid://14070070713", --unsheathe
        "rbxassetid://14068932670",
        "rbxassetid://14068962412",
        "rbxassetid://14068875327",
        "rbxassetid://14068827633",
        "rbxassetid://14070065324",
        "rbxassetid://14070071816",
        "rbxassetid://14070085241", -- running with katana/weapon
        "rbxassetid://14072131995",
        "rbxassetid://14072133845",
        "rbxassetid://14068941037",
        "http://www.roblox.com/asset/?id=180436334", -- Roblox climbing
    },
}
--Remotes/

--\

--\\

local localPlayer = Players.LocalPlayer

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua"))()
local lib_SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/addons/SaveManager.lua"))()
local Window = lib:CreateWindow({Title = "r1sIngHub", Center = true, AutoShow = true})
local Tabs = {
    Main = Window:AddTab("Main"),
    UI_Settings = Window:AddTab("UI Settings")
}
local UI_Settings_UITabbox = Tabs.UI_Settings:AddLeftTabbox()
local UI_Settings_UITabbox_Tabs = {
    UI = UI_Settings_UITabbox:AddTab("UI Settings")
}

UI_Settings_UITabbox_Tabs.UI:AddButton("Unload", function() lib:Unload() end)
UI_Settings_UITabbox_Tabs.UI:AddLabel("UI Keybind"):AddKeyPicker("MenuKeybind", {Default = "End", NoUI = true, Text = "UI Keybind"})
lib.ToggleKeybind = getgenv().Options.MenuKeybind

local main_lefttabbox = Tabs.Main:AddLeftTabbox()
local main_lefttabbox_tabs = {
    AutoParry = main_lefttabbox:AddTab("Auto Parry")
}
main_lefttabbox_tabs.AutoParry:AddToggle("APToggle", {Text = "Enable", Default = false, Tooltip = "Enables Auto Parry"})
main_lefttabbox_tabs.AutoParry:AddInput("APDelayInput", {
    Default = 0.25,
    Numeric = true,
    Finished = true,
    Text = "Auto Parry Delay",
    Tooltip = "Enter a number and press ENTER (Default is 0.25)",
    Placeholder = "0.25"
})
main_lefttabbox_tabs.AutoParry:AddInput("APRangeInput", {
    Default = 9.5,
    Numeric = true,
    Finished = true,
    Text = "Auto Parry Range",
    Tooltip = "Enter a number and press ENTER (Default is 9.5)",
    Placeholder = "9.5"
})
main_lefttabbox_tabs.AutoParry:AddInput("APHoldInput", {
    Default = 0.35,
    Numeric = true,
    Finished = true,
    Text = "Auto Parry Hold",
    Tooltip = "Enter a number and press ENTER (Default is 0.35)",
    Placeholder = "0.35"
})

local function getDistanceFromPlayer(obj)
    return localPlayer:DistanceFromCharacter(obj.Position)
end

local currentBlockState = false
local currentAPConnections = {}
local function Parry()
    if not localPlayer.Character then return end
    local char = localPlayer.Character
    local AP_HOLD = getgenv().Options.APHoldInput.Value
    if currentBlockState then
        char.CharacterHandler.Remotes.Block:FireServer("Released")
        currentBlockState = false
        task.wait(0.01)
        char.CharacterHandler.Remotes.Block:FireServer("Pressed")
        currentBlockState = true
        task.wait(AP_HOLD)
        char.CharacterHandler.Remotes.Block:FireServer("Released")
        currentBlockState = false
    else
        local char = localPlayer.Character
        local AP_HOLD = getgenv().Options.APHoldInput.Value
        char.CharacterHandler.Remotes.Block:FireServer("Pressed")
        currentBlockState = true
        task.wait(AP_HOLD)
        char.CharacterHandler.Remotes.Block:FireServer("Released")
        currentBlockState = false
    end
end
local function initAP()
    for _, entity in pairs(entityFolder:GetChildren()) do
        if entity ~= localPlayer.Character then
            if entity:FindFirstChildOfClass("Humanoid") then
                local entityHumanoid = entity.Humanoid
                local entityAnimator = entityHumanoid:FindFirstChildOfClass("Animator")
                if not entityAnimator then return end
                currentAPConnections[tostring(entity).."AnimationPlayed"] = entityAnimator.AnimationPlayed:Connect(function(animTrack)
                    local anim = animTrack.Animation
                    local animId = anim.AnimationId
                    if not entity:FindFirstChildOfClass("Part") or not entity:FindFirstChild("HumanoidRootPart") then return end
                    if table.find(animationIdList.Misc, animId) then return end
                    if getDistanceFromPlayer(entity.HumanoidRootPart) > tonumber(getgenv().Options.APRangeInput.Value) then return end
                    local HitFrameTime
                    pcall(function()
                        HitFrameTime = animTrack:GetTimeOfKeyframe("HitFrame")
                    end)
                    if type(HitFrameTime) ~= "number" then
                        return
                    end

                    local waitTime = HitFrameTime - animTrack.TimePosition - getgenv().Options.APDelayInput.Value
                    --print("Waiting "..waitTime.." seconds to parry "..entity.Name.."'s attack.")
                    print(HitFrameTime.." - "..animTrack.TimePosition.." - "..getgenv().Options.APDelayInput.Value)
                    task.wait(waitTime)

                    Parry()
                end)
            end
        end
    end
end
local function clearAPConnections()
    for _, entity in pairs(entityFolder:GetChildren()) do
        local AnimationPlayedCon = currentAPConnections[tostring(entity).."AnimationPlayed"]
        if AnimationPlayedCon then
            AnimationPlayedCon:Disconnect()
            currentAPConnections[tostring(entity).."AnimationPlayed"] = nil
        end
    end
end

getgenv().Toggles.APToggle:OnChanged(function()
    if getgenv().Toggles.APToggle.Value then
        initAP()
    else
        clearAPConnections()
    end
end)

lib_SaveManager:SetLibrary(lib)
lib_SaveManager:BuildConfigSection(Tabs.UI_Settings)
lib_SaveManager:LoadAutoloadConfig()