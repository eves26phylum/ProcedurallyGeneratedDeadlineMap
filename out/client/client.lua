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
        for index, value in b do
            if optionalFunc then
                optionalFunc(a, index, value)
                continue
            end
            a[index] = value
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
end
function modules.EgoMoose()
    -- sourced from EgoMoose
    -- https://github.com/EgoMoose/Articles
    -- saved me some time if i was gonna do it myself when I was searching on wedgeparts in roblox
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
    WedgeA.Anchored = true
    WedgeB.Anchored = true
    Util:assign(WedgeA, AData, selfProp:returnFunctionWithIdentity(adapter.setProperty, adapter))
    Util:assign(WedgeB, BData, selfProp:returnFunctionWithIdentity(adapter.setProperty, adapter))
    return WedgeA, WedgeB
end

function createTerrain:createTrianglesFromData(data, resolution, partSize, exaggeratedness, offsetVector3, adapter, materialiseTriangle)
    -- note: resolution can only be an integer. Being a float breaks the entire thing because it's an index
    local triFunc = materialiseTriangle or selfProp:returnFunctionWithIdentity(self.materialiseTriangle, self)
    local wedges = {} -- Record<number, Record<number, [Instance, Instance]>>
    local minRaw = math.huge
    for i = 1, #data do
        if data[i] < minRaw then minRaw = data[i] end
    end

    local function getHeight(x, y)
        local raw = data[x * (resolution.Y + 1) + y + 1]
        return minRaw + (raw - minRaw) * exaggeratedness
    end

    local function multiplyVectorByPartSize(x, y, h)
        return Vector3.new(x * partSize, h * partSize, y * partSize)
    end

    for x = 0, resolution.X - 1 do
        for y = 0, resolution.Y - 1 do
            local topLeftOffset = Vector2.new(0, 0)
            local topRightOffset = Vector2.new(1, 0)
            local bottomLeftOffset = Vector2.new(0, 1)
            local bottomRightOffset = Vector2.new(1, 1)
            local tLTotalH = getHeight(x + topLeftOffset.X, y + topLeftOffset.Y)
            local tRTotalH = getHeight(x + topRightOffset.X, y + topRightOffset.Y)
            local bLTotalH = getHeight(x + bottomLeftOffset.X, y + bottomLeftOffset.Y)
            local bRTotalH = getHeight(x + bottomRightOffset.X, y + bottomRightOffset.Y)
            local topLeft = multiplyVectorByPartSize(x + topLeftOffset.X, y + topLeftOffset.X, tLTotalH) + offsetVector3
            local topRight = multiplyVectorByPartSize(x + topRightOffset.X, y + topRightOffset.Y, tRTotalH) + offsetVector3
            local bottomLeft = multiplyVectorByPartSize(x + bottomLeftOffset.X, y + bottomLeftOffset.Y, bLTotalH) + offsetVector3
            local bottomRight = multiplyVectorByPartSize(x + bottomRightOffset.X, y + bottomRightOffset.Y, bRTotalH) + offsetVector3
            if (not wedges[x]) then wedges[x] = {} end
            wedges[x][y] = {{triFunc(topLeft, topRight, bottomLeft, EgoMoose, adapter)}, {triFunc(topRight, bottomRight, bottomLeft, EgoMoose, adapter)}, data={
                vertices={topLeft,
                topRight,
                bottomLeft,
                bottomRight}
            }}
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
local partSize = 30
local resolution = Vector2.new(math.round(1000 / partSize), math.round(1000 / partSize))
local maxxedResolution = math.max(resolution.X, resolution.Y)
local noised = perlinNoise:generate(maxxedResolution * 0.25, resolution)
local startTime = os.clock()
local triangles = createTerrain:createTrianglesFromData(noised, resolution, partSize, 20, Vector3.new(0, 0, 0), robloxAdapter)
local endTime = os.clock()
print(startTime, endTime, endTime - startTime)
local wedgesFolder = robloxAdapter:findFirstChild(workspace, "Wedges")
if wedgesFolder then
    robloxAdapter:destroy(wedgesFolder)
end
local wedgesFolder = robloxAdapter:newInstance("Folder")
robloxAdapter:setProperty(wedgesFolder, "Parent", workspace)
robloxAdapter:setProperty(wedgesFolder, "Name", "Wedges")
for x, dataY in triangles do
    for y, data in dataY do
        local success, result = pcall(function()
            data[1][1].Parent = wedgesFolder
            data[1][2].Parent = wedgesFolder
            data[2][1].Parent = wedgesFolder
            data[2][2].Parent = wedgesFolder
        end)
        if not success then warn(result) end
    end
end
local randTrianglePickX = triangles[math.random(1, #triangles)]
local randTrianglePickY = randTrianglePickX[math.random(1, #randTrianglePickX)]
local pos = (randTrianglePickY.data.vertices[1] + randTrianglePickY.data.vertices[2]) / 2
local height = EgoMoose:getBarycentricHeight(randTrianglePickY.data.vertices[1], randTrianglePickY.data.vertices[2], randTrianglePickY.data.vertices[3], Vector2.new(pos.X, pos.Z))
local newPart = robloxAdapter:newInstance("Part")
robloxAdapter:setProperty(newPart, "Parent", workspace)
robloxAdapter:setProperty(newPart, "Anchored", true)
local dogCFrame = CFrame.new(Vector3.new(pos.X, height, pos.Z)) * data[randTrianglePickX][randTrianglePickY][1][1].CFrame.Rotation
robloxAdapter:setProperty(newPart, "CFrame", dogCFrame)
end

-- FILE IS LOCKED