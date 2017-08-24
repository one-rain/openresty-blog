--
-- User: one-rain
-- Date: 2016/12/23
-- Time: 15:31
-- To change this template use File | Settings | File Templates.
--

local template = require "resty.template"
local redis = require "resty_utils"


local function createtoken()
    ngx.log(ngx.INFO, "")
end



local data = '{"code": ' .. 100 .. ', "message": "抱歉，该功能暂未开放！", "callbak": "https://kiswo.com"}'
template.rander("login.html", data)
