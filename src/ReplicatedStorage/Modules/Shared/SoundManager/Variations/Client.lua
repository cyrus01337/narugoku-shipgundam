--|| Services ||--
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

return function(Table, SoundName, SoundProperties, RemoteData)
    if not Table[SoundName] then
        warn(SoundName .. " not found")
        return
    end

    local Sound = Table[SoundName]:Clone()
    if SoundProperties then
        for Property, Value in next, SoundProperties do
            Sound[Property] = Value
        end
    end
    Sound:Play()
    if not SoundProperties.Looped then
        local Connection
        Connection = Sound.Ended:Connect(function()
            Sound:Destroy()
            Connection:Disconnect()
            Connection = nil
        end)
    elseif SoundProperties.Looped then
        if not RemoteData and RemoteData.Duration then
            return
        end
        Debris:AddItem(Sound, RemoteData.Duration)
    end
    if SoundProperties.Playing then
        coroutine.wrap(function()
            wait(Sound.TimeLength - RemoteData.ExectueTween)

            local SoundTween = TweenService:Create(
                Sound,
                TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                { ["Volume"] = 0 }
            )
            SoundTween:Play()
            SoundTween:Destroy()

            SoundTween.Completed:Wait()
            Sound:Destroy()
        end)()
    end
    return Sound
end
