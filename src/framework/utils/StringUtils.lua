--[[
字符串帮助类，基于cocos2dx 3.0
]]
StringUtils        = {}

--function StringUtils:splitString(strSrc, sep)
--    local strArray = {}
--    if strSrc == nil then
--        return nil
--    end
--    local str = strSrc
--    local len = string.len(str)
----    local keyLen = string.len(sep)
--    local tempStr = ""
--    local index = 1
--    for i = 1, len do
--        local subStr = string.sub(str, i, i)
--        if subStr == sep then
--            strArray[index] = tempStr
--            index = index + 1
--            tempStr = ""
--        else
--            tempStr = tempStr..subStr
--        end
--
--        if i == len then
--            strArray[index] = tempStr
--        end
--    end
--    return strArray
--end

--返回一个fixed64位是否为0
function StringUtils:isFixed64Zero(fix64)
    local num = self:fined64ToAtom(fix64)
    --4294967295是后台公告id  0是系统公告id
    return num.high == 0 and num.low == 0 
end

--返回一个fixed64位是否小于0
function StringUtils:isFixed64Minus(fix64)
    local id = string.byte(fix64,8)
    return id == 255
end

function StringUtils:isGmNotice(fix64)
    local num = self:fined64ToAtom(fix64)
    return num.high == 4294967295 and num.low == 4294967295
end

function StringUtils:fixed64ToNormalStr(fix64)
    local byteArray = ByteArray.new()
    byteArray:writeBytes(string.reverse(fix64))
    local high = byteArray:readInt()
    local low = byteArray:readInt()
    
    return high .. "_" .. low
end

function StringUtils:fined64ToAtom(fix64)
    local byteArray = ByteArray.new()
    byteArray:writeBytes(string.reverse(fix64))
    local high = byteArray:readInt()
    local low = byteArray:readInt()
    
    
    return {high = high, low = low}
end

function StringUtils:fixed64ToServerId(fix64)
    local byteArray = ByteArray.new()
    byteArray:writeBytes(string.reverse(fix64))
    local high = byteArray:readInt()
    local low = byteArray:readInt()
    --return {high = high, low = low}

    local int64 = math.floor(high * 2^32 + low + 0.5)

    local serverId = math.floor(int64 / 2 ^ 36 + 0.5)

    return serverId
end

function StringUtils:int32ToFixed64(int32)
 
    local byteArray = ByteArray.new()
    byteArray:writeInt(int32)
    byteArray:writeInt(0)
    local fix64 = byteArray:toString()
    return fix64
end

function StringUtils:int64ToFixed64(int64)
    local high = math.floor(int64 / 2^32)
    local low = math.floor(int64 % 2^32 + 0.5)
    local byteArray = ByteArray.new()
    byteArray:writeInt(high)
    byteArray:writeInt(low)
    local str = byteArray:readBytes(8)
    local fix64 = string.reverse(str)
    return fix64
end

--通过属性ID，来格式化输入的数字
function StringUtils:formatNumberByK(num, attrId)
    if num == nil then
        return ""
    end
    local isMinus = false
    num = tonumber(num)
    if num < 0 then
        isMinus = true
        num = 0 - num
    end
    
    local divider = 1
    local unit = ""
    
    if num > 999999999 then
        divider = 1000000000
        unit = "G"
    elseif num > 999999 then
        divider = 1000000
        unit = "M"
    elseif num > 999 then
        divider = 1000
        unit = "K"
    end
    
    local str = ""
    local value = num / divider
    if divider > 1 then
        str = string.format("%.1f%s",value, unit)
    else
        str = math.floor(value) .. ""
    end
    if isMinus == true then
        str = "-"..str
    end
    return str
end

-- 2015-12-17 10:03:31 add by fzw 
--通过属性ID，来格式化输入的数字（仓库储备只显示3个数字）
function StringUtils:formatNumberByK3(num, attrId)
    if num == nil then
        return ""
    end
    num = tonumber(num)
    
    local divider = 1
    local unit = ""
    
    if num > 999999999 then
        divider = 1000000000
        unit = "G"
    elseif num > 999999 then
        divider = 1000000
        unit = "M"
    elseif num > 999 then
        divider = 1000
        unit = "K"
    end
    
    local str = ""
    local value = num / divider
    if divider > 1 then
        if value > 99 then
            str = string.format("%3.0f%s",value, unit)
            elseif value > 9 then
                str = string.format("%2.1f%s",value, unit)
                else
                str = string.format("%1.2f%s",value, unit)
                end
    else
        str = value .. ""
    end
    
    return str
