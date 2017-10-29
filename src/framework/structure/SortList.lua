
--[[
排序队列数据结构
只会处理设置的最大数量顺序
]]

SortList = class("SortList")

--
--orderType 排序类型 1降序 2升序， 默认降序
function SortList:ctor(maxNum, sortKey, orderType)
    self._sortMaxNum = maxNum
    self._sortKey = sortKey
    self._orderType = orderType or 1
    
    self._lastElement = 0
    
    self._sortList = {}
end

--1降序
function SortList:comp1(a, b)
    return a >= b
end

-- 2升序
function SortList:comp2(a, b)
    return a <= b
end

function SortList:add(element)
    local sortKey = self._sortKey
    local value = element[sortKey]
    local compFunc = self["comp" .. self._orderType]
    
    local curSortListLen = #self._sortList
    if curSortListLen >= self._sortMaxNum then
        if compFunc(self, self._lastElement[sortKey], value) then
            return  --跟最后一个数比较还不满足要求
        end
    end
    
    for index=1, self._sortMaxNum do
        local indexElement = self._sortList[index]
        local nextElement = self._sortList[index + 1]
        if indexElement == nil then
            self:insert(element)
            break
        elseif not compFunc(self, indexElement[sortKey], value) and index == 1 then
            self:insert(index, element )
            break
        elseif compFunc(self, indexElement[sortKey], value) 
            and nextElement == nil then 
            self:insert(element)
            break
        elseif compFunc(self, indexElement[sortKey], value) 
            and (not compFunc(self, nextElement[sortKey], value)) then
            self:insert(index + 1, element )
            break
    	end
    end
    
    local len = #self._sortList
    self._lastElement = self._sortList[len]
    
--    self:print()
end

function SortList:insert(pos, element)
    if element == nil then
        table.insert(self._sortList, pos)
    else
        table.insert(self._sortList, pos, element)
    end
    
    local len = #self._sortList
    if len > self._sortMaxNum then
        table.remove(self._sortList, len)
    end
end

function SortList:getList()
    return self._sortList
end

function SortList:print()
    local list = {}
    for _, value in pairs(self._sortList) do
        table.insert(list, value[self._sortKey])
    end
    
    print(table.concat(list,"#"))
end












