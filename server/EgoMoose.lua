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