end

function StringUtils:formatNumberByK4(num)
    if num == nil then
        return ""
    end
    num = tonumber(num)

    local divider = 1
    local unit = ""

    if num > 999999999 then
        divider = 1000000000
        unit = "G"
    elseif num > 999999 then
        divider = 1000000
        unit = "M"
    elseif num > 9999 then
        divider = 1000
        unit = "K"
    end

    local str = ""
    local value = num / divider
    if divider > 1 then
        if value > 99 then
            str = string.format("%3.0f%s", value, unit)
        elseif value > 9 then
            str = string.format("%2.1f%s", value, unit)
        else
            str = string.format("%1.2f%s", value, unit)
        end
    else
        str = value .. ""
    end

    return str
end

--//null num值格式化 
function StringUtils:formatNumberByGMKFloor(num)
      if num == nil then
        return ""
    end
    num = tonumber(num)

    local divider = 1
    local unit = ""

    if num > 999999999 then
        divider = 1000000000
        unit = "G"
    elseif num > 999999 then
        divider = 1000000
        unit = "M"
    elseif num > 9999 then
        divider = 1000
        unit = "K"
    end

    local str = ""
    local value =math.floor( num / divider)
    if divider > 1 then
        if value > 99 then
            str = string.format("%3.0f%s", value, unit)
        elseif value > 9 then
            str = string.format("%2.1f%s", value, unit)
        else
            str = string.format("%1.2f%s", value, unit)
        end
    else
        str = value .. ""
    end

    return str

end

--经验值格式，转化为K  4位  向下取整
function StringUtils:formatNumberByK4Floor(num)
    if num == nil then
        return ""
    end
    num = tonumber(num)

    local unit = ""
    local str = ""
    local value
    if num > 999999 then
        --7位以及以上
        value = math.floor(num / 1000) 
        unit =  "K"
        str = string.format("%.0f%s",value, unit)
    elseif num > 99999 then
        --6位
        value = math.floor(num / 100) 
        value = value / 10
        unit =  "K"
        str = string.format("%.1f%s",value, unit)
    elseif num > 9999 then
        --5位
        value = math.floor(num / 10) 
        value = value / 100
        unit =  "K"
        str = string.format("%.2f%s",value, unit)
    elseif num > 999 then
        --4位
        value = math.floor(num) 
        value = value / 1000
        unit =  "K"
        str = string.format("%.3f%s",value, unit)
    else
        --3位以及以下
        value = math.floor(num) 
        unit =  ""
        str = string.format("%.0f%s",value, unit)
    end
    return str
end
--经验值格式，转化为K  4位  向上取整
function StringUtils:formatNumberByK4Ceil(num)
    if num == nil then
        return ""
    end
    num = tonumber(num)

    local unit = ""
    local str = ""
    local value
    if num > 999999 then
        --7位以及以上
        value = math.ceil(num / 1000) 
        unit =  "K"
        str = string.format("%.0f%s",value, unit)
    elseif num > 99999 then
        --6位
        value = math.ceil(num / 100) 
        value = value / 10
        unit =  "K"
        str = string.format("%.1f%s",value, unit)
    elseif num > 9999 then
        --5位
        value = math.ceil(num / 10) 
        value = value / 100
        unit =  "K"
        str = string.format("%.2f%s",value, unit)
    elseif num > 999 then
        --4位
        value = math.ceil(num) 
        value = value / 1000
        unit =  "K"
        str = string.format("%.3f%s",value, unit)
    else
        --3位以及以下
        value = math.ceil(num) 
        unit =  ""
        str = string.format("%.0f%s",value, unit)
    end
    return str
end

------
-- 分割字符返回table表
function StringUtils:jsonDecode(str)
    if str == nil then
        logger:error("错误：jsonDecode参数为nil ") 
    end

    if self._tempMap == nil then
        self._tempMap = {}
    end
    if self._tempMap[str] ~= nil then
        return self._tempMap[str]
    end
    require("json")
    local data = json.decode(str)
    self._tempMap[str] = data
    return data
