local perlinNoise = import("PerlinNoise")
local createTerrain = import("createTerrainFromVerticesUsingAdapter")
local robloxAdapter = import("robloxAdapter")
local EgoMoose = import("EgoMoose")
local partSize = 30
local resolution = Vector2.new(math.round(2000 / partSize), math.round(2000 / partSize))
local lacunarity = 2
local persistence = 0.1
local octaves = 4
local exaggeratedness
local offset = Vector2.new(math.random(1, 10e6), math.random(1, 10e6))
local noised = perlinNoise:generate(math.max(resolution.X, resolution.Y) / 6, resolution, offset, exaggeratedness, lacunarity, persistence, octaves)
local startTime = os.clock()
local triangles = createTerrain:createTrianglesFromData(noised, resolution, partSize, Vector3.new(0, 0, 0), robloxAdapter)
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
        -- data.data
        if not success then warn(result) end
    end
end