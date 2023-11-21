--|| Services ||--
local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local Server = ServerScriptService.Server

local Managers = Server.Managers

local Modules = ReplicatedStorage.Modules
local State = Server.State

local Effects = Modules.Effects
local Shared = Modules.Shared
local Metadata = Modules.Metadata
local Utility = Modules.Utility

--|| Imports ||--
local ProfileService = require(Server.ProfileService)

local GlobalFunctions = require(ReplicatedStorage.GlobalFunctions)

local HitboxModule = require(Server.Combat.Combat.HitboxModule)

local AbilityData = require(Metadata.AbilityData.AbilityData)

local DebounceManager = require(State.DebounceManager)

local NetworkStream = require(Utility.NetworkStream)
local TaskScheduler = require(Utility.TaskScheduler)

local StateManager = require(Shared.StateManager)
local SpeedManager = require(Shared.StateManager.Speed)
local SoundManager = require(Shared.SoundManager)

local RaycastManager = require(Shared.RaycastManager)

local DamageManager = require(Managers.DamageManager)

local VfxHandler = require(Effects.VfxHandler)

local Ragdoll = require(ServerStorage.Modules.Ragdoll)

--|| Remotes ||--
local ClientRemote = ReplicatedStorage.Remotes.ClientRemote
local ServerRemote = ReplicatedStorage.Remotes.ServerRemote

local MouseRemote = ReplicatedStorage.Remotes.GetMouse
local AnimationRemote = ReplicatedStorage.Remotes.AnimationRemote
local CameraRemote = ReplicatedStorage.Remotes.CameraRemote
local GUIRemote = ReplicatedStorage.Remotes.GUIRemote

--|| Functions ||--
local Trash = {}

local function RemoveTrash(Trash)
    for Index = 1, #Trash do
        local Item = Trash[Index]
        if Item and Item.Parent then
            Item:Destroy()
        end
    end
end

local function GetNearPlayers(Character, Radius)
    local ChosenVictim
    local Live = workspace.World.Live

    local HumanoidRootPart = Character.PrimaryPart

    for _, Victim in ipairs(Live:GetChildren()) do
        if Victim:FindFirstChild("Humanoid") and Victim.Humanoid.Health > 0 then
            local EnemyRootPart = Victim:FindFirstChild("PrimaryPart") or Victim:FindFirstChild("HumanoidRootPart")

            if (EnemyRootPart.Position - HumanoidRootPart.Position).Magnitude <= Radius then
                if Victim ~= Character then
                    ChosenVictim = Victim
                end
            end
        end
    end
    return ChosenVictim
end

local function RaycastTarget(Radius, Character)
    local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

    local Root = Character:FindFirstChild("HumanoidRootPart")

    local RayParam = RaycastParams.new()
    RayParam.FilterDescendantsInstances = { Character, workspace.World.Visuals }
    RayParam.FilterType = Enum.RaycastFilterType.Exclude

    local RaycastResult = workspace:Raycast(Root.Position, (MouseHit.Position - Root.Position).Unit * Radius, RayParam)
        or {}
    local Target, Position = RaycastResult.Instance, RaycastResult.Position

    if Target and Target:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid") then
        local Victim = Target:FindFirstAncestorWhichIsA("Model")
        if Victim ~= Character then
            return Victim, Position or nil
        end
    end
end

local function GetMouseTarget(Target, Character)
    local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

    local Root = Character:FindFirstChild("HumanoidRootPart")
    if (Root.Position - MouseHit.Position).Magnitude > 80 then
        return
    end

    if
        Target
        and Target:IsA("BasePart")
        and not Target:IsDescendantOf(Character)
        and GlobalFunctions.IsAlive(Target.Parent)
    then
        return Target.Parent or nil
    end
end

