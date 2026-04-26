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
    robloxAdapter:setProperty(thisTriangle, "Parent", wedgesFolder)
    robloxAdapter:setProperty(thisTriangle, "Color", Color3.fromRGB(237, 201, 175))
    robloxAdapter:setProperty(thisTriangle, "Material", Enum.Material.Sand)
end
local startTime = os.clock()
local triangles = createTerrain:createTrianglesFromData(noised, resolution, partSize, Vector3.new(0, 500, 0), robloxAdapter, nil, function(thisData)
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