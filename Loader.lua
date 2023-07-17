local placeId = game.PlaceId
local gameTable = {}

local githubURL = "https://raw.githubusercontent.com/r1sIngisgood/r1sIngHub/main/Scripts/"
local scriptString = ""
local gameFile = gameTable[placeId]
if type(gameFile) == "string" then
    scriptString = githubURL..gameTable[placeId]
else
    scriptString = githubURL.."General.lua"
end

loadstring(game:HttpGet(scriptString))()