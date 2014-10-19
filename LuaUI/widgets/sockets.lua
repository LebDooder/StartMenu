
if not (Spring.GetConfigInt("LuaSocketEnabled", 0) == 1) then
	Spring.Echo("LuaSocketEnabled is disabled")
	return false
end

function widget:GetInfo()
return {
	name    = "Test-Widget for luasocket",
	desc    = "a simple test widget to show capabilities of luasocket",
	author  = "abma",
	date    = "Feb. 2012",
	license = "GNU GPL, v2 or later",
	layer   = 0,
	enabled = false,
}
end


local socket = socket


local clients = {}
local step = 1

local host = "api.springfiles.com"
local port = 80
local map = 'Ravaged_v2'
local minimap
local heightmap


local function SocketConnect()
	local client = socket.tcp()
	client:settimeout(0)
	res, err = client:connect(host, port)

	if err then
		Spring.Echo("Error in connect: " .. err)
		return false
	end
	
	clients = {client}
end

local function GetMapInfo(arg)
	map = arg
	minimap = io.open('maps/'..map..'_minimap.jpg','w+')
	heightmap = io.open('maps/'..map..'_heightmap.jpg','w+')
	step = 1
	SocketConnect(host, port)
end

local requests = {}

local sent = {}
local URLs = {
	'/?springname=' .. map .. '&filename=&tag=&sdp=&images=on&category='
}

local funcs = {
	function(data)
		URLs[2] = data:match('0:<a href="http://api.springfiles.com(.-)">')
		URLs[3] = data:match('1:<a href="http://api.springfiles.com(.-)">')
		Spring.Echo(URLs[2])	
		Spring.Echo(URLs[3])	
	end,
	function(data)
		minimap:write(data)
	end,
	function(data)
		heightmap:write(data)
	end,
}

-- called when data can be written to a socket
local function sendOn(sock)
	if sent[step]then return end
	if URLs[step] then
		Spring.Echo("Socket "..step.." Sent")
		sock:send("GET " .. URLs[step] .. " HTTP/1.0\r\nHost: " .. host ..  " \r\n\r\n")
		sent[step] = true
	else
		Spring.Echo("GetMapInfo can't get URL for step " .. step)
		sent[step] = true
	end
end

-- called when a connection is closed
local function SocketClosed(sock)
	Spring.Echo("Socket "..step.." closed")
	sock:close()
	if step < #funcs then
		step = step + 1
		SocketConnect()
	else
		minimap:close()
		heightmap:close()
	end
end

local function CheckAvail()
	if not next(clients) then return end

	-- get sockets ready for read
	local readable, writeable, err = socket.select(clients, clients, 0)
	if err then return end

	for _, input in ipairs(readable) do
		local s, status, partial = input:receive('*a') --try to read all data
		Spring.Echo("Recieved " .. string.len(s or partial) .. " Bytes, with status of " .. (status or 'nil'))
		
		if status == "timeout" or status == nil then
			funcs[step](s or partial)
		elseif status == "closed" then
			SocketClosed(input)
		end
	end
	
	for _, sock in ipairs(writeable) do
		sendOn(sock)
	end
end

function widget:Update()
	CheckAvail()
end

function widget:Initialize()
	WG.GetMapInfo = GetMapInfo
end