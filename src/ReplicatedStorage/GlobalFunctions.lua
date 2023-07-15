--|| Services ||--
local Players = game:GetService("Players");

local Debris = game:GetService("Debris");
local RunService = game:GetService("RunService");
local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerScriptService = game:GetService("ServerScriptService");

--|| Directories ||--
local Modules = ReplicatedStorage.Modules;

local Metadata = Modules.Metadata;
local Utility = Modules.Utility;

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote;
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote;

local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote;
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote;

local GetKeyHeld = ReplicatedStorage.Remotes.GetKeyHeld;

--|| Variables ||--
local Player = Players.LocalPlayer;
local CurrentCamera = workspace.CurrentCamera

local function ConvertToVector(CF)
	return typeof(CF) == "CFrame" and CF.Position or CF
end

--|| Module ||--
local GlobalFunctions = {}

function GlobalFunctions.ReturnMouse(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	local Mouse = Player:GetMouse()
	Mouse.TargetFilter = workspace.World.Visuals
	return Mouse.Hit
end

function GlobalFunctions.Visualize(Orgin, Goal, Color)
	local StartPosition = ConvertToVector(Orgin)
	local EndPosition = ConvertToVector(Goal)
	local Distance = (EndPosition - StartPosition).Magnitude

	local Beam = Instance.new("Part")
	Beam.Material = Enum.Material.Neon
	Beam.Anchored = true
	Beam.Color = Color or Color3.fromRGB(255,255,255)
	Beam.Locked = true
	Beam.CanCollide = false
	Beam.Size = Vector3.new(0.1,0.1,Distance)
	Beam.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0,0,-Distance/2)
	Beam.Parent = workspace.World.Visuals

	Debris:AddItem(Beam,3)
end

function GlobalFunctions.CastRay(Orgin,Direction,List)
	table.insert(List,#List + 1,workspace.World.Visuals)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = List

	return workspace:Raycast(Orgin,Direction,raycastParams)
end

function GlobalFunctions.TweenFunction(ObjectData,InfoData)
	local Goal = {}

	for Index, Value in next, InfoData do
		Goal[Index] = InfoData[Index]
		Goal[Value] = InfoData[Value]
	end

	local Tween = TweenService:Create(ObjectData["Instance"],TweenInfo.new(ObjectData["Duration"],ObjectData["EasingStyle"],ObjectData["EasingDirection"],0,false,0),InfoData)
	Tween:Play()
	Tween:Destroy()
end

function GlobalFunctions.CheckDistance(Player,Distance)
	local Character = Player.Character or Player.CharacterAdded:Wait()

	local Range = Distance;
	if Range < (Character:FindFirstChild("HumanoidRootPart").CFrame.Position - CurrentCamera.CFrame.Position).Magnitude then
		return false
	end
	return true
end

function GlobalFunctions.GetMouseRay(Player,Distance)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local MousePosition = UserInputService:GetMouseLocation()

	local ViewPointMouse = CurrentCamera:ViewportPointToRay(MousePosition.X,MousePosition.Y)

	if UserInputService.TouchEnabled then
		ViewPointMouse = CurrentCamera:ViewportPointToRay(0.5,0.5)
	end

	local RaycastResult = Ray.new(ViewPointMouse.Origin,ViewPointMouse.Direction * Distance)
	local Part,Position = workspace:FindPartOnRayWithIgnoreList(RaycastResult,{Character,workspace.World.Visuals})

	return Position,Part,ViewPointMouse
end

function GlobalFunctions.GetNearPlayers(Character,Radius)
	local Table = {}
	local PlayerList = Players:GetPlayers()

	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

	for _,Player in ipairs(PlayerList) do
		local EnemyCharacter = Player.Character or Player.CharacterAdded:Wait();
		local EnemyRootPart = EnemyCharacter:FindFirstChild("HumanoidRootPart")

		if Character and EnemyCharacter and HumanoidRootPart and EnemyRootPart then
			if (EnemyRootPart.Position - HumanoidRootPart.Position).Magnitude <= Radius and EnemyCharacter then
				Table[#Table + 1] = Player
			end
		end

	end
	return Table
end

function GlobalFunctions.FreshShake(Number,Divide,Minece,Lerp) -- Numb/Divide = 20,15
	local Minece = Minece or 1
	local Lerp = Lerp or .2

	coroutine.resume(coroutine.create(function()
		for Index = Number,0,-Minece do
			local X,Y = math.random(-Index,Index) / Divide,math.random(-Index,Index) / Divide
			CurrentCamera.CoordinateFrame = CurrentCamera.CoordinateFrame:Lerp(CurrentCamera.CoordinateFrame * CFrame.new(X,Y,0),Lerp)
			RunService.RenderStepped:wait()
		end
	end))
end

function GlobalFunctions.GetKeyHeld(Player,Key,Type)
	local Result = GetKeyHeld:InvokeClient(Player,Key,Type)
	if Result then
		return true or false
	end
end;

function GlobalFunctions.NewInstance(ObjectInstance, Data, Duration)
	local NewInstance = Instance.new(ObjectInstance)
	if Data then
		for Property, Value in next, Data do
			NewInstance[Property] = Value
		end
	end
	if Duration then
		Debris:AddItem(NewInstance,Duration)
	end
	return NewInstance
end

function GlobalFunctions.IsAlive(Model)
	if Model and Model.PrimaryPart
		and Model:FindFirstChild("Humanoid")
		and Model.Humanoid:IsDescendantOf(workspace.World.Live)
		and Model.Humanoid.Health > 0 then
		return true
	end
	return false
end

function GlobalFunctions.GetGraphics()
	local UU = UserSettings().GameSettings.SavedQualityLevel.Value 
	UU = 11 -UU
	if UU > 3 and UU < 7 then
		UU = UU -2.5
	end                 
	return UU 
end

return GlobalFunctions