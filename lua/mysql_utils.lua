--
-- mysql datasource
-- User: one-rain
-- Date: 2016/10/27
-- Time: 16:30
-- To change this template use File | Settings | File Templates.
--


local mysql = require("resty.mysql")

local _MySQL = {}


-- 创建连接
function _MySQL:getdatasource()
    if ngx.ctx[_MySQL] then
        return ngx.ctx[_MySQL]
    end

    local db, err = mysql:new()
    if not db then
        ngx.log(ngx.ERR, "failed to instantiate mysql: ", err)
        return
    end

    db:set_timeout(5000)

    local props = {
        host = "127.0.0.1",
        port = 3306,
        database = "yourdb",
        user = "username",
        password = "yourpwd"
    }

    local connect, err, errno, sqlstate = db:connect(props)

    if not connect then
        ngx.log(ngx.ERR, "connect to mysql error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
        return close_db(db)
    end

    ngx.ctx[_MySQL] = db
    return ngx.ctx[_MySQL]
end


--- 关闭连接
function _MySQL:close()
    if ngx.ctx[_MySQL] then
        ngx.ctx[_MySQL]:set_keepalive(10000, 100)
        ngx.ctx[_MySQL] = nil
    end
end


--- 执行查询
--
-- 有结果数据集时返回结果数据集
-- 无数据集时返回查询影响，如：
-- { insert_id = 0, server_status = 2, warning_count = 1, affected_rows = 32, message = nil}
--
-- @param string query 查询语句
-- @return table 查询结果
-- @error mysql.queryFailed 查询失败
function _MySQL:query(query)
    res, err, errcode, sqlstate = self:getdatasource():query(query)
    if not res then
        ngx.log(ngx.ERR, "bad result, error: ", err, "error code: ", errcode, "sqlstate: ", sqlstate, "." , "sql: ", query)
        return nil
    end
    ngx.log(ngx.INFO, "SQL: ", query)
    return res
end

return _MySQL