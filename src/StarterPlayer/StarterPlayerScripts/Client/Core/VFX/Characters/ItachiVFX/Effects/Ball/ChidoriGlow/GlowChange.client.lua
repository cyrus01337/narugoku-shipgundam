local A = script.Parent
local B = math.random(10, 16)
local TweenService = game:GetService("TweenService")
local Info = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
local Goals = { Range = B, Brightness = 0 }
local tween = TweenService:Create(A, Info, Goals)
tween:Play()
A.Enabled = true
wait(0.6)
A:Destroy()
