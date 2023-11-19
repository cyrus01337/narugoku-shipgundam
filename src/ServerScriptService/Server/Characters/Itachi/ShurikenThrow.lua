--|| Services ||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--|| Directories ||--
local Server = ServerScriptService.Server

local Managers = Server.Managers

--|| Variables ||--
local MouseRemote = ReplicatedStorage.Remotes.GetMouse

local StatesManager = require(ReplicatedStorage.Modules.Shared.StateManager)
local SoundManager = require(ReplicatedStorage.Modules.Shared.SoundManager)

local NetworkStream = require(ReplicatedStorage.Modules.Utility.NetworkStream)

local DamageManager = require(Managers.DamageManager)

local module = {}

local function RaycastFunction(StartPosition, EndPosition, Distance, Object)
    local RayParam = RaycastParams.new()
    RayParam.FilterDescendantsInstances = { workspace.World.Visuals, Object }
    RayParam.FilterType = Enum.RaycastFilterType.Exclude

    local RayCast = workspace:Raycast(
        StartPosition,
        CFrame.new(StartPosition, EndPosition).LookVector * Distance,
        RayParam
    ) or {}
    local Target, Position, Surface = RayCast.Instance, RayCast.Position, RayCast.Normal

    return Target, Position, Surface
end

function module.Activate(Character, Position, Spread, Target, ExtraData)
    local Root, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
    if not Position then
        return
    end

    local Player = Players:GetPlayerFromCharacter(Character)
    local Distance = 8
    local SPREAD = CFrame.Angles(math.rad(math.random(-Spread, Spread)), math.rad(math.random(-Spread, Spread)), 0)
        * CFrame.new(0, 0, -2)

    for Index = 1, 1 do
        local Position = MouseRemote:InvokeClient(Player)

        local Shuriken = script.Kunai:Clone()
        Shuriken.CFrame = CFrame.new(Root.Position, Position.p) * SPREAD
        if Target then
            Position = Target.Position
        end
        Shuriken.CFrame = Shuriken.CFrame * CFrame.new(0, 0, -3.25)
        Shuriken.Parent = workspace.World.Visuals

        Debris:AddItem(Shuriken, 10)

        coroutine.wrap(function()
            for Index = 1, 40 do
                RunService.Heartbeat:Wait()
                local Hit, Position, Surface = RaycastFunction(
                    Shuriken.Position,
                    Shuriken.CFrame * CFrame.new(0, 0, -Distance).p,
                    Distance,
                    workspace.World.Visuals
                )
                if Hit and Hit.Anchored and Hit.Transparency ~= 1 then
                    if Hit.Material == Enum.Material.Wood or Hit.Material == Enum.Material.WoodPlanks then
                        Shuriken.CFrame = CFrame.new(Position, Position + Shuriken.CFrame.lookVector)
                        Shuriken.Wood:Play()
                        Shuriken.Anchored = true
                        break
                    elseif
                        Hit.Material == Enum.Material.Slate
                        or Hit.Material == Enum.Material.Cobblestone
                        or Hit.Material == Enum.Material.Brick
                        or Hit.Material == Enum.Material.Pebble
                        or Hit.Material == Enum.Material.Concrete
                    then
                        Shuriken.Stone:Play()
                        Shuriken.CFrame = CFrame.new(Position, Position + Shuriken.CFrame.lookVector)
                        Shuriken.Anchored = true
                        break
                    elseif Hit.Material == Enum.Material.Grass then
                        Shuriken.Grass:Play()
                        Shuriken.CFrame = CFrame.new(Position, Position + Shuriken.CFrame.lookVector)
                        Shuriken.Anchored = true
                        break
                    end
                    Debris:AddItem(Shuriken.Trail, 1)
                elseif
                    Hit
                    and Hit.Parent ~= Character
                    and (Hit.Parent:findFirstChild("Humanoid") or Hit.Parent.Parent:findFirstChild("Humanoid"))
                then
                    local Victim = Hit.Parent:findFirstChild("Humanoid") or Hit.Parent.Parent:findFirstChild("Humanoid")
                    Shuriken.CFrame = CFrame.new(Position, Position + Shuriken.CFrame.lookVector)
                    -- delay(.1,function()	SoundManager:AddSound("ShurikenHit",{Parent = Shuriken, Volume = 5, Pitch = math.random(14,15) / 10}, "Client") end)
                    ---- SoundManager:AddSound("ClinkSound",{Parent = Shuriken, Volume = 5, Pitch = math.random(14,15) / 10}, "Client")
                    Shuriken.Trail:Destroy()

                    local VictimCharacter = Victim.Parent
                    DamageManager.DeductDamage(
                        Character,
                        VictimCharacter,
                        ExtraData.KeyData.SerializedKey,
                        ExtraData.CharacterName,
                        { Type = "Combat", KeysLogged = math.random(1, 3) }
                    )
                    NetworkStream.FireClientDistance(
                        Character,
                        "ClientRemote",
                        80,
                        { Character = VictimCharacter, Module = "SasukeVFX", Function = "ShurikenHit" }
                    )

                    Shuriken.Size = Vector3.new(0, 10, 0)

                    local Weld = Instance.new("Weld")
                    Weld.Part1 = Shuriken
                    Weld.Part0 = Hit
                    Weld.Parent = Shuriken
                    Shuriken.Anchored = false
                    break
                else
                    Shuriken.CFrame = Shuriken.CFrame * CFrame.new(0, 0, -Distance)
                    if Index == 40 then
                        Debris:AddItem(Shuriken, 1)
                    end
                end
            end
        end)()
    end
end

return module
