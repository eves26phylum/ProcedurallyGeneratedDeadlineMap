local perlinNoise = {}
local function FUCKROBLOX(a)
    if math.floor(a) == a then
        return a + 0.001
    end
    return a
end
function perlinNoise:generate(scale, resolution, offset, exaggeratedness, lacunarity, persistence, octaves, POWER)
    assert(scale, "scale is missing")
    assert(resolution, "resolution is missing")
    assert(exaggeratedness, "exaggeratedness is missing")
    assert(lacunarity, "lacunarity is missing")
    assert(persistence, "persistence is missing")
    assert(octaves, "octaves is missing")
    assert(POWER, "POWER is missing")
    local offset = offset or Vector2.new(0, 0)
    local noiseMap = {}
    local minRaw, maxRaw = math.huge, -math.huge
    for x = 0, resolution.X do
        for y = 0, resolution.Y do
            local offsetX = x + offset.X
            local offsetY = y + offset.Y

            local frequency = 1
            local amplitude = 1
            local noiseHeight = 0

            for i = 1, octaves do
                local sampleX = offsetX / scale * frequency
                local sampleY = offsetY / scale * frequency
                local computed_noise = math.noise(FUCKROBLOX(sampleX), FUCKROBLOX(sampleY))
                local clamped_noise = (computed_noise / 2 + 0.5)
                noiseHeight += clamped_noise * amplitude
                amplitude *= persistence
                frequency *= lacunarity
            end
            local endHeight = (noiseHeight ^ POWER) * exaggeratedness
            if endHeight < minRaw then minRaw = endHeight end
            if endHeight > maxRaw then maxRaw = endHeight end
            table.insert(noiseMap, endHeight)
        end
    end
    -- local index = 0
    -- for x = 0, resolution.X do
    --     for y = 0, resolution.Y do
    --         index += 1
    --         noiseMap[index] = noiseMap[index]
    --     end
    -- end
    return noiseMap
end

return perlinNoise