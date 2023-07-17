local placeId = game.PlaceId
local gameTable = {}

local scriptString = "https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/"
if not gameTable[placeId] then
    scriptString = scriptString.."General.lua"
else
    scriptString = scriptString..gameTable[placeId]
end

loadstring(game:HttpGet(scriptString))()