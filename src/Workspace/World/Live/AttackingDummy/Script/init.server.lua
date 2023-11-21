--|| Services ||--
local Players = game:GetService("Players")

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Directories ||--
local CombatAnims = ReplicatedStorage.Assets.Animations.Shared.Combat.L

local Server = ServerScriptService.Server
local Modules = ReplicatedStorage.Modules

local Shared = Modules.Shared
local Utility = Modules.Utility
local Effects = Modules.Effects

--|| Modules ||--
local StateManager = require(Shared.StateManager)
local SoundManager = require(Shared.SoundManager)

local HitboxModule = require(Server.Combat.Combat.HitboxModule)
local DamageManager = require(script.DamageManager)

--|| Variables ||--
local Character = script.Parent

local Humanoid, Root = Character:FindFirstChild("Humanoid"), Character:FindFirstChild("HumanoidRootPart")

--|| Debounces ||--
local Combo = 0

while true do
    if not StateManager:Peek(Character, "Stunned") then
        Combo += 1

        Humanoid:LoadAnimation(CombatAnims["CombatL" .. Combo]):Play()

        -- SoundManager:AddSound("CombatSwing", {Parent = Root, Volume = .75}, "Client")

        local HitResult, HitObject = HitboxModule.MagnitudeModule(
            Character,
            { Range = 5, KeysLogged = Combo, Type = "Combat" },
            "Swing",
            "Killer Queen",
            false
        )
        if HitResult then
            local Victim = HitObject.Parent
            local VRoot, VHum = Victim:FindFirstChild("HumanoidRootPart"), Victim:FindFirstChild("Humanoid")

            DamageManager.DeductDamage(Character, Victim, "ThirdAbility", "Natsu", Combo)
        end

        if Combo >= 5 then
            Combo = 1
            StateManager:ChangeState(Character, "Stunned", 2)
        end
    end
    wait(0.35)
end
