function assert(condition, message)
    if not condition then
        error(message or `{_VERSION} assertion error`)
    end
end

local modules = {}
local cached = {}
function import(key)
    assert(modules[key], `Module {key} does not exist`)
    local value = cached[key] or modules[key]()
    cached[key] = value
    return value
end
function modules.Util()
    local Object = {}

    function Object:assign(a, b, optionalFunc)
        assert(a, "A is missing")
        assert(b, "B is missing")
        local optionalFunc = optionalFunc or function(a, index, value) a[index] = value end
        for index, value in b do
            optionalFunc(a, index, value)
        end
    end

    return Object
end
function modules.selfProp()
    local selfProp = {}
    function selfProp:returnFunctionWithIdentity(func, this)
        assert(func, "Function is missing")
        assert(this, "this is missing")
        return function(...) return func(this, ...) end
    end
    return selfProp
end
function modules.robloxAdapter()
    local robloxAdapter = {}
    function robloxAdapter:newInstance(...)
        return Instance.new(...)
    end
    function robloxAdapter:setProperty(property, key, value)
        property[key] = value
    end
    function robloxAdapter:findFirstChild(target, ...)
        return target:FindFirstChild(...)
    end
    function robloxAdapter:destroy(target)
        return target:Destroy()
    end
    return robloxAdapter
end
function modules.PerlinNoise()
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
    local noiseMap = table.create(resolution.X * resolution.Y)
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
end
function modules.EgoMoose()
-- thanks from EgoMoose
-- https://github.com/EgoMoose/Articles
-- saved some time
local EgoMoose = {}
function EgoMoose:draw3dTriangle(a, b, c) -- roblox doesn't give us access to a plain triangle object or the render pipeline
	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

	if (abd > acd and abd > bcd) then
		c, a = a, c
	elseif (acd > bcd and acd > abd) then
		a, b = b, a
	end

	ab, ac, bc = b - a, c - a, c - b

	local right = ac:Cross(ab).unit
	local up = bc:Cross(right).unit
	local back = bc.unit

	local height = math.abs(ab:Dot(up))

	return {Size = Vector3.new(0, height, math.abs(ab:Dot(back))), CFrame = CFrame.fromMatrix((a + b)/2, right, up, back)}, {Size = Vector3.new(0, height, math.abs(ac:Dot(back))), CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back)}
end
function EgoMoose:getBarycentricHeight(vertexA, vertexB, vertexC, samplePoint) -- Get the height of a point in a triangle by finding how much this point relates to each other 3 vertexes and get a lerped position within how much it goes into each vertex's position. Returns a height number, and the percentages (0 - 1) and doesn't need to return an x or z because your samplePoint already does that and is just saying where on the triangle you're supposed to get
    local projectedDenominator = (vertexB.Z - vertexC.Z) * (vertexA.X - vertexC.X) + (vertexC.X - vertexB.X) * (vertexA.Z - vertexC.Z)

    if projectedDenominator == 0 then
        return nil, 0, 0, 0
    end

    local weightA = ((vertexB.Z - vertexC.Z) * (samplePoint.X - vertexC.X) + (vertexC.X - vertexB.X) * (samplePoint.Y - vertexC.Z)) / projectedDenominator
    local weightB = ((vertexC.Z - vertexA.Z) * (samplePoint.X - vertexC.X) + (vertexA.X - vertexC.X) * (samplePoint.Y - vertexC.Z)) / projectedDenominator
    local weightC = 1 - weightA - weightB

    local interpolatedHeight = weightA * vertexA.Y + weightB * vertexB.Y + weightC * vertexC.Y

    return interpolatedHeight, weightA, weightB, weightC
end

return EgoMoose
end
function modules.createTerrainFromVerticesUsingAdapter()
local createTerrain = {}
local EgoMoose = import("EgoMoose")
local Util = import("Util")
local selfProp = import("selfProp")

function createTerrain:materialiseTriangle(a, b, c, EgoMoose, adapter)
    local AData, BData = EgoMoose:draw3dTriangle(a, b, c) -- a, b, c
    local WedgeA = adapter:newInstance("WedgePart")
    local WedgeB = adapter:newInstance("WedgePart")
    adapter:setProperty(WedgeA, "Anchored", true)
    adapter:setProperty(WedgeB, "Anchored", true)
    Util:assign(WedgeA, AData, selfProp:returnFunctionWithIdentity(adapter.setProperty, adapter))
    Util:assign(WedgeB, BData, selfProp:returnFunctionWithIdentity(adapter.setProperty, adapter))
    return WedgeA, WedgeB
end

