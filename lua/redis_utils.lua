--
-- redis pool
-- User: one-rain
-- Date: 2016/10/28
-- Time: 16:21
-- To change this template use File | Settings | File Templates.
--

local redis = require "resty.redis"

local jedis = {}
jedis.VERSION = "0.0.1"

function jedis:getconnect()
    if ngx.ctx[jedis] then
        return true, ngx.ctx[jedis]
    end

    local red, errmsg = redis:new()
    if not red then
        return false, "redis.socket_failed: " .. (errmsg or "nil")
    end

    red:set_timeout(1000) -- 1 sec

    local client, err = red:connect("127.0.0.1", 6379)
    local auth_flg = client:auth("yourpwd")
    if not auth_flg then
        ngx.log(ngx.ERR, "failed to connect: ", err)
        return nil
    end

    ngx.ctx[jedis] = red
    return true, ngx.ctx[jedis]
end

function jedis:commitpipeline()
    local results, err = ngx.ctx[jedis]:commit_pipeline()
    if not results then
        ngx.log(ngx.ERR, "failed to commit the pipelined requests: ", err)
        return nil
    end

    return results
end

function jedis:close()
    if ngx.ctx[jedis] then
        ngx.ctx[jedis]:set_keepalive(10000, 100)
        ngx.ctx[jedis] = nil
    end
end

return jedis
