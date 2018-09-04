local cjson = require "cjson.safe"
local http = require "resty.http"

local httpc = http:new()

local auth_header = kong.request.get_header("Authorization")
local token = auth_header:gsub("Bearer ", "")

local res, err = httpc:request_uri('CHECK_TOKEN_URL' .. token, {
    method = "GET",
    ssl_verify = false,
})

if res then

    local json = cjson.decode(res.body)

    if res.status ~= 200 then
         return kong.response.exit(401 , json.error)
    end

    for k,v in ipairs(json) do
        kong.service.request.set_header("X-"..k, v)
    end
end