_G.Valyse = identifyexecutor() == "Valyse v1"
local placeId = game.PlaceId
local gameTable = {[14070029709] = "TypeSoul.lua"}

local gameFile = gameTable[placeId]
if type(gameFile) == "string" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/"..gameFile))
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/General.lua"))()
end

