return function(Table, SoundName, SoundProperties, RemoteData)
    local SoundId = SoundName

    local Sound = Instance.new("Sound")
    if SoundProperties then
        for Property, Value in next, SoundProperties do
            Sound[Property] = Value
        end
    end
    Sound.SoundId = "rbxassetid://" .. SoundId
    Sound:Play()
    Sound.Parent = SoundProperties and SoundProperties.Parent and SoundProperties.Parent or workspace
    Table[SoundName] = Sound

    local Connection
    Connection = Sound.Ended:Connect(function()
        Connection = Connection and Connection:Disconnect()
        Sound:Destroy()
    end)

    return Sound
end
