------
-- 在table中查找值，返回位置，失败返回-1
table.indexOf =
function(table, value)
    local index = -1
    local i = 1
    for _, t in pairs(table) do
    	if t == value then
    	    index = i
    	    break
    	else
            i = i + 1
    	end
    end
    return index
end

--将list全部添加到tale中去
table.addAll = 
function(tableV, list)
    for _, value in pairs(list) do
        table.insert(tableV, value)
    end
    
end
------
--tableA tableB是否有交集
table.isIntersect = 
function(tableA, tableB)
    local result = false
    for _, vA in pairs(tableA) do
        for _, vB in pairs(tableB) do
    		if vA == vB then
    		    result = true
    		    break
    		end
    	end
    	if result == true then
    	    break
    	end
    end
    return result
end

-----
-- table的长度size
table.size =
function(table)
    local size = 0
    for _, _ in pairs(table) do
        size = size + 1
    end
    return size
end

------
-- 返回最大的key值
table.maxKey =
function(table)
    local maxkey = 0
    for key, _ in pairs(table) do
        if key > maxkey then
            maxkey = key
        end
    end
    
    return maxkey
end


------
-- 根据值删除元素
-- @param  tableV [table] 表
-- @param  value [key] key值
-- @return nil
table.removeValue =
function(tableV, value)
    local index = -1
    for i, name in pairs(tableV) do
    	if value == name then
    	    index = i
    	    break
    	end
    end
    if index >= 0 then
        table.remove(tableV, index)
    end
end

local function partition (arr, left, right, pivotIndex, cmp)
    local pivotValue, storeIndex
    pivotValue = arr[pivotIndex]
    arr[pivotIndex], arr[right] = arr[right], arr[pivotIndex]
    storeIndex = left
    for i=left,right-1,1 do
--        if arr[i] <= pivotValue then
        if cmp(arr[i], pivotValue) then
            arr[i], arr[storeIndex] = arr[storeIndex], arr[i]
            storeIndex = storeIndex+1
        end
    end
    arr[storeIndex], arr[right] = arr[right], arr[storeIndex]
    return storeIndex
end

table.quicksort = 
function(arr, left, right, cmp)
    local pivotIndex
    if right > left then
        pivotIndex = partition(arr, left, right, left, cmp)
        table.quicksort(arr, left, pivotIndex-1, cmp)
        table.quicksort(arr, pivotIndex + 1, right, cmp)
    end
end


-- 计算 table 中所有不为 nil 的值的个数
table.nums = 
function(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

-- 判断 table 是否空表
table.isEmpty = 
function(t)
    for k, v in pairs(t) do
        return false
    end
    return true
end


-- 返回所有的key值
table.keys =
function(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

-- 返回所有的值
table.values = 
function(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

-- 将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值
table.merge = 
function(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

-- 在 目标表格 的指定位置插入 来源表格，如果没有指定位置则连接两个表格
table.insertto = 
function (dest, src, begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

-- 从list中查找指定值，返回其索引，如果没找到返回 false
-- table.indexOf更通用
table.indexofList = 
function(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then return i end
    end
    return false
end

-- 从表格中查找指定值，返回其 key，如果没找到返回 nil
table.keyof = 
function(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then return k end
    end
    return nil
end

-- 从表格中删除指定值，返回删除的值的个数
table.removebyvalue = 
function(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

-- 对表格中每一个值执行一次指定的函数，并用函数返回值更新表格内容
table.map = 
function(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

-- 对表格中每一个值执行一次指定的函数，但不改变表格内容
table.walk = 
function(t, fn)
    for k,v in pairs(t) do
        fn(v, k)
    end
end

table.filter = 
function(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then t[k] = nil end
    end
end

table.reverseList = 
function (tab)  
    local tmp = {}  
    for i = 1, #tab do  
        local key = #tab  
        tmp[i] = table.remove(tab)  
    end  
    return tmp  
end  

-- 遍历表格，确保其中的值唯一
table.unique = 
function (t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end




TableUtils = {}
--将map转成list
function TableUtils:map2list(map,notInsertNil)
    local list = {}
    if notInsertNil == nil then
        for _, value in pairs(map) do
            table.insert(list,value)
        end
    else
        for _, value in pairs(map) do
            if value ~= nil then
                table.insert(list,value)
            end
        end
    end
    
    return list
end

--打乱数组list
function TableUtils:shuffleList(list)
    local len = #list
    for i = 1, len do
        local randomIndex = math.random(1, len)
        list[i], list[randomIndex] = list[randomIndex], list[i]
    end
end

--一个listview的item有两个甚至跟多相同的子widget需要渲染
--需要把数据重新整理一下，例如:
-- data = {{}, {}, {}, {}}变成
-- data = {{{},{}}, {{}, {}}}
function TableUtils:splitData(info, num)
    if num == 1 or num == nil then
        return info
    end
    local tempInfo = {}
    local index = 1
    for i=1, #info, num do
        tempInfo[index] = tempInfo[index] or {}
        for j=1,num do
            table.insert(tempInfo[index], info[i + j - 1])
        end
        index = index + 1
    end
    return tempInfo

end

local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next

function print_r(root)
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
            else
                tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return tconcat(temp,"\n"..space)
    end
    print(_dump(root, "",""))
    logger:error(_dump(root, "",""))
end

