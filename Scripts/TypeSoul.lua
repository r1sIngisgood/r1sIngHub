repeat task.wait() until game:IsLoaded()

local defaultConfig = {["APState"] = false, ["APRange"] = 9.79, ["APDelay"] = 0.275}
getgenv().config = defaultConfig

local Players = game:GetService("Players")
local localPlayer = game:GetService("Players").LocalPlayer
local entityFolder = workspace.Entities

local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngLib/main/Library.lua"))()
local MainWindow = UILib:NewWindow("r1sIngHub")

local TypeSoulTab = MainWindow:NewTab("Type Soul")
local APDivider = TypeSoulTab:NewDivider("Auto Parry")

local WeaponAnimations = {
    --Base katana
    "rbxassetid://14070072624", 
    "rbxassetid://14070073772",
    "rbxassetid://14070074688",
    "rbxassetid://14070075681",
    "rbxassetid://14070076756",
    "rbxassetid://14070060393", --Crit

    --Greatsword
    "rbxassetid://14070072624",
    "rbxassetid://14070072624",
    "rbxassetid://14070072624",
    "rbxassetid://14070072624",
    "rbxassetid://14070072624",

    --Hollows
}
local WeaponDelays = {
    --Base Katana
    ["rbxassetid://14070072624"] = 0.25,
    ["rbxassetid://14070073772"] = 0.25,
    ["rbxassetid://14070074688"] = 0.25,
    ["rbxassetid://14070075681"] = 0.25,
    ["rbxassetid://14070076756"] = 0.25,
    ["rbxassetid://14070060393"] = 0.25, --crit

    --Greatsword
    
}
local otherAnimations = {
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
    "http://www.roblox.com/asset/?id=180436334",
}

local localPlayerCharacter = localPlayer.Character
local currentBlockState = false
local AP_HOLD_TIME = 0.2
local APConnections = {}
local function APToggled(toggleState)
    if toggleState then
        APConnections.localPlayerCharacterAdded = localPlayer.CharacterAdded:Connect(function(newCharacter)
            localPlayerCharacter = newCharacter
        end)
        for _, entity in pairs(entityFolder:GetChildren()) do
            print(entity.Name)
            if entity:FindFirstChildOfClass("Humanoid") and not(entity == localPlayerCharacter) then
                local entityHumanoid = entity.Humanoid
                local entityAnimator = entityHumanoid:FindFirstChildOfClass("Animator")
                APConnections[tostring(entity).."AnimationPlayed"] = entityAnimator.AnimationPlayed:Connect(function(animTrack)
                    local animation = animTrack.Animation
                    local animationId = animation.AnimationId
                    if table.find(WeaponAnimations, animationId) then
                        if not entity:FindFirstChild("HumanoidRootPart") then return end
                        print("BLOCKING "..entity.Name)
                        if localPlayer:DistanceFromCharacter(entity.HumanoidRootPart.Position) <= getgenv().config.APRange then
                            task.spawn(function()
                                task.wait(getgenv().config.APDelay)
                                if currentBlockState then
                                    localPlayerCharacter.CharacterHandler.Remotes.Block:FireServer("Released")
                                    currentBlockState = false
                                    task.wait(0.01)
                                    localPlayerCharacter.CharacterHandler.Remotes.Block:FireServer("Pressed")
                                    currentBlockState = true
                                    task.wait(AP_HOLD_TIME)
                                    localPlayerCharacter.CharacterHandler.Remotes.Block:FireServer("Released")
                                    currentBlockState = false
                                else
                                    localPlayerCharacter.CharacterHandler.Remotes.Block:FireServer("Pressed")
                                    currentBlockState = true
                                    task.wait(AP_HOLD_TIME)
                                    localPlayerCharacter.CharacterHandler.Remotes.Block:FireServer("Released")
                                    currentBlockState = false
                                end
                            end)
                        end
                    end
                end)
            end
        end
        APConnections.EntityRemoved = entityFolder.ChildRemoved:Connect(function(child)
            print(child.Name)
            if APConnections[tostring(child).."AnimationPlayed"] then
                APConnections[tostring(child).."AnimationPlayed"]:Disconnect()
                APConnections[tostring(child).."AnimationPlayed"] = nil
            end
        end)
        APConnections.EntityAdded = entityFolder.ChildAdded:Connect(function(child)
            print(child.Name)
            if child:FindFirstChildOfClass("Humanoid") and not(child == localPlayerCharacter) then
                local childHumanoid = child.Humanoid
                local childAnimator = childHumanoid:FindFirstChildOfClass("Animator")
                APConnections[tostring(child).."AnimationPlayed"] = childAnimator.AnimationPlayed:Connect(function(animTrack)
                    local animation = animTrack.Animation
                    local animationId = animation.AnimationId
                    if table.find(WeaponAnimations, animationId) then
                        print("BLOCKING "..child.Name)
                        if (child.HumanoidRootPart.Position - localPlayerCharacter.HumanoidRootPart.Position).Magnitude <= getgenv().config.APRange then
                            task.spawn(function()
                                task.wait(getgenv().config.APDelay + WeaponDelays[animationId])
                                if currentBlockState then
                                    localPlayerCharacter.CharacterHandler.Remotes.Block:FireServer("Released")
                                    currentBlockState = false
                                    task.wait(0.01)
                                    localPlayerCharacter.CharacterHandler.Remotes.Block:FireServer("Pressed")
                                    currentBlockState = true
                                    task.wait(AP_HOLD_TIME)
                                    localPlayerCharacter.CharacterHandler.Remotes.Block:FireServer("Released")
                                    currentBlockState = false
                                else
                                    localPlayerCharacter.CharacterHandler.Remotes.Block:FireServer("Pressed")
                                    currentBlockState = true
                                    task.wait(AP_HOLD_TIME)
                                    localPlayerCharacter.CharacterHandler.Remotes.Block:FireServer("Released")
                                    currentBlockState = false
                                end
                            end)
                        end
                    end
                end)
            end
        end)
    else
        for _, entity in pairs(entityFolder:GetChildren()) do
            local animationPlayedCon = APConnections[tostring(entity).."AnimationPlayed"]
            if animationPlayedCon then
                animationPlayedCon:Disconnect()
                APConnections[tostring(entity).."AnimationPlayed"] = nil
            end
        end
    end
