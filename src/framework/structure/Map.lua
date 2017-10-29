--------------------------------------------------------
--- 列表容器
-- @copyright(c) 
-- @author 
-- @release 2016/8/5
--------------------------------------------------------

------
-- 列表容器
Map = class("Map")


----------------------
--   构造区
----------------------
------
--   构造函数
function Map:ctor()
    self.m_map = {}
    --setmetatable(self.m_map, {__mode = "kv"})
    self.m_size = 0
end

------
-- 往map中加入值，如果map中的所对应的key已经有值了，那么插入将失败
-- @param[type=data] key值
-- @param[type=data] value值
function Map:insert(key, value)
    if nil == key then
        return false
    end

    local oldValue = self.m_map[key]
    if nil ~= oldValue then
        return false
    end

    self.m_map[key] = value
    self.m_size = self.m_size + 1
	return true
end

------
-- 替换map中的值，如果map中的所对应的key不存在，那么不进行替换
-- @param[type=data] key值
-- @param[type=data] value值
function Map:replace(key, value)
    local oldValue = self.m_map[key]
    if nil == oldValue then
        return
    end
    self.m_map[key] = value
end

------
-- 通过key来查询某个value 查询失败将返回nil
-- @return[type=data] value值
function Map:find(key)
    local oldValue = self.m_map[key]
    return oldValue
end

------
-- 通过key来删除某个value
-- @param[type=data] key值
function Map:erase(key)
    if nil == key then
        return
    end
    if nil ~= self.m_map[key] then
        self.m_map[key] = nil
        self.m_size = self.m_size - 1
    end
end

------
-- 清空
function Map:clear()
    self.m_map = {}
    self.m_size = 0
end

------
-- Map中内容的个数
-- @param[type=number] 内容个数
function Map:size()
    return self.m_size
end

------
-- Map中的内容是否为空
-- @return[type=number] 是否为空
function Map:isEmpty()
    return self.m_size == 0
end

------
-- Map的迭代器函数，一般是这么用的
-- local map = Map.new()
-- for k, v in map:pairs() do
--     print(k)
-- end
-- @param[type=function] 返回迭代器函数
function Map:pairs()
    return pairs(self.m_map)
end