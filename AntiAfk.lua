local LocalPlayer = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
end)

