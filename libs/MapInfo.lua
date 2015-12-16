
function toInt(str)
	local num = 0
	local len = #str
	for i = 1,len do
		num = num + string.byte(str,i) * 256^(i-1)
	end
	return num
end

function getMapInfo()
	local filepath = VFS.DirList("maps/","*.smf")[1]
	local file = VFS.LoadFile(filepath) -- currently loaded map (for now)

	local map = {
		version         = toInt(file:sub(17, 20)),
		mapid           = toInt(file:sub(21, 24)),
		mapx            = toInt(file:sub(25, 28)),
		mapy            = toInt(file:sub(29, 32)),
		squareSize      = toInt(file:sub(33, 36)),
		texelPerSquare  = toInt(file:sub(37, 40)),
		tilesize        = toInt(file:sub(41, 44)),
		--minHeight       = toInt(file:sub(45, 48)), -- float
		--maxHeight       = toInt(file:sub(49, 52)), -- float
		heightmapPtr    = toInt(file:sub(53, 56)),
		typeMapPtr      = toInt(file:sub(57, 60)),
		tilesPtr        = toInt(file:sub(61, 64)),
		minimapPtr      = toInt(file:sub(65, 68)),
		metalmapPtr     = toInt(file:sub(69, 72)),
		featurePtr      = toInt(file:sub(73, 76)),
		numExtraHeaders = toInt(file:sub(77, 80)),
	}

	local minimap = file:sub(map.minimapPtr, size)
end