function createTerrain:createTrianglesFromData(data, resolution, partSize, offsetVector3, adapter, materialiseTriangle, operateOnData)
    -- note: resolution can only be an integer. Being a float breaks the entire thing because it's an index
    local triFunc = materialiseTriangle or selfProp:returnFunctionWithIdentity(self.materialiseTriangle, self)
    local wedges = {} -- Record<number, Record<number, [Instance, Instance]>>

    local function getFromXY(x, y)
        return data[x * (resolution.Y + 1) + y + 1]
    end

    local function multiplyVectorByPartSize(x, y, h)
        return Vector3.new(x * partSize, h * partSize, y * partSize)
    end
    local minSize, maxSize = math.huge, -math.huge
    for x = 0, resolution.X - 1 do
        for y = 0, resolution.Y - 1 do
            local computed_getFromXY_value = getFromXY(x, y)
            if computed_getFromXY_value < minSize then 
                minSize = computed_getFromXY_value
            end
            if computed_getFromXY_value > maxSize then
                maxSize = computed_getFromXY_value
            end
        end
    end
    local minSizeVector3 = Vector3.new(0, minSize * partSize, 0)
    for x = 0, resolution.X - 1 do
        for y = 0, resolution.Y - 1 do
            local topLeftOffset = Vector2.new(0, 0)
            local topRightOffset = Vector2.new(1, 0)
            local bottomLeftOffset = Vector2.new(0, 1)
            local bottomRightOffset = Vector2.new(1, 1)
            local tLTotalH = getFromXY(x + topLeftOffset.X, y + topLeftOffset.Y)
            local tRTotalH = getFromXY(x + topRightOffset.X, y + topRightOffset.Y)
            local bLTotalH = getFromXY(x + bottomLeftOffset.X, y + bottomLeftOffset.Y)
            local bRTotalH = getFromXY(x + bottomRightOffset.X, y + bottomRightOffset.Y)
            local topLeft = multiplyVectorByPartSize(x + topLeftOffset.X, y + topLeftOffset.X, tLTotalH) + offsetVector3 - minSizeVector3
            local topRight = multiplyVectorByPartSize(x + topRightOffset.X, y + topRightOffset.Y, tRTotalH) + offsetVector3 - minSizeVector3
            local bottomLeft = multiplyVectorByPartSize(x + bottomLeftOffset.X, y + bottomLeftOffset.Y, bLTotalH) + offsetVector3 - minSizeVector3
            local bottomRight = multiplyVectorByPartSize(x + bottomRightOffset.X, y + bottomRightOffset.Y, bRTotalH) + offsetVector3 - minSizeVector3
            if (not wedges[x]) then wedges[x] = {} end
            wedges[x][y] = {{triFunc(topLeft, topRight, bottomLeft, EgoMoose, adapter)}, {triFunc(topRight, bottomRight, bottomLeft, EgoMoose, adapter)}, data={
                vertices={topLeft,
                topRight,
                bottomLeft,
                bottomRight}, averageHeight=getFromXY(x, y)/maxSize, averageHeightSized=getFromXY(x, y)
            }}
            if not operateOnData then continue end
            operateOnData(wedges[x][y])
        end
    end
    return wedges
end
return createTerrain
end

do
local perlinNoise = import("PerlinNoise")
local createTerrain = import("createTerrainFromVerticesUsingAdapter")
local robloxAdapter = import("robloxAdapter")
local EgoMoose = import("EgoMoose")
local partSize = 100
local resolution = Vector2.new(math.round(10000 / partSize), math.round(10000 / partSize))
local lacunarity = 4
local persistence = 0.25
local octaves = 2
local exaggeratedness = 20
local roughness = 4
local POWER = 3
local offset = Vector2.new(math.random(1, 10e6), math.random(1, 10e6))
local noised = perlinNoise:generate(math.max(resolution.X, resolution.Y) / roughness, resolution, offset, exaggeratedness, lacunarity, persistence, octaves, POWER)
local wedgesFolder = robloxAdapter:findFirstChild(workspace, "Wedges")
if wedgesFolder then
    robloxAdapter:destroy(wedgesFolder)
end
local wedgesFolder = robloxAdapter:newInstance("Folder")
robloxAdapter:setProperty(wedgesFolder, "Parent", workspace)
robloxAdapter:setProperty(wedgesFolder, "Name", "Wedges")

local function operateOnThisTriangleInstance(data, thisTriangle)
    local isSnow = data.data.averageHeight > 0.5
    robloxAdapter:setProperty(thisTriangle, "Parent", wedgesFolder)
    robloxAdapter:setProperty(thisTriangle, "Color", isSnow and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(237, 201, 175))
    robloxAdapter:setProperty(thisTriangle, "Material", isSnow and Enum.Material.Snow or Enum.Material.Sand)
end
local startTime = os.clock()
local triangles = createTerrain:createTrianglesFromData(noised, resolution, partSize, Vector3.new(0, 0, 0), robloxAdapter, nil, function(thisData)
    operateOnThisTriangleInstance(thisData, thisData[1][1])
    operateOnThisTriangleInstance(thisData, thisData[1][2])
    operateOnThisTriangleInstance(thisData, thisData[2][1])
    operateOnThisTriangleInstance(thisData, thisData[2][2])
end)
local endTime = os.clock()

print(startTime, endTime, endTime - startTime)

-- for x, dataY in triangles do
-- for y, data in dataY do
--         data[1][1].Parent = wedgesFolder
--         data[1][2].Parent = wedgesFolder
--         data[2][1].Parent = wedgesFolder
--         data[2][2].Parent = wedgesFolder
--         -- data.data
--     end
-- end
end

-- FILE IS LOCKED