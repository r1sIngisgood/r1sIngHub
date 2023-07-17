local placeId = game.PlaceId
local gameTable = {}

local gameFile = gameTable[placeId]
if type(gameFile) == "string" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/"..gameFile))
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/General.lua"))()
end

