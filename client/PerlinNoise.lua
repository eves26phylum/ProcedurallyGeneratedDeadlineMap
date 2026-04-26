local perlinNoise = {}
local function FUCKROBLOX(a)
    if math.floor(a) == a then
        return a + 0.001
    end
    return a
end
function perlinNoise:generate(scale, resolution, offset)
    assert(scale, "scale is missing")
    assert(resolution, "resolution is missing")
    local offset = offset or Vector2.new(0, 0)
    local resultArray = {}
    for x = 0, resolution.X do
        for y = 0, resolution.Y do
            local offsetX = x + offset.X
            local offsetY = y + offset.Y
            local computed_noise = math.noise(FUCKROBLOX(offsetX / scale), FUCKROBLOX(offsetY / scale))
            local clamped_noise = (computed_noise / 2 + 0.5)
            table.insert(resultArray, clamped_noise)
        end
    end
    return resultArray
end

return perlinNoise