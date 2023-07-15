local UiLib = require(game:HttpsGet("https://github.com/r1sIngisgood/r1sIngHub/UiLibs/Bracket.lua"))

local Window = UiLib:Window() do
    Window:ChangeName("r1sIngHub")
    Window:ChangeSize(UDim2.new(0,500,0,500))
    Window:ChangePosition(UDim2.new(0.5,0,0.5,0))
    local ScriptsTab = Window:Tab() do
        ScriptsTab:ChangeName("Scripts")
        ScriptsTab:Divider({Text = "Scripts", Side = "Left"})

        local DexButton = ScriptsTab:Button({Name = "Dex Explorer", Side = "Left", Callback = function()
            loadstring(game:HttpGet("https://github.com/r1sIngisgood/r1sIngHub/Scripts/DexExplorer.lua", true))()
        end})
        local RemoteSpy = ScriptsTab:Button({Name = "RemoteSpy", Side = "Left", Callback = function()
            loadstring(game:HttpGet("https://github.com/r1sIngisgood/r1sIngHub/Scripts/RemoteSpy.lua", true))()
        end})
    end
end