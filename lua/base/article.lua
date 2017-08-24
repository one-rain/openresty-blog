--
-- 文章内容
-- User: one-rain
-- Date: 2016/11/7
-- Time: 12:35
--

local template = require "resty.template"
local mysql = require("mysql_utils")
local strutil = require("string_utils")
local cjson = require("cjson")

local id = 0
if ngx.var.id ~= nil then
    id =  ngx.var.id
end

local s = ngx.var.request_uri
local index = string.find(s, '?')
local args = ''
if index and index > 0 then
    args = string.sub(s, index + 1)
end

local function updateReader()
    local update_sql = string.format("update t_article set read_count=read_count+1 where id = %d", id)
    return mysql:getdatasource():query(update_sql)
end

local function select_post()
    local select_sql = string.format("select id,title,content,html,tag_id,tag_name,img_path,read_count,create_time from t_article where id = %d", id)
    return mysql:getdatasource():query(select_sql)
end

local function select_tag()
    local select_sql = "select a.tagid id,max(t.tag) name,count(1) cn from t_article_tag a, t_tag t where a.tagid=t.id group by tagid order by cn desc"
    return mysql:getdatasource():query(select_sql)
end

updateReader()
local post = select_post()
local tags = select_tag()

mysql:close()

--local domain = 'http://' .. ngx.var.host
local domain = 'https://kiswo.com'
local url = domain .. s
local head_title = post[1].title .. " | One Rain's Blog"
local head_description = string.gsub(post[1].content, "%s*", "")
local head_keywords = post[1].tag_name
local tag_names = strutil.split(head_keywords, ',')
local tag_ids = strutil.split(post[1].tag_id, ',')
local time = post[1].create_time
local image = post[1].img_path

local content = {
    domain = domain,
    url = url,
    head_keywords = head_keywords,
    head_title = head_title,
    head_description = head_description,
    post = post,
    tags = tags,
    tag_ids = tag_ids,
    tag_names = tag_names,
    time = time,
    image = image,
}

template.caching(true)

if (id == '1014' and args ~= 'k=fly') then
    template.render("404.html", content)
else
    template.render("post.html", content)
end

