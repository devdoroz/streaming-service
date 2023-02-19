local requests = {}
local httpService = game:GetService("HttpService")

local function bodyIntoQuery(body)
	local result = "?"
	for name, value in pairs(body) do
		result ..= name.."="..value.."&"
	end
	return string.sub(result, 1, #result - 1)
end
local acceptableMethods = {
	"GET",
	"POST",
	"DELETE",
	"PUT",
	"HEAD",
	"CONNECT",
	"OPTIONS",
	"TRACE",
	"PATCH"
}

function requests.uuid(curlyBraces: boolean?)
	return httpService:GenerateGUID(curlyBraces)
end

function requests.create(address: string?, method: string?, headers, body)
	if not method then return error("Invalid method") end
	method = string.upper(method)
	headers = headers or {}
	body = body or {}
	address = if method == "GET" then address..bodyIntoQuery(body) else address
	assert(table.find(acceptableMethods, method), "Invalid method")
	local sendData = {
		Url = address,
		Method = method,
	}
	if method ~= "GET" then
		sendData["Headers"] = headers
		sendData["Body"] = httpService:JSONEncode(body) or body
	end
	local req
	local s = pcall(function()
		req = httpService:RequestAsync(sendData)
	end)
	if s then
		local s, returned = pcall(function()
			return httpService:JSONDecode(req.Body)
		end)
		if s then
			req.Body = returned
		end
	end
	return req
end

return requests