end

StringUtils.h2b = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["A"] = 10,
    ["B"] = 11,
    ["C"] = 12,
    ["D"] = 13,
    ["E"] = 14,
    ["F"] = 15
}

function StringUtils.hex2bin( hexstr )
    local s = string.gsub(hexstr, "(.)(.)%s", function ( h, l )
         return string.char(StringUtils.h2b[h]*16+StringUtils.h2b[l])
    end)
    return s
end

function StringUtils.bin2hex(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X ",string.byte(x)) end)
    return s
end

--协议体加码 返回字符串
function StringUtils:protoEncode(protoName, data)
    local msg = protobuf.encode(protoName , data)
    local key = StringUtils.bin2hex(msg)
    print("key============",key)
    return key
end

--协议体解码 返回table
function StringUtils:protoDecode(protoName, msg)
    local key = StringUtils.hex2bin(msg)
    print("key============",key)
    local data = protobuf.decode(protoName , key)
    return data
end

--[[
分隔字符串，返回分隔后的table
str:(string) 分隔字符串
delimiter:(string) 分隔符
--]]
function string.split(str, delimiter, func)
    str = tostring(str)
    delimiter = tostring(delimiter)
    if (delimiter == '') then return false end
    local pos, arr = 0, { }
    -- for each divider found
    for st, sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, func and func(string.sub(str, pos, st - 1)) or string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, func and func(string.sub(str, pos)) or string.sub(str, pos))
    return arr
end

function StringUtils:splitString(szFullString, szSeparator)
    local sep, fields = szSeparator or "\t", {}
    local pattern = string.format("([^%s]+)", sep)
    szFullString:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields

end

function StringUtils:getHtmlByLines(lines)
    local contentList = {}
    for _, line in pairs(lines) do
        local index = 0
        for _, col in pairs(line) do
            local content = col.content
            local foneSize = col.foneSize or 22
            local color = col.color or "#ffffff"

            index = index + 1
            local text = ""
            if index == #line then
                text = string.format([[<font face="fn%d" color = "%s">%s<br/></font>]], foneSize, color, content) 
            else
                text = string.format([[<font face="fn%d" color = "%s">%s</font>]], foneSize, color, content) 
            end

            table.insert(contentList,text) 
        end
    end

    local texts = table.concat(contentList, "")
    return texts
end

--拆开中英字符，返回table
--例子 str = "12我我"
--ret = {"1", "2", "我", "我"}
function StringUtils:separate(str)
    local function SubUTF8String(s, n)  
    local dropping = string.byte(s, n+1)  
        if not dropping then
            return s 
        end  
        if dropping >= 128 and dropping < 192 then  
            return SubUTF8String(s, n-1)  
        end  
        return string.sub(s, 1, n)  
    end  

    local i = 1
    local lastStr = ""
    local curStr = ""
    local ret = {}
    while i <= #str do
        curStr = SubUTF8String(str,i)
        if lastStr ~= curStr then
            table.insert(ret,string.sub(curStr,string.len(lastStr)+1))
            lastStr = curStr
        end
        i = i + 1
    end
    return ret
end

--检测字符串
--不管中英文，最多2-5个字符
local minNum = 2
local maxNum = 5

function StringUtils:checkString(str, minSize, maxSize)
    minSize = minSize or minNum
    maxSize = maxSize or maxNum
    local allStr = self:separate(str)
    local len = #allStr
    return (len >= minSize and len <= maxSize)
    -- local function isCn(param)
    --     return param:byte() > 128
    -- end
    -- local curSize = 0
    -- local curCnNum = 0
    -- local curEnNum = 0
    -- for k,v in pairs(allStr) do
    --     if isCn(v) then
    --         curCnNum = curCnNum + 1
    --         curSize = curSize + 2
    --     else
    --         curEnNum = curEnNum + 1
    --         curSize = curSize + 1
    --     end
    -- end
    -- if curSize > maxSize or curSize < minSize then
    --     return false
    -- end
    -- if curCnNum > maxCnNum or curEnNum > maxEnNum then
    --     return false
    -- end
    -- return true
end