end
local APState = getgenv().config.APState or false
local APToggle = TypeSoulTab:NewToggle("Auto Parry", APToggled, APState)

local playerId = localPlayer.UserId
if playerId == 3959041870 then
    local devDivider = TypeSoulTab:NewDivider("DEV")

    local grabOnlyMyAnims = false
    local devGrabConnections = {}
    local function animGrabToggle(toggleState)
        if toggleState then
            devGrabConnections.localPlayerCharacterAdded = localPlayer.CharacterAdded:Connect(function(newCharacter)
                localPlayerCharacter = newCharacter
            end)
            for _, entity in pairs(entityFolder:GetChildren()) do
                if not entity:FindFirstChildOfClass("Humanoid") or not entity:IsA("Model") then return end
                local entitiyHumanoid = entity.Humanoid
                local entityAnimator = entitiyHumanoid:FindFirstChildOfClass("Animator")
                devGrabConnections[tostring(entity).."AnimationPlayed"] = entityAnimator.AnimationPlayed:Connect(function(animTrack)
                    local animation = animTrack.Animation
                    local animationId = animation.AnimationId
                    if grabOnlyMyAnims and entity == localPlayerCharacter and not table.find(WeaponAnimations, animationId) and not table.find(otherAnimations, animationId) then
                        print(entity.Name.." - "..animationId)
                    elseif not grabOnlyMyAnims and not table.find(WeaponAnimations, animationId) and not table.find(otherAnimations, animationId) then
                        print(entity.Name.." - "..animationId)
                    end
                end)
            end
            devGrabConnections.EntityRemoved = entityFolder.ChildRemoved:Connect(function(child)
                if devGrabConnections[tostring(child).."AnimationPlayed"] then
                    devGrabConnections[tostring(child).."AnimationPlayed"]:Disconnect()
                    devGrabConnections[tostring(child).."AnimationPlayed"] = nil
                end
            end)
            devGrabConnections.EntityAdded = entityFolder.ChildAdded:Connect(function(child)
                if not child:FindFirstChildOfClass("Humanoid") or not child:IsA("Model") or not child:FindFirstChild("HumanoidRootPart") then return end
                local childHumanoid = child.Humanoid
                local childAnimator = childHumanoid:FindFirstChildOfClass("Animator")
                devGrabConnections[tostring(child).."AnimationPlayed"] = childAnimator.AnimationPlayed:Connect(function(animTrack)
                    local animation = animTrack.Animation
                    local animationId = animation.AnimationId
                    if grabOnlyMyAnims and child == localPlayerCharacter and not table.find(WeaponAnimations, animationId) and not table.find(otherAnimations, animationId) then
                        print(child.Name.." - "..animationId)
                    elseif not grabOnlyMyAnims and not table.find(WeaponAnimations, animationId) and not table.find(otherAnimations, animationId) then
                        print(child.Name.." - "..animationId)
                    end
                end)
            end)
        else
            for _, entity in pairs(entityFolder:GetChildren()) do
                local animationPlayedCon = devGrabConnections[tostring(entity).."AnimationPlayed"]
                if animationPlayedCon then
                    animationPlayedCon:Disconnect()
                    devGrabConnections[tostring(entity).."AnimationPlayed"] = nil
                end
            end
        end
    end
    local devAnimToggle = TypeSoulTab:NewToggle("Animation Grabber", animGrabToggle)
    
    local function grabOnlyMeToggled(toggleState)
        if toggleState then
            grabOnlyMyAnims = true
        else
            grabOnlyMyAnims = false
        end
    end
    local grabOnlyMeToggle = TypeSoulTab:NewToggle("Grab only my animations", grabOnlyMeToggled)
end