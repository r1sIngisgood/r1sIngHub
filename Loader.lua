local UiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Bracket/main/BracketV32.lua"))()

print("1")
local Window = UiLib:Window({Name = "r1sIngHub",Enabled = true,Color = Color3.new(1,0.5,0.25),Size = UDim2.new(0,496,0,496),Position = UDim2.new(0.5,-248,0.5,-248)})

local ScriptsTab = Window:Tab({Name = "Scripts"})

local DexButton = ScriptsTab:Button({Name = "Dex Explorer", Side = "Left", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/DexExplorer.lua", true))()
end})

local RemoteSpy = ScriptsTab:Button({Name = "RemoteSpy", Side = "Left", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/RemoteSpy.lua", true))()
end})