--检测字符串大小
--中文单2个字符
--minSize 最小字符数
--maxSize 最大字符数
function StringUtils:checkStringSize(strSrc, minCharSize, maxCharSize)
    return self:checkString(strSrc, minCharSize, maxCharSize)
    -- local size, charSize = self:getStringSize(strSrc)
    -- local curSize = charSize + (size - charSize) * 2
    -- local flag = false
    -- if curSize >= minCharSize and curSize <= maxCharSize then
    --     flag = true
    -- end
    -- return flag
end

function StringUtils:checkStringLenght(str, minSize, maxSize)
    minSize = minSize or 1
    maxSize = maxSize or 1
    local allStr = self:separate(str)
    local len = #allStr
    return (len >= minSize and len <= maxSize)
end

--检测字符串是否含有有效字符
function StringUtils:checkStringValid(strSrc)
    local invalidList = {'&', '#', ' ', '　'}
    local flag = true
    for _, invalid in pairs(invalidList) do
        if string.find(strSrc,invalid) ~= nil then
            flag = false
            break
        end
    end
    return flag
end

--分别获取Asc uft8的长度
function StringUtils:getStringSize(strSrc)
    local size = 0
    local charSize = 0
    local str = strSrc
    local len = string.len(strSrc)
    local isWchar = false
    local offset = 1
    for i = 1, len do
        local byte = string.byte(str, i)
        if byte >= 224 then
            isWchar = true
            offset = i
        elseif isWchar == false and byte <= 127 then
            offset = i
            charSize = charSize + 1
        end

        if isWchar == true then
            if i - offset == 2 then
                isWchar = false
            end
        end

        if isWchar == false then
            size = size + 1
        end
    end
    return size, charSize
end

function StringUtils:calcStringDimension(text, fontSize, dimenWidth)
    local dimenSize = cc.size(dimenWidth, 20)
    local size = 0
    local charSize = 0
    size,charSize = self:getStringSize(text)
    local tempSize = fontSize / 2
    dimenSize.height = math.ceil(((size - charSize) * 2 + charSize) / (dimenWidth / tempSize)) --向上取整
    dimenSize.height = dimenSize.height * fontSize
    return dimenSize
end

function StringUtils:getStringWidth(text, fontSize)
    local size = 0
    local charSize = 0
    size,charSize = self:getStringSize(text)
    local width = (size - charSize) * fontSize + charSize * fontSize / 2
    return width
end

function StringUtils:getHeightFromString(text, fontSize, dimenWidth)
    text = text or ""
    local size = 0
    local str = text
    local charSize = 0
    local len = string.len(text)
    size,charSize = self:getStringSize(text)
    local textSize = len
    local line = 1
    local p = 0
    local index = 0
    local isWchar = false --是否是中文字符
    local offset = 1  --访问字符串的偏移量
    
    for index=1,len do
        local byte = string.byte(str, index)
        if byte >= 224 then
            isWchar = true
            offset = index
        elseif isWchar == false and byte <= 127 then
            offset = index
        end
        
        if isWchar == true then
            if index - offset == 2 then
                isWchar = false
            end
        end
        if isWchar == false then
            if index <= textSize then 
                local subStr = string.sub(text, offset, index)
                local add = fontSize
                if index - offset ~= 2 then
                    add = add/2.5
                end
                if subStr == "\n" then
                    line = line +1
                    p = fontSize
                elseif p+add > dimenWidth then
                    line = line+1
                    p = fontSize
                else
                    p = p+add
                end
            end
        end
    end
    return line*fontSize*1.2
end

