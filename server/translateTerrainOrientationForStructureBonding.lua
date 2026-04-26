local translateTerrainOrientationForStructureBonding = {
    orientationSubtraction = Vector3.new(0, 0, -90)
}
function translateTerrainOrientationForStructureBonding:Translate(targetTriangle)
    local orientation = targetTriangle.Orientation
	return Vector3.new(orientation.X, orientation.Y, orientation.Z) + self.orientationSubtraction
end
return translateTerrainOrientationForStructureBonding