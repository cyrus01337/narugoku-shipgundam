repeat wait() until game.Players.LocalPlayer.Character ~= nil

function died()
script.Parent.ImageLabel.Visible = true
for i = 1,100 do
script.Parent.Frame.BackgroundTransparency = script.Parent.Frame.BackgroundTransparency - 0.01
script.Parent.uuhhh:Play()
script.Parent.uuhhh.Playing = script.Parent.uuhhh.Playing - 0.01
script.Parent.ImageLabel.Size = script.Parent.ImageLabel.Size + UDim2.new(0.01, 0, 0.01, 0)
script.Parent.ImageLabel.Position = script.Parent.ImageLabel.Position - UDim2.new(0.005, 0, 0.005, 0)
script.Parent.ImageLabel.BackgroundTransparency = script.Parent.ImageLabel.BackgroundTransparency - 0.005
wait()
end
end

game.Players.LocalPlayer.Character.Humanoid.Died:connect(died)