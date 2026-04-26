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
    local minSize = math.huge
    for x = 0, resolution.X - 1 do
        for y = 0, resolution.Y - 1 do
            if getFromXY(x, y) < minSize then minSize = getFromXY(x, y) * partSize end
        end
    end
    local minSizeVector3 = Vector3.new(0, minSize, 0)
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
                bottomRight}, averageHeight=getFromXY(x, y)
            }}
            if not operateOnData then continue end
            operateOnData(wedges[x][y])
        end
    end
    return wedges
end
return createTerrain