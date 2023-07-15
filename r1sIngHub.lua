local UiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/UiLibs/Bracket.lua"))()

local Window = UiLib:Window({Name = "Window",Enabled = true,Color = Color3.new(1,0.5,0.25),Size = UDim2.new(0,496,0,496),Position = UDim2.new(0.5,-248,0.5,-248)})
Window:ChangeName("r1sIngHub")
Window:ChangeSize(UDim2.new(0,500,0,500))
Window:ChangePosition(UDim2.new(0.5,0,0.5,0))

local ScriptsTab = Window:Tab()
 ScriptsTab:ChangeName("Scripts")
ScriptsTab:Divider({Text = "Scripts", Side = "Left"})

local DexButton = ScriptsTab:Button({Name = "Dex Explorer", Side = "Left", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/DexExplorer.lua", true))()
end})

local RemoteSpy = ScriptsTab:Button({Name = "RemoteSpy", Side = "Left", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/RemoteSpy.lua", true))()
end})