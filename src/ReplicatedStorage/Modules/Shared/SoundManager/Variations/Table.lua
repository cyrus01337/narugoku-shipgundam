--|| Services ||--
local RunService = game:GetService("RunService")

function FastWait(Duration)
    Duration = Duration or 1 / 60
    local StartTime = os.clock()
    while os.clock() - StartTime < Duration do
        RunService.Stepped:Wait()
    end
end

return function(Table, SoundName, SoundProperties, RemoteData)
    local Music = SoundName

    local TableSound = Table["Music"]:Clone()
    TableSound.Volume = SoundProperties.Volume
    TableSound.Parent = SoundProperties.Parent

    if TableSound then
        while true do
            for i = 1, #Music do
                TableSound.SoundId = "rbxassetid://" .. Music[i]
                FastWait(1)
                TableSound:Play()
                FastWait(TableSound.TimeLength)
            end
        end
    end

    return TableSound
end
