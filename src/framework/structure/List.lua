--------------------------------------------------------
--- 列表容器
-- @copyright(c) 
-- @author 
-- @release 2016/8/5
--------------------------------------------------------

------
-- 列表容器
List = class("List")


----------------------
--   构造区
----------------------
------
--   构造函数
function List:ctor()
    self.m_list = {}
    self.m_size = 0
end

------
-- 往最后面加入数据
-- @param[type=data] 任意类型的数据
function List:pushBack(data)
    if nil == data then
        return 
    end 
    table.insert(self.m_list, data)
    self.m_size = self.m_size + 1
end

------
-- 往最前面加入数据
-- @param[type=data] 任意类型的数据
function List:pushFront(data)
    if nil == data then
        return 
    end 
    table.insert(self.m_list, 1, data)
    self.m_size = self.m_size + 1
end

------
-- 指定位置加入数据
-- @param[type=number] 任意类型的数据
-- @param[type=data] 任意类型的数据
function List:insert(index, data)
    if nil == data then
        return 
    end 
    if index > self.m_size then
        index = self.m_size + 1
    end

    if index <= 0 then
        index = 1
    end
    table.insert(self.m_list, index, data)
    self.m_size = self.m_size + 1
end

------
-- 通过索引来删除数据
-- @param[type=number] 索引值
function List:erase(index)
    if index > self.m_size or index <= 0 then
        return
    end

    table.remove(self.m_list, index)
    self.m_size = self.m_size - 1
end

------
-- 通过索引获取某个值
-- @param[type=int] 索引值
function List:at(index)
   if index > self.m_size or index < 0 then
        return nil
    end
    return self.m_list[index]
end

------
-- 替换某个数据项
-- @param[type=index] 索引值
-- @param[type=data]  
function List:replace(index, data)
    if nil == data then 
       return 
    end 
    if index > self.m_size or index <= 0 then
       return
    end
    self.m_list[index] = data
end

------
-- 返回最前面的数据
-- @return[type=data] 任意类型的数据，可能为空
function List:front()
    if self.m_size == 0 then
        return nil        
    else
        return self.m_list[1];
    end
end

------
-- 返回最后面的数据
-- @return[type=data] 任意类型的数据，可能为空
function List:back()
    if self.m_size == 0 then
        return nil
    else
        return self.m_list[self.m_size];
    end
end

------
-- 将最前面的数据移除并返回
-- @return[type=data] 任意类型的数据，可能为空
function List:popFront()
    if self.m_size > 0 then
        local front = self.m_list[1]
        table.remove(self.m_list, 1)
        self.m_size = self.m_size - 1
        return front
    else
        return nil
    end
end

------
-- 将最后面的数据移除并返回
-- @return[type=data] 任意类型的数据，可能为空
function List:popBack()
    if self.m_size > 0 then
        local back = self.m_list[self.m_size]
        table.remove(self.m_list, self.m_size)
        self.m_size = self.m_size - 1
        return back
    else
        return nil
    end
end

------
-- 返回list中数据的大小
-- @return[type=number] list的大小
function List:size()
    return self.m_size
end

------
-- 通过一个排序函数进行排序,排序函数类似下面
-- @param[type=function] sortFunc = function(a, b) return b < a end
function List:sort(sortFun)
   table.sort(self.m_list, sortFun)
end

------
-- 清空
function List:clear()
    if self.m_size == 0 then
        return
    end
    self.m_list = {}
    self.m_size = 0
end

------
-- 合并
-- @param[type=List] 一个list对象
-- @param[type=listBegin] 从list对象的那个位置开始拷贝
-- @param[type=listEnd] 从list对象的终止位置
function List:merge(objList, listBegin, listEnd)
    if nil == objList then
        return
    end

    if objList.__cname ~= "List" then
        return
    end
    local size = objList:size()
    local listTable = objList:getTable()
    for i = 1, size, 1 do
        table.insert(self.m_list, listTable[i])
    end
    self.m_size = self.m_size + size
end

------
-- 从一个table开始合并，需要保证这个table是链表的方式，而不是key value的方式
-- @param[type=table] 一个table对象
-- @param[type=listBegin] 从table对象的那个位置开始拷贝
-- @param[type=listEnd] 从table对象的终止位置
function List:mergeTable(objTable, listBegin, listEnd)
    if nil == objTable then
        return
    end

    local size = #objTable
    for i = 1, size, 1 do
        table.insert(self.m_list, objTable[i])
    end
    self.m_size = self.m_size + size
end

------
-- 返回内部用的table
-- @return[type=table] 返回内部用的table
function List:getTable()
    return self.m_list;
end

------
-- 判断是否为空
-- @return[type=bool] 返回是否为空
function List:isEmpty()
    return self.m_size == 0
end

------
-- 将List中的内容反向
function List:reverse()
    local half = self.m_size/2
    for i = 1, half, 1 do
        local tmp = self.m_list[i]
        local replaceIndex = self.m_size - i + 1
        self.m_list[i] = self.m_list[replaceIndex]
        self.m_list[replaceIndex] = tmp
    end
end

------
-- List的迭代器函数，ipairs版本，一般是这么用的
-- local list = List.new()
-- for k, v in list:ipairs() do
--     print(k)
--     print(v)
-- end
-- @param[type=function] 返回迭代器函数
function List:ipairs()
    return ipairs(self.m_list)
end

------
-- 通过数据项获得索引值
-- @param[type=data] 通过某个数据返回索引
-- @return[type=int] 索引
function List:getIndex(data)
    if nil == data then
       return 0
    end  
    local size = self.m_size
    for i = 1, size, 1 do
        local tmp = self.m_list[i]
        if tmp == data then 
            return i 
        end 
    end
    return 0
end 

------
-- 通过数据项移除某个数据
-- @param[type=data] 通过某个数据返回索引
function List:remove(data)
    if nil == data then
       return
    end  
    local index = self:getIndex(data)
    self:erase(index)
end 