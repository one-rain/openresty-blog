--
-- 首页，获取文章总数和分页信息
-- User: one-rain
-- Date: 2016/11/7
-- Time: 12:35
--

local template = require "resty.template"
local mysql = require("mysql_utils")
strutil = require("string_utils")
local cjson = require("cjson")

local s = ngx.var.request_uri
local index = string.find(s, '?')
if index and index > 0 then
    s = string.sub(s, 0, index - 1)
end


local tag_id = 0
local page = 1
local urls = strutil.split(s, '/')
local n = table.getn(urls)
if n >= 3 and urls[2] == 'tag' then
    tag_id = tonumber(urls[3])
    if n >= 5 and urls[4] == 'page' then
        page = tonumber(urls[5])
    end
end

local uri_args = ngx.req.get_uri_args()
--for k,v in pairs(uri_args) do
--    ngx.say("[GET ] key:", k, " v:", v)
--end
local q = uri_args['s']

local catalog = ngx.var.catalog
if catalog == nil then
    catalog = 0
end

local page_size = 5

local function select_catalog()
    local select_sql = "select id, tag from t_tag where type=1 and status=1"
    return mysql:getdatasource():query(select_sql)
end

--获取总数，用来分页
local function select_count()
    local select_sql = ""
    if tag_id > 0 then
        select_sql = "select count(a.id) total from t_article a, t_article_tag b where b.tagid = " .. tag_id .. " and a.id=b.aid and a.status=1"
        if q then
            select_sql = select_sql .. " and a.html like '" .. q .. "%'"
        end
        --select_sql = string.format(sql, tag_id)
    else
        select_sql = "select count(id) total from t_article where status=1"
        if q then
            select_sql = select_sql .. " and html like '" .. q .. "%'"
        end
        --select_sql = sql
    end
    --ngx.say(select_sql)

    return mysql:getdatasource():query(select_sql)
end

local function select_post()
    local select_sql = ""
    if tag_id > 0 then
        select_sql = "select a.id,a.title,a.content,a.tag_id,a.tag_name,a.img_path,a.read_count,a.create_time from t_article a, t_article_tag b where b.tagid = " .. tag_id .. " and a.id=b.aid and a.status=1"
        if q then
            select_sql = select_sql .. " and a.html like '" .. q .. "%'"
        end
        select_sql = select_sql .. " order by a.id desc limit " .. ((page - 1) * page_size) .. "," .. page_size
        --select_sql = string.format(sql, tag_id, , page_size)
    else
        select_sql = "select id,title,content,tag_id,tag_name,img_path,read_count,create_time from t_article where status=1"
        if q then
            select_sql = select_sql .. " and html like '" .. q .. "%'"
        end
        select_sql = select_sql .. " order by id desc limit " .. ((page - 1) * page_size) .. "," .. page_size
        --select_sql = string.format(sql, ((page - 1) * page_size), page_size)
    end
    --ngx.say(select_sql)

    return mysql:getdatasource():query(select_sql)
end

local function select_tag()
    local select_sql = "select a.tagid id,max(t.tag) name,count(1) cn from t_article_tag a, t_tag t where a.tagid=t.id group by tagid order by cn desc"
    return mysql:getdatasource():query(select_sql)
end

local total_row = select_count()[1].total
local total_page = 1
if total_row % page_size == 0 then
    total_page = math.floor(total_row / page_size)
else
    total_page = math.floor(total_row / page_size) + 1
end

local posts = select_post()
local tags = select_tag()

mysql:close()

--local domain = 'https://' .. ngx.var.host
local domain = 'https://kiswo.com'

local content = {
    domain = domain,
    tag = tag_id,
    page = page,
    catalog = catalog,
    total_page = total_page,
    head_keywords = "Java,大数据,Hadoop,Flume,Kafka,Storm,Hive,Nginx,OpenResty,日志收集",
    head_title = "One Rain's Blog",
    head_description = "王潤，一名软件工程师，坐标北京。喜欢新技术，喜欢Code，擅长Copy，语言学的太杂，已经傻傻分不清。英语很菜，行动很慢，却梦想成为一名架构师。这里记录了我的点点滴滴。",
    posts = posts,
    s = q,
    tags = tags,
}

--ngx.say(content.posts)
--ngx.say(cjson.encode(content))

template.caching(true)
template.render("home.html", content)
