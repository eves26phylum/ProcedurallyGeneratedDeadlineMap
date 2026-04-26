local perlinNoise = import("PerlinNoise")
local createTerrain = import("createTerrainFromVerticesUsingAdapter")
local robloxAdapter = import("robloxAdapter")
local resolution = Vector2.new(50, 50)
local noised = perlinNoise:generate(math.max(resolution.X, resolution.Y) * 5, resolution)
local startTime = os.clock()
local triangles = createTerrain:createTrianglesFromData(noised, resolution, 5, 20, Vector3.new(0, 0, 0), robloxAdapter)
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