--||Services||--
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

--||Directories||--
local Maps = workspace.World.Map

local Modules = ReplicatedStorage.Modules
local Remotes = ReplicatedStorage.Remotes

local Metadata = Modules.Metadata
local Utility = Modules.Utility

--||Imports||--
local SpatialPresets = require(script.SpatialPresets)
local TableUtility = require(Utility.Utility)

--||Remotes||--

local ClientRemote = Remotes.ClientRemote
local ServerRemote = Remotes.ServerRemote

--||Variables||--
local MAP_SIZE = Maps.Model.BetterBasePlates.Size

local CONVERSION_RATE = SpatialPresets.CONVERSION_RATE

local MIN_CELL_SIZE = SpatialPresets.MIN_CELL_SIZE
local MIN_CELL_DISTANCE = SpatialPresets.MIN_CELL_DISTANCE

--||Module||--
local SpatialManager = {}

function SpatialManager.CreateGrid()
    local X_SIZE = MAP_SIZE.X
    local Z_SIZE = MAP_SIZE.Z

    local CONVERT_XSIZE_TO_CELL = math.floor(X_SIZE * CONVERSION_RATE)
    local CONVERT_ZSIZE_TO_CELL = math.floor(Z_SIZE * CONVERSION_RATE)

    local Cells = table.create(CONVERT_XSIZE_TO_CELL + 1)

    print(CONVERT_XSIZE_TO_CELL, CONVERT_ZSIZE_TO_CELL)
    --for
    for X = 1, CONVERT_XSIZE_TO_CELL do
        Cells[X] = table.create(CONVERT_ZSIZE_TO_CELL + 1)
        for Z = 1, CONVERT_ZSIZE_TO_CELL do
            Cells[X][Z] = Vector3.new(X, 0, Z)
        end
    end

    --Debugging
    for Index, Cell in pairs(Cells) do
        for _, Vector in pairs(Cell) do
            if typeof(Vector) == "Vector3" then
                local Part = Instance.new("Part")
                Part.Position = Vector
                Part.Anchored = true
                Part.Parent = workspace
            end
        end
    end
end

return SpatialManager