function StringUtils:stringParse(strSrc, tableStrDest, tableSpacePos)
    local str = strSrc
    local outStr = ""
    local charSize = 0
    local totalSpaceCount = 0
    require "cross/utility/structure/deque"
    local strQueue = cQueue()
    local len = string.len(str)
    --print("########## : ", len)
    local isPush = false
    local index = 1
    local isWchar = false --是否是中文字符
    local offset = 1  --访问字符串的偏移量
    local spaceCount = 0
    local subStr = ""
    for i = 1, len do
        local byte = string.byte(str, i)
        --print("byte------>", byte)
        --224为utf8编码中，中文字符占用的第一个字节的高三位为1的值，
        --表示该中文字符占3个字节
        if byte >= 224 then
            isWchar = true
            offset = i
        elseif isWchar == false and byte <= 127 then
            offset = i
        end

        if isWchar == true then
            if i - offset == 2 then
                isWchar = false
                --print("isWchar : ", isWchar)
            end
        end

        --当不是宽字符时，或访问到一个宽字符需要再访问2个字节之后，执行
        if isWchar == false then
            subStr = string.sub(str, offset, i)
            if subStr == "[" then
                isPush = true
            elseif subStr == "]" then
                isPush = false
            else
                if isPush == false then
                    outStr = outStr..subStr
                    if byte <= 127 then
                        charSize = charSize + 1
                    end
                end
            end


            if isPush == true then
                strQueue:push_back(subStr)
                --print("subStr", strStack.top)
            elseif isPush == false and strQueue:size() > 0 then
                --print("can not push", isPush)
                local size = strQueue:size()
                --print("size", size)
                local destStr = ""
                local flag = false --是否是中文字符的标记
                spaceCount = 0
                for j = 1, size do
                    local tempStr = strQueue:pop_front()
                    --print("tempStr : ", tempStr)
                    if tempStr ~= "#" then
                        if tempStr ~= "[" then 
                            destStr = destStr..tempStr
                            if flag == false then
                                outStr = outStr.." "
                                spaceCount = spaceCount + 1
                            else
                                outStr = outStr.."  "
                                spaceCount = spaceCount + 2
                                flag = false
                            end
                        end
                    else
                        --#表示为中文字符
                        flag = true
                    end
                end
                --print("destStr : ", destStr)
                --destStr = string.reverse(destStr)
                tableStrDest[index] = destStr
                local outStrLen = string.len(outStr)
                tableSpacePos[index] = outStrLen - spaceCount
                totalSpaceCount = totalSpaceCount + spaceCount
                index = index + 1
                strQueue:clear()
            end         
        end
    end
    return outStr, charSize, totalSpaceCount
end

function StringUtils:utf8Len(str)
    
    local utfstrlen = self:utfstrlen(str)
    local asciilen = self:asciiLen(str)
    
    local len = (utfstrlen - asciilen) + math.ceil(asciilen / 2) 
    
    return len
end

--含有ascii的长度
function StringUtils:asciiLen(str)
    local asciiLen = 0
    local len = #str
    for index=1, len do
        local tmp=string.byte(str,index)
        if tmp <= 127 then
            asciiLen = asciiLen + 1
        end
    end
    
    return asciiLen
end

--utf8总长度
function StringUtils:utfstrlen(str)
    local len = #str
    local left = len
    local cnt = 0
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}
    while left ~= 0 do
        local tmp=string.byte(str,-left)
        local i=#arr
        while arr[i] do
            if tmp>=arr[i] then 
                left=left-i
                break
            end
            i=i-1
        end
        cnt=cnt+1
    end
    return cnt
end


function StringUtils:splitUtf8String(strSrc, sep)
    local strDic = {}
    local str = strSrc
    local len = string.len(strSrc)
    local isWchar = false
    local isSWchar = false
    local offset = 1
    local index = 1
    local tempStr = ""
    for i = 1, len do
        local byte = string.byte(str, i)
        if byte >= 224 then
            isWchar = true
            offset = i
        elseif isWchar == false and isSWchar == false and byte > 127 then
            isSWchar = true
            offset = i
        elseif isWchar == false and byte <= 127 then
            offset = i
        end

        if isWchar == true then
            if i - offset == 2 then
                isWchar = false
            end
        end
        
        if isSWchar == true then
            if i - offset == 1 then
                isSWchar = false
            end
        end

        if isWchar == false and isSWchar == false then
            local subStr = string.sub(str, offset, i)
            if subStr == sep  then
                strDic[index] = tempStr
                index = index + 1
                tempStr = ""
            elseif sep == "" then
                strDic[index] = subStr
                index = index + 1
                tempStr = ""          
            else
                tempStr = tempStr..subStr
            end

            if i == len then
                strDic[index] = tempStr
            end
        end
    end
    return strDic
end
-----------------------------------------------------
--用空格充满有换行符的那一行，这样富文才不会变成一块一块
-----------------------------------------------------
function StringUtils:getFullSpaceToRichElement(text ,fontSize,weight,nowSize)
    local str = self:splitUtf8String(text,"\n")
    local result = {}