local function GetNearestFromMouse(Character, Range)
    local MouseHit = MouseRemote:InvokeClient(Players:GetPlayerFromCharacter(Character))

    for _, Entity in ipairs(workspace.World.Live:GetChildren()) do
        if Entity:IsA("Model") and GlobalFunctions.IsAlive(Entity) and Entity ~= Character then
            local EntityPrimary = Entity:FindFirstChild("HumanoidRootPart")
            local Distance = (MouseHit.Position - EntityPrimary.Position).Magnitude

            if Distance <= Range then
                return Entity or nil
            end
        end
    end
end

local KilluaMode = {

    ["Transformation"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        local Data = ProfileService:GetPlayerProfile(Player)

        Root.Anchored = true
        NetworkStream.FireClientDistance(
            Character,
            "ClientRemote",
            350,
            { Character = Character, Module = Data.Character .. "Mode", Function = "Transformation" }
        )

        CameraRemote:FireClient(
            Player,
            "CameraShake",
            { FirstText = 7, SecondText = 5, ThirdText = 0.1, FourthText = 3.8 }
        )

        local CreateFrameData = {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Color = Color3.fromRGB(110, 153, 202),
            Duration = 1,
        }

        SpeedManager.changeSpeed(Character, 0, 3, 2)
        CameraRemote:FireClient(Player, "ModeCamera", {
            Character = Character,

            StartingCFrame = Root.CFrame * CFrame.new(0, 0, 5),
            Duration = 1,
        })

        TaskScheduler:AddTask(1.425, function()
            -- SoundManager:AddSound("LightningExplosion2", {Parent = Root}, "Client")

            CameraRemote:FireClient(Player, "CreateFlashUI", CreateFrameData)
            CameraRemote:FireClient(
                Player,
                "CameraShake",
                { FirstText = 15, SecondText = 4, ThirdText = 0.1, FourthText = 1 }
            )

            Root.Anchored = false
        end)
    end,

    ["FirstAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        --[[local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local Victim = GetNearestFromMouse(Character,20) ---GetMouseTarget(ExtraData.MouseTarget, Character) or GetNearPlayers(Character,35)
		if not Victim then return end
		
		local VRoot = Victim:FindFirstChild("HumanoidRootPart")
		
		local UnitVector = (Root.Position - VRoot.Position).Unit
		local VictimLook = VRoot.CFrame.LookVector
		local DotVector = UnitVector:Dot(VictimLook)

		if StateManager:Peek(Victim,"Blocking") and DotVector >= -.5 then 
			NetworkStream.FireClientDistance(Character,"ClientRemote",150,{
				Character = Character,
				Victim = Victim,
				WeaponType = "Combat",
				Module = "CombatVFX",
				Function = "Block"
			}) 
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
			return 
		end	
		StateManager:ChangeState(Character,"Attacking",1.5)
		
		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
		
		AnimationRemote:FireClient(Player, "LightningPalm", "Play", {AdjustSpeed = .125})
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KilluaVFX", Function = "LightningPalmStart"})

		SpeedManager.changeSpeed(Character,4,2,1.5) --function(Character,Speed,Duration,Priority)

		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KilluaVFX", Function = "LightningDash", ContactPointCFrame = Root.CFrame})

		Root.CFrame = VRoot.CFrame * CFrame.new(0,0,3)

		Humanoid.AutoRotate = false

		wait(.315)
		if StateManager:Peek(Character,"Stunned") then
			AnimationRemote:FireClient(Player, "LightningPalm", "Stop")
			Humanoid.AutoRotate = true
			return 
		end

		AnimationRemote:FireClient(Player, "LightningPalm", "Play", {AdjustSpeed = 5})

		coroutine.resume(coroutine.create(function()
			wait(.3)
			CameraRemote:FireClient(Player, "CameraShake", {FirstText = 8, SecondText = 10})
			NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KilluaVFX", Function = "LightningPalmAOE"})

			local HitResult,HitObject = HitboxModule.MagnitudeModule(Character, {Range = 10, KeysLogged = 1, Type = "Combat"}, KeyData.SerializedKey, CharacterName)
			if HitResult then
				local Victim = HitObject.Parent 
				local VRoot,VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

				Humanoid.AutoRotate = true

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.new(4e4,4e4,4e4);
				BodyVelocity.Velocity = CFrame.new(Root.Position,Root.Position + (Root.CFrame.lookVector * 10) + (Root.CFrame.upVector * -10) ).lookVector * 100
				BodyVelocity.Parent = VRoot
				Debris:AddItem(BodyVelocity,.25)

				Ragdoll.DurationRagdoll(Victim,1)
			end
			Humanoid.AutoRotate = true
		end))]]
    end,

    ["SecondAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        --[[local Character = Player.Character
		local Root,Humanoid = Character:FindFirstChild("HumanoidRootPart"),Character:FindFirstChild("Humanoid")

		local MouseHit = MouseRemote:InvokeClient(Player)	
		
		local Victim,Position = RaycastTarget(100,Character)
		if not Victim then return end
		local VHumanoid,VRoot = Victim:FindFirstChild("Humanoid"),Victim:FindFirstChild("HumanoidRootPart")
		
		local UnitVector = (Root.Position - VRoot.Position).Unit
		local VictimLook = VRoot.CFrame.LookVector
		local DotVector = UnitVector:Dot(VictimLook)

		if StateManager:Peek(Victim,"Blocking") and DotVector >= -.5 then 
			NetworkStream.FireClientDistance(Character,"ClientRemote",150,{
				Character = Character,
				Victim = Victim,
				WeaponType = "Combat",
				Module = "CombatVFX",
				Function = "Block"
			}) 
			DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName)
			CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
			return 
		end	
		
		Root.CFrame = CFrame.new(Position)
		Root.Anchored = true
		VRoot.Anchored = true

		local Base = Position + Vector3.new(0,20,0)
		NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KilluaVFX", Function = "WhirlWindRelease"})

		for Index = 1,9 do
			local RandomCalculation = math.random(1,2)

			local RandomIndex = RandomCalculation == 1 and -1 or 1
			RandomCalculation = RandomIndex

			DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Combat", KeysLogged = math.random(1,3)})

			local Yincrement = math.random(2,5) * Index
			if Index == 9 then Yincrement = Yincrement + 20 end
			VRoot.CFrame = CFrame.new(Base + Vector3.new(math.random(20,30) * RandomCalculation, Yincrement, math.random(20,30) * RandomCalculation))
			--
			local Beam = ReplicatedStorage.Assets.Effects.Meshes.Whirldwindball:Clone()
			Beam.BrickColor = BrickColor.new("Pastel light blue")
			Beam.Shape = "Cylinder"	
			Beam.CanCollide = false
			Beam.Anchored = true
			Beam.Material = "Neon"					
			local End = (Root.CFrame.Position - VRoot.CFrame.Position).Magnitude 
			Beam.Size = Vector3.new(End, 5, 5)
			Beam.CFrame = CFrame.new(Root.CFrame.Position, VRoot.CFrame.Position) * CFrame.new(0,0,-End / 2) * CFrame.fromEulerAnglesXYZ(0,math.rad(90),0)
			Beam.Parent = workspace.World.Visuals

			Debris:AddItem(Beam, .25)
			GlobalFunctions.TweenFunction({["Instance"] = Beam,["EasingStyle"] = Enum.EasingStyle.Quad,["EasingDirection"] = Enum.EasingDirection.Out,["Duration"] = .25,},{["Size"] = Vector3.new(End,0,0)})

			Root.CFrame = VRoot.CFrame * CFrame.new(0,0,-2)
			wait(.15)
		end
		VfxHandler.FaceVictim({Character = Victim, Victim = Character})
		
		AnimationRemote:FireClient(Player,"GodspeedRush","Stop")
		AnimationRemote:FireClient(Player,"CombatAerial3","Play")
		Root.Anchored = false
		
		TaskScheduler:AddTask(.35,function()
			VRoot.Anchored = false
		end)

		GlobalFunctions.NewInstance("BoolValue",{Parent = Character, Name = "Aiming"},.375)

		TaskScheduler:AddTask(.35,function()
			local MouseHit = MouseRemote:InvokeClient(Player)

			local SecondRaycast = Ray.new(Root.Position,(-Root.CFrame.upVector * 50) + (Root.CFrame.lookVector * 50))
			local Target,Position = workspace:FindPartnRayWithIgnoreList(SecondRaycast, {Character, workspace.World.Visuals}, false, false)
			if Target and Target:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid") then
				local VHum = Target:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid")
				if VHum.Parent ~= Character then
					Target,Position = workspace:FindartOnRayWithIgoreList(SecondRaycast, {Character, workspace.World.Visuals, VHum.Parent}, false, false)
				end
			end	

			local BodyPosition = Instance.new("BodyPosition") 
			BodyPosition.MaxForce = Vector3.new(100000,100000,100000)
			BodyPosition.Position = Position
			BodyPosition.P = 1000
			BodyPosition.D = 100
			BodyPosition.Parent = VRoot
			Debris:AddItem(BodyPosition, .5)				

			local Debounce = false
			coroutine.wrap(function()
				for Index = 1,10 do
					wait(.05)
					if (VRoot.Position - Position).Magnitude <= 5 and not Debounce then

						DamageManager.DeductDamage(Character,Victim,KeyData.SerializedKey,CharacterName,{Type = "Combat", KeysLogged = math.random(1,3)})

						local CreateFrameData = {Size = UDim2.new(1,0,1,0); Position = UDim2.new(0,0,0,0); Color = Color3.fromRGB(110, 153, 202); Duration = 1}
						CameraRemote:FireClient(Player,"CreateFlashUI",CreateFrameData)

						NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Character, Module = "KilluaVFX", Function = "WhirlWindHit", ContactPointCFrame = VRoot})
						Debounce = true
					end	
				end
			end)()

			local Connection; Connection = Victim["Torso"].Touched:Connect(function(Hit)
				if Hit then
					if (not Hit:IsDescendantOf(Character)) and (not Hit:IsDescendantOf(workspace.World.Visuals)) then								
						NetworkStream.FireClientDistance(Character,"ClientRemote",200,{Character = Victim, Module = "KilluaVFX", Function = "WhirldWindSlam", ContactPointCFrame = VRoot.CFrame})
						-- SoundManager:AddSound("BOOM!",{Parent = Root, Volume = 1}, "Client")
						
						_ = Players:GetPlayerFromCharacter(Victim) and AnimationRemote:FireClient(Players:GetPlayerFromCharacter(Victim),"SlamDown","Play") or VHumanoid:LoadAnimation(ReplicatedStorage.Assets.Animations.Shared.Misc.SlamDown):Play()
					end
					Connection = Connection and Connection:Disconnect(); Connection = nil
				else
					Connection:Disconnect()
					Connection = nil
				end
			end)
		end)	

		CameraRemote:FireClient(Player, "ChangeUICooldown",{Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName})
		DebounceManager.SetDebounce(Character,KeyData.SerializedKey,CharacterName) ]]
    end,

    ["ThirdAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        print("here killua mode third ability")

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,

    ["FourthAbility"] = function(Player, CharacterName, KeyData, MoveData, ExtraData)
        local Character = Player.Character
        local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")

        print("here killua mode fourth ability")

        CameraRemote:FireClient(
            Player,
            "ChangeUICooldown",
            { Cooldown = MoveData.Cooldown, Key = KeyData.SerializedKey, ToolName = CharacterName }
        )
        DebounceManager.SetDebounce(Character, KeyData.SerializedKey, CharacterName)
    end,
}

return KilluaMode
