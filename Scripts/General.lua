print(_G.Valyse == identifyexecutor())
if type(_G.Valyse) ~= "boolean" then _G.Valyse = identifyexecutor() == "Valyse v1" end 
local localPlayer = game:GetService("Players").LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngLib/main/Library.lua"))()
local MainWindow = UILib:NewWindow("r1sIngHub")
local HomeLib = MainWindow:GetHomeLib()
if not _G.Valyse then
    HomeLib:AddText("Valyse is recommended to use with this script. Some funcitions may crash/not work.")
end

local PlayerTab = MainWindow:NewTab("Player")
local PlayerDivider = PlayerTab:NewDivider("Movement")

local infJumpConnection = nil
local function infJumpToggle(infJumpState)
    if infJumpState then
        infJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
            localPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end)
    else
        infJumpConnection:Disconnect()
    end
end
local InfJumpToggle = PlayerTab:NewToggle("Infinite Jump", infJumpToggle)

local GeneralTab = MainWindow:NewTab("General")

local MainDivider = GeneralTab:NewDivider("Useful stuff")
local antiAfkConnection = nil
local function antiAfkToggle(toggleState)
    if toggleState then
        antiAfkConnection = localPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
        end)
    else
        antiAfkConnection:Disconnect()
    end
end
local antiAfkToggle = GeneralTab:NewToggle("Anti Afk", antiAfkToggle)
local DexExplorerButton = GeneralTab:NewButton("Dex Explorer", function()
     loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/DexExplorer.lua"))()
end)
local RemoteSpyButton = GeneralTab:NewButton("Remote Spy", function()
     loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/RemoteSpy.lua"))()
end)