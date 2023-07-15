--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

return function(Data)
	local Circle = Data.Circle or false
	local Sphere = Data.Sphere or false
	if Circle then
		coroutine.wrap(function()
			for Index = 1,Data.Amount do
				local Clone = ReplicatedStorage.Assets.Effects.Meshes.HitPart2:Clone()
				
				Clone.Rotation = Data.Rotation or Clone.Rotation
				Clone.Color = Data.Color or Color3.fromRGB(255,255,255)
				Clone.Transparency = .25
				Clone.Material = Data.Material or Enum.Material.Neon
				Clone.Size =  Data.Size or Vector3.new(.3,.3, 2)
				Clone.CFrame = CFrame.new(Data.Parent.Position + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)),Data.Parent.Position) 
				Clone.Parent = workspace.World.Visuals

				Debris:AddItem(Clone,Data.Speed)
				
				local ColorIndex = Index >= 5 and Data.Type == "Yes" and Color3.fromRGB(255,96,33) or Data.Color or Color3.fromRGB(255,255,255)
				
				Clone.Color = ColorIndex
				
				local Tween = TweenService:Create(Clone, TweenInfo.new(Data.Speed or .5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0,  false), {["CFrame"] = Clone.CFrame * Data.Cframe or CFrame.new(0,0,5),Size = Clone.Size + Vector3.new(0,0,math.random(1.8,3.5))})
				Tween:Play()
				Tween:Destroy()

				local EndTween = TweenService:Create(Clone,TweenInfo.new(Data.Speed or .5,Enum.EasingStyle.Cubic,Enum.EasingDirection.In,0,false),{["Size"] = Vector3.new(0,0,.8),["Transparency"] = 1})
				EndTween:Play()
				EndTween:Destroy()
			end
		end)()
	end

	if Sphere then
		coroutine.wrap(function()
			for Index = 1,Data.Amount do
				local Clone = ReplicatedStorage.Assets.Effects.Meshes.HitPart1:Clone()
				
				Clone.Rotation = Data.Rotation or Clone.Rotation
				Clone.Color = Data.Color or Color3.fromRGB(255,255,255)
				Clone.Transparency = .25		
				Clone.Size =  Data.Size or Vector3.new(.2, .3, 3.79)
				Clone.CFrame = CFrame.new(Data.Parent.Position + Vector3.new(math.random(-1,1),math.random(-1,1),math.random(-1,1)),Data.Parent.Position) 
				Clone.Parent = workspace.World.Visuals

				Debris:AddItem(Clone,Data.Speed)

				local Tween = TweenService:Create(Clone, TweenInfo.new(Data.Speed or .5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0,  false), {["CFrame"] = Clone.CFrame * Data.Cframe or CFrame.new(0,0,5),Size = Clone.Size + Vector3.new(0,0,math.random(1.8,3.5))})
				Tween:Play()
				Tween:Destroy()

				local EndTween = TweenService:Create(Clone,TweenInfo.new(Data.Speed or .5,Enum.EasingStyle.Cubic,Enum.EasingDirection.In,0,false),{["Size"] = Vector3.new(0,0,.8),["Transparency"] = 1})
				EndTween:Play()
				EndTween:Destroy()
			end
		end)()
	end
end
