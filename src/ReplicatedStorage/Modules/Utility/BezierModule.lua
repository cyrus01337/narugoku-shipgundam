local BezierModule = {}

function BezierModule:lerp(a, b, c)
    return a + (b - a) * c
end

function BezierModule:quadBezier(t, p0, p1, p2)
    local l1 = BezierModule:lerp(p0, p1, t)
    local l2 = BezierModule:lerp(p1, p2, t)
    local quad = BezierModule:lerp(l1, l2, t)
    return quad
end

function BezierModule:cubicBezier(t, p0, p1, p2, p3)
    local l1 = BezierModule:lerp(p0, p1, t)
    local l2 = BezierModule:lerp(p1, p2, t)
    local l3 = BezierModule:lerp(p2, p3, t)
    local a = BezierModule:lerp(l1, l2, t)
    local b = BezierModule:lerp(l2, l3, t)
    local cubic = BezierModule:lerp(a, b, t)
    return cubic
end

return BezierModule
