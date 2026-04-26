local createTerrain = {}
local EgoMoose = import("EgoMoose")
local Util = import("Util")
local robloxAdapter = import("robloxAdapter")
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

function createTerrain:createTrianglesFromData(data, resolution, partSize, exaggeratedness, offsetVector3, materialiseTriangle)
    local triFunc = materialiseTriangle or selfProp:returnFunctionWithIdentity(self.materialiseTriangle, self)
    local wedges = {} -- Record<number, Record<number, [Instance, Instance]>>

    local function getHeight(x, y)
        return data[x * (resolution.Y + 1) + y + 1]
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
            local tLTotalH = getHeight(x + topLeftOffset.X, y + topLeftOffset.Y) * exaggeratedness
            local tRTotalH = getHeight(x + topRightOffset.X, y + topRightOffset.Y) * exaggeratedness
            local bLTotalH = getHeight(x + bottomLeftOffset.X, y + bottomLeftOffset.Y)
            local bRTotalH = getHeight(x + bottomRightOffset.X, y + bottomRightOffset.Y)
            local topLeft = multiplyVectorByPartSize(x + topLeftOffset.X, y + topLeftOffset.X, tLTotalH) + offsetVector3
            local topRight = multiplyVectorByPartSize(x + topRightOffset.X, y + topRightOffset.Y, tRTotalH) + offsetVector3
            local bottomLeft = multiplyVectorByPartSize(x + bottomLeftOffset.X, y + bottomLeftOffset.Y, bLTotalH) + offsetVector3
            local bottomRight = multiplyVectorByPartSize(x + bottomRightOffset.X, y + bottomRightOffset.Y, bRTotalH) + offsetVector3
            if (not wedges[x]) then wedges[x] = {} end
            wedges[x][y] = {{triFunc(topLeft, topRight, bottomLeft, EgoMoose, robloxAdapter)}, {triFunc(topRight, bottomRight, bottomLeft, EgoMoose, robloxAdapter)}}
        end
    end

    return wedges
end
return createTerrain