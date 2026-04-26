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
local randX = math.random(1, #triangles)
local randTrianglePickX = triangles[randX]
local randY = math.random(1, #randTrianglePickX)
local randTrianglePickY = randTrianglePickX[randY]
local pos = (randTrianglePickY.data.vertices[1] + randTrianglePickY.data.vertices[2]) / 2
local height = EgoMoose:getBarycentricHeight(randTrianglePickY.data.vertices[1], randTrianglePickY.data.vertices[2], randTrianglePickY.data.vertices[3], Vector2.new(pos.X, pos.Z))
local newPart = robloxAdapter:newInstance("Part")
robloxAdapter:setProperty(newPart, "Parent", workspace)
robloxAdapter:setProperty(newPart, "Anchored", true)
local dogCFrame = CFrame.new(Vector3.new(pos.X, height, pos.Z)) * triangles[randX][randY][1][1].CFrame.Rotation
robloxAdapter:setProperty(newPart, "CFrame", dogCFrame)