--    local weight = label:getContentSize()["width"]
--    local fontSize = label._fontSize
    local lineSize = nowSize
    local changeLine=true
    if #str == 1 then
        changeLine=false
    end
    -- 如果有\n的话返回的应该是一个table
    for i,s in pairs(str) do
        
        local isWchar = false
        local offset = 1
        local len = string.len(s)
        
        --获取每行，然后计算出该行还剩下多少空间，用空格补上
        for j=1,len do
            local byte = string.byte(s, j)
            if byte >= 224 then
                isWchar = true
                offset = j
            elseif isWchar == false and byte <= 127 then
                offset = j
            end
            if isWchar == true then
                if j - offset == 2 then
                    isWchar = false
                end
            end
            if isWchar == false then
                if j <= len then 
                    local subStr = string.sub(text, offset, j)
                    local add = fontSize
                    if j - offset ~= 2 then
                        add = add/2
                    end
                    lineSize = lineSize + add
                end
            end
        end
        local lineStr = s
        if lineSize > weight then
            lineSize = lineSize % weight
            if lineSize == 0 then
                lineSize = weight
            end
        end
        if i ~= #str and changeLine then
            while lineSize < weight do
                if lineSize + fontSize <= weight then
                    lineStr = lineStr .."　"
                    --                lineStr = lineStr .."＿"
                end
                lineSize = lineSize + fontSize
            end
--        elseif lineStr ~= "" then --不是以\n结尾的要把换行符加回来
--            lineStr = "\n".. lineStr
        end
        table.insert(result,lineStr)
    end
    local res = ""
    for _,rStr in pairs(result) do
        res = res .. rStr
    end
    return res,lineSize
end


function StringUtils:getStringAddBackEnter(str,num)
    if str ~= nil then
        num = num or 20
        local newInfoTable = {}
        local info  = clone(str)
        local list = self:splitString(info,"\n")
        local index = 1
        for _,value in pairs(list) do
            if value ~= nil and value ~= "" then
                if index ~= 1 then
                    table.insert(newInfoTable, "\n")
                end
                local strArray = self:splitUtf8String(value or "", "")
                local count = 0
                local acount = 0
                for index = 1, #strArray do
                    local char = strArray[index]
                    if string.len(char) > 1 then --中文
                        count = count + 1
                    else
                        acount = acount + 1
                        if acount % 2 == 0 then
                            count = count + 1
                            acount = 0
                        end
                    end
                    table.insert(newInfoTable, strArray[index])
                    if count > 0 and count % num == 0 then
                        table.insert(newInfoTable, "\n")
                        count = 0
                    end
                end
                index = index + 1
            end
        end
        local newInfoStr = table.concat(newInfoTable)
        return newInfoStr
    end
    return ""
end

function StringUtils:getStringAddBackEnterAndLine(str,num)
    if str ~= nil then
        num = num or 20
        local newInfoTable = {}
        local info  = clone(str)
        local list = self:splitString(info,"\n")
        local index = 1
        local line = 1
        for _,value in pairs(list) do
            if value ~= nil and value ~= "" then
                if index ~= 1 then
                    table.insert(newInfoTable, "\n")
                    line = line + 1
                end
                local strArray = self:splitUtf8String(value or "", "")
                local count = 0
                local acount = 0
                for index = 1, #strArray do
                    local char = strArray[index]
                    if string.len(char) > 1 then --中文
                        count = count + 1
                    else
                        acount = acount + 1
                        if acount % 2 == 0 then
                            count = count + 1
                            acount = 0
                        end
                    end
                    table.insert(newInfoTable, strArray[index])
                    if count > 0 and count % num == 0 then
                        table.insert(newInfoTable, "\n")
                        line = line + 1
                        count = 0
                    end
                end
                index = index + 1
            end
        end
        local newInfoStr = table.concat(newInfoTable)
        return newInfoStr, line
    end
    return "", 1
end

--增加下划线 文本
function  StringUtils:getStringOutline(str)
    local strAry = self:splitUtf8String(str, "")
    local content = table.concat(strAry, "&")
    return content
end

