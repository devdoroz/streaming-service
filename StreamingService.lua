--[[
	StreamingService: Send data across every game server!
	
	MessagingService, but without the rate limits!
	
	StreamingService Functions:
		- Publish(subscription: string, data)
		- Subscribe(subscription, functionOnData: function)
--]]

local stream = {hash = ''}
local runService = game:GetService("RunService")
local serverStorage = game:GetService("ServerStorage")
local requests = require(script:WaitForChild("Requests"))
local url = "https://streaming.doroz-cats.com/"
local serverUUID = requests.uuid(false)
local auth = serverStorage:WaitForChild("Auth", 3); do
	if not auth then
		warn("Make a string value in ServerStorage called auth with a generated value from https://streaming.doroz-cats.com/gen")
	else
		auth = auth.Value
	end
end

function stream:Publish(subscription: string?, data)
	local s = pcall(function()
		requests.create(url.."subscription", "PUT", {["Content-Type"] = "application/json"}, {subscription = subscription, data = data, hash = stream.Hash})
	end)
	return s
end

function stream:Subscribe(subscription: string?, functionOnData)
	coroutine.wrap(function()
		while true do
			task.wait()
			pcall(function()
				-- We use long polling
				local req = requests.create(url..stream.Hash.."/"..subscription, "GET", {}, {uuid = serverUUID})
				if req.Success then
					local body = req.Body
					if typeof(body) == "table" then
						functionOnData(body)
					end
				end
			end)
		end
	end)()
end

if runService:IsServer() then
	-- Initalization
	local req = requests.create(url.."get-stream", "GET", {}, {auth = auth, uuid = serverUUID})
	if req.Success then
		local body = req.Body
		stream.Hash = body.streamHash
	else
		warn("Invalid authentication")
	end
else
	warn("This should be only required on server.")
end

return stream
