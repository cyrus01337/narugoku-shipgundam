while script.Disabled == false do
    local A = script.Parent
    local B = script.ChidoriGlow:Clone()
    B.Parent = A.Attachment
    B.GlowChange.Disabled = false
    wait(0.2)
end
