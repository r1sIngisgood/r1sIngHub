local placeId = game.PlaceId
local gameTable = {}

local gameFile = gameTable[placeId]
if identifyexecutor() ~= "Valyse v1" then warn("It's recommended to use Valyse for this script. Some functions may crash/not work") else print("VALYSE CARRIES") end
if type(gameFile) == "string" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/"..gameFile))
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/General.lua"))()
end

