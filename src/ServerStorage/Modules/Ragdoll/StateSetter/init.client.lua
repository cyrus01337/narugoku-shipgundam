local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
local Temp = script:WaitForChild("Ended").Value

workspace.CurrentCamera.CameraSubject = Character.Head

while script.Ended.Value == false do
	if Humanoid.Health <= 0 then
		break
	end
	game["Run Service"].Heartbeat:wait()
end
print("wat")

script.RemoteEvent:FireServer()
workspace.CurrentCamera.CameraSubject = Humanoid

Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)