function StringUtils:isEmotion(content, maxEmotionNum)
    local flag = false
    local emotion = nil
    local index = string.find(content, "emotions")
    if index ~= nil then
        flag = true
    end
    if flag == true then
        content = string.gsub(content,"emotions","")
        emotion = tonumber(content)
    end
    
    if flag == true  and (emotion == nil or emotion <= 0 or emotion > maxEmotionNum ) then
        flag = false
    end
    
    return flag, emotion
end

--返回万 单位格式
function StringUtils:getWFormat(num)
    local str 
    if num > 1000 then
        str = string.format("%0.1f", num / 10000)  .. "W"
    else
        str = num .. ""
    end
    return str
end

--& , 二级分割
function StringUtils:customSplit(str)
    local listTable = {}
    local list = self:splitString(str,"&")
    if list == nil then
        list = self:splitString(str,"&")
    end
    local len = #list
    for index = 1, len do
        local strin = list[index]
        local list2 = self:splitString(strin,",")
        if list2 == nil then
            list2 = self:splitString(str,"，")
        end
        listTable[list2[1]] = list2[2]
    end
    return listTable
end

function StringUtils:getFullName(name)
    local showLen = 8  --显示5个字符，后面的用...代替  英文字符当做半个字符
    local changeNameList = {}
    local curNameLen = 0
    local isFullName = false
    local charAry = self:splitUtf8String(name,"")
    local charLen = #charAry
    local index = 1
    for _, char in pairs(charAry) do
    	if char ~= "" then
            local byte = string.byte(char, 1)
            if byte <= 127 then
                curNameLen = curNameLen + 0.5
            else
                curNameLen = curNameLen + 1
            end
            table.insert(changeNameList, char)
            
            if curNameLen >= showLen and index < charLen - 1  then
                isFullName = true
                break
            end
            
            index = index + 1
    	end
    end
    if isFullName == true then
        table.insert(changeNameList, "...")
    end
    local fullName = table.concat(changeNameList)
    return fullName
end

--截取限制的字符长度 size是汉字宽
function StringUtils:formatShortContent(content, size)
    local result = ""
    local contentAry = self:splitUtf8String(content, "")
    local curLen = 0
    for _, char in pairs(contentAry) do
    	if char == "" then
    	elseif self:isUtf8Word(char) == true then
    	    curLen = curLen + 1
    	else
            curLen = curLen + 0.5
    	end
        result = result .. char
    	if curLen >= size then
    	    break
    	end
    end
    
    return result
end

function StringUtils:isUtf8Word(word)
    local byte = string.byte(word, 1)
    if byte == nil then
         print("")
    end
    return byte > 127
end

--格式化表情内容
function StringUtils:formatMsgForEmotion(context)
    
    local newMsg = ""
    local config = ConfigDataManager:getConfigData(ConfigData.ChatFaceConfig)
    for _, info in pairs(config) do
        local msgAry = string.split(context,info.faceinstead)
        if #msgAry > 1 then
            for i= 1, #msgAry do
            	if i ~= #msgAry then
            	    local html = [[<img src="bg/face/face_%d.png" />]]
                    local htmlstring = string.format(html,info.iconID)
                    newMsg = newMsg .. msgAry[i] .. htmlstring
            	else
            	    newMsg = newMsg .. msgAry[i]
            	end
            end
        end
        if newMsg ~= "" then
            context = newMsg
        end
        newMsg = ""
    end
    
    return context

end

function StringUtils:getEmotionUrl(context)
    local flag = false
    local url = ""
    local config = ConfigDataManager:getConfigData(ConfigData.ChatFaceConfig)
    for _, info in pairs(config) do
        local msgAry = string.split(context,info.faceinstead)
        if #msgAry > 1 then
            for i= 1, #msgAry do
                if i ~= #msgAry then
                    local html = "images/faceIcon/%d.png"
                    url = string.format(html,info.iconID)
                    flag = true
                    break
                end
            end
        end
    end

    return flag, url
end

function StringUtils:getEmotionCount(context)
    local count = 0
    local config = ConfigDataManager:getConfigData(ConfigData.ChatFaceConfig)
    for _, info in pairs(config) do
        local msgAry = string.split(context,info.faceinstead)
        if #msgAry > 1 then
            for i= 1, #msgAry do
                if i ~= #msgAry then
                    count = count + 1
                end
            end
        end
    end
    return count
end

function StringUtils:formatA()
end

