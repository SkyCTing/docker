----------------------------
-- Copyright (c) 2019,2345
-- 摘    要：nginx 代理转发相应的目录
-- 作    者：san
-- 修改日期：2019.01.18
----------------------------

--服务器时间接口
local time              = ngx.time
local cjson             = require "cjson"
local json_decode       = cjson.decode
local json_encode       = cjson.encode

-- 日志
local file_err = '/opt/app/nginx/logs/'..os.date("%Y-%m-%d", os.time()).."-proxy-lua.log"

-- 日志
local function log(type,msg)
    type = type or 'ERR'
    files = assert(io.open(file_err,"a+"))
    files:write(os.date("%Y-%m-%d %X", os.time())..'    '..type..'    '..json_encode(msg)..'\n')
    files:close()
end

-- explode 方法  分隔字符串
local function explode(delimeter, str)
    local res = {}
    local start, start_pos, end_pos = 1, 1, 1
    while true do
        start_pos, end_pos = string.find(str, delimeter, start, true)
        if not start_pos then
            break
        end
        table.insert(res, string.sub(str, start, start_pos - 1))
        start = end_pos + 1
    end
    table.insert(res, string.sub(str,start))
    return res
end

--思路：可以在对应的lua脚本中调用shell命令，然后再shell命令中连接redis，之后就可以操作redis了--
---eg: redis-cli -h 127.0.0.1 -p 6379 -a 123456 -n 1 get ${key}-----
----- -h(host)表示服务器, -p(port)表示端口, -a 表示密码  -n 代表redis数据库的db index,get 后面接的是对应的key--------

-- 客户端ip
local headers = ngx.req.get_headers()
local ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"

-- 判断客户端ip是否为代理机ip,是的话判断X_FORWARDED_FOR
if ip == '172.17.12.70' or ip == '172.17.12.40' then
	local forwarded = explode(',', headers["X_FORWARDED_FOR"])
	if table.getn(forwarded) > 1 then
		ip = forwarded[1]
	end
end

-- nginx配置redis_domain
local redis_domain = ngx.var.redis_domain;
local redisKey = 'walle:domain:'..redis_domain..':clientip:'..ip
log('DEBUG', 'redis key is: '..redisKey)

local cmd = "/opt/app/nginx/conf/redis-cli -h 172.17.12.18 -p 6379 -a 2345 -n 0 get "..redisKey
local redis = io.popen(cmd)
if nil == redis then
    log('DEBUG', "get redis key fail")
end

----获取对应的数据---
local dir = tostring(redis:read())
--关闭---
redis:close()

-- 根据ip转发
if dir == nil or dir=='' or dir == 'nil' then
    log('DEBUG','path is null, use default master')
    --ngx.exit(500)
	if string.find(redis_domain, "_pre") then
		return "/opt/case/"..string.gsub(redis_domain,"_pre",".pre").."/master"
	else
		return "/opt/case/"..redis_domain..".test/master"
	end
    
else
    log('DEBUG','path is: '..dir)
    return dir
end
