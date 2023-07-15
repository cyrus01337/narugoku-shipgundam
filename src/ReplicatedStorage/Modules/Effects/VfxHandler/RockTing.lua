--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Tween1 = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.World.Map}
raycastParams.FilterType = Enum.RaycastFilterType.Include

return function(Cframe,Size)
	if Cframe then
		
		local RockFolder = Instance.new("Folder")
		RockFolder.Name = "RockFolder"
		RockFolder.Parent = workspace.World.Visuals

		Debris:AddItem(RockFolder,4)
		
		for Index = 1,24 do
			--// math
			local radius = 10
			local Size2 = (Size + (math.random(5,7)/10))
			local Theta = math.rad(Index * 15)
			local x,z =  math.cos(Theta) * radius,math.sin(Theta) * radius
			x,z = Cframe.p.X + x, Cframe.p.Z + z
			local ax,ay,az = math.rad(math.random(1,12) * 30),math.rad(math.random(1,12) * 30),math.rad(math.random(1,12) * 30)
			local a2x,a2y,a2z = math.rad(math.random(1,12) * 30),math.rad(math.random(1,12) * 30),math.rad(math.random(1,12) * 30)
			local r1 = Vector3.new(x,Cframe.p.Y,z)
			local r2 = Cframe.upVector * -200

			local results = workspace:Raycast(r1,r2,raycastParams)
			if results and results.Instance and (results.Position - r1).Magnitude < 50 then
				coroutine.resume(coroutine.create(function()
					wait(1/23)
					local c1 = results.Position + Vector3.new(0, - (Size2 + .2), 0)
					local c2 = results.Position
					
					local Part = Instance.new("Part")
					Part.Material = results.Instance.Material
					Part.Color = results.Instance.Color
					Part.Size = Vector3.new(Size2,Size2,Size2)
					Part.CanCollide = false
					Part.Anchored = true

					Part.Parent = RockFolder

					local Tween = TweenService:Create(Part,Tween1,{CFrame = CFrame.new(c2) * CFrame.Angles(a2x,a2y,a2z)})
					Tween:Play()
					Tween:Destroy()

					Debris:AddItem(Part,4)

					wait(3.8-((Index / 19) * 2))
					local Tween = TweenService:Create(Part,Tween1,{CFrame = CFrame.new(c1) * CFrame.Angles(ax,ay,az),Transparency = 1})
					Tween:Play()
					Tween:Destroy()
				end))
			end
		end
	end
end