function StringUtils:coutStrWidth(str)
    local width = 0
    local i = 1
    while i <= #str  do
       c = str:sub(i,i)
       ord = c:byte()
       if ord > 128 then
          -- table.insert(tblStr,str:sub(i,i+2))
          width = width + 27
          i = i+3
       else
          -- table.insert(tblStr,c)
          width = width + 14
          i=i+1
       end
    end
    return width
end

------
-- 打印key数值
function StringUtils:printKey(data)
    if #data == 0 then return end
    for k, v in pairs(data) do
        print(k.."======================")
    end
end

--竖排版，每个字加\n
function StringUtils:getVerticalString(str)
    return self:getStringAddBackEnterAndLine(str, 1)
end

------
-- 通用的数字滚动方法
-- @param  nodeTxt [obj] 文本node
-- @param  targetNum [int] 目标值
-- @param  nowNum [int] 当前值，nil时默认为0
-- @param  times [int] 变化次数，nil时默认为10
-- @param  stepTime [int] 单位变化周期单位毫秒，nil时默认为0.02秒
-- @param  addStr [str] 末尾额外的字段
function StringUtils:rollToTargetNum(nodeTxt, targetNum, nowNum, times, stepTime, addStr)
    times = times or 10 -- 默认10次
    stepTime = stepTime or 0.02*1000 -- 默认每次变化时间
    nowNum = nowNum or 0 -- 是否从0开始
    addStr = addStr or ""
    local diff = targetNum - nowNum
    local stepNum = math.floor(diff/times)
    local function setNum()
        if times > 0 then
            nowNum = nowNum + stepNum
            nodeTxt:setString(nowNum..addStr)
            times = times - 1
            TimerManager:addOnce(stepTime, setNum, self)
        else
            nodeTxt:setString(targetNum..addStr)
            TimerManager:remove(setNum, self)
        end
    end
    setNum()
end

--nNum保留小数点后n位
function StringUtils:getPreciseDecimal(nNum, n)
    local num = tonumber(nNum)
    if num == nil then
        return nNum
    end
    
    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, num))

    return nRet
end

--特殊处理StrategicsLvConfig表里面的info信息的血量和攻击要乘以带兵量
--主要的目的就是  把"提升2阶及以上兵种#30#,#50#"这段文字里面的30和50都乘以带兵量
--返回  "提升2阶及以上兵种300,500" 这段字符串  假设带兵量是10
--这里 identity传的是"%b##"
function StringUtils:getSymmetricStr(str, identity, percent)
    for w in string.gfind(str, identity) do
        local b = string.gsub(w, "#", "")
        local num = tonumber(b)
        num = num * percent
        str = string.gsub(str, w, num)
    end
    return str
end

--首字符小写
function StringUtils:toLowerCaseFirstOne(str)
    return string.lower(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

--复制多少份 str
function StringUtils:copyString(str, len)
    local t = {}
    for i=1,len do
        table.insert(t, str)
    end
    return table.concat(t, "")
end

-- 删除字符串首尾空格、\t、\n
function StringUtils:trim (s) 
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end
--字符串转换成table
function StringUtils:toTable (s) 
    return loadstring("return function() return " .. s .. " end" )()()
end

-- table to string 
function StringUtils:serialize(tab)  
    local str = ""  
    local t = type(tab)  
    if t == "number" then  
        str = str .. tab  
    elseif t == "boolean" then  
        str = str .. tostring(tab)  
    elseif t == "string" then  
        str = str .. string.format("%q", tab)  
    elseif t == "table" then  
        str = str .. "{\n"  
    for k, v in pairs(tab) do  
        str = str .. "[" .. self:serialize(k) .. "]=" .. self:serialize(v) .. ",\n"  
    end  
    local metatable = getmetatable(tab)  
        if metatable ~= nil and type(metatable.__index) == "table" then  
        for k, v in pairs(metatable.__index) do  
            str = str .. "[" .. self:serialize(k) .. "]=" .. self:serialize(v) .. ",\n"  
        end  
    end  
        str = str .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return str  
end  

-- string to table
function StringUtils:unserialize(str)  
    local t = type(str)  
    if t == "nil" or str == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        str = tostring(str)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    str = "return " .. str  
    local func = loadstring(str)  
    if func == nil then  
        return nil  
    end  
    return func()  
end 
