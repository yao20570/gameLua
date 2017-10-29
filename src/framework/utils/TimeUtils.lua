
TimeUtils = {}

----格式： 00:00:00
function TimeUtils:getStandardFormatTimeString(time)
    local hours = math.floor(time / 3600)
    time = time % 3600
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    if hours < 10 then
        hours = "0" .. hours
    end
    if minutes < 10 then
        minutes = "0" .. minutes
    end
    if seconds < 10 then
        seconds = "0" .. seconds
    end
    return hours .. ":" .. minutes .. ":" .. seconds
end

----格式： 0h0m0s
function TimeUtils:getStandardFormatTimeString6(time, isShort)
    local hours = math.floor(time / 3600)
    time = time % 3600
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    
    local str = ""
    if hours <= 0 then
        str = minutes .. "m" .. seconds .. "s"
    else
        str = hours .. "h" .. minutes .. "m"
    end
    
    if isShort ~= true then
        str = hours .. "h" .. minutes .. "m" .. seconds .. "s"
    end

    return str
end

----格式： 0h0m0s
function TimeUtils:getStandardFormatTimeString61(time)
    local hours = math.floor(time / 3600)
    if hours > 0 then
        return hours .. "h"
    end

    time = time % 3600
    local minutes = math.floor(time / 60)
    if minutes>0 then
        return minutes .. "m"
    end

    local seconds = time % 60
    return seconds .. "s"
    
end

--获取时间的价格
function TimeUtils:getTimeCost(time)
    local cost = math.ceil(time / 60)
    return cost
end

--获取通过加速百分比后，获取到的时间
function TimeUtils:getTimeBySpeedRate(time, rate)
    local newTime = math.ceil(time / (1 + rate / 100.0))
    return newTime 
end

---格式： 00 00 00
function TimeUtils:getStandardFormatTimeString5(time)
    local hours = math.floor(time / 3600)
    time = time % 3600
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    if hours < 10 then
        hours = "0" .. hours
    end
    if minutes < 10 then
        minutes = "0" .. minutes
    end
    if seconds < 10 then
        seconds = "0" .. seconds
    end
    return hours , minutes, seconds
end

----格式： xx天xx小时xx分xx秒
function TimeUtils:getStandardFormatTimeString2(time)
    local day = math.floor(time / 86400)
    time = time % 86400
    local hours = math.floor(time / 3600)
    time = time % 3600
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    local str = ""
    if day > 0 then
        str = str .. day .. "天"
    end
    if hours > 0 then
        str = str .. hours .. "小时"
    end
    if minutes >= 0 then
        str = str .. minutes .. "分钟"
    end
--    if seconds > 0 then
--        str = str .. seconds .. "秒"
--    end
    return str
end

----格式：xx小时xx分钟 or xx分钟xx秒
function TimeUtils:getStandardFormatTimeString7(time)
    local hours = math.floor(time / 3600)
    time = time % 3600
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    local str = ""
    if hours > 0 then
        str = str .. hours .. "小时"
        if minutes >= 0 then
            str = str .. minutes .. "分钟"
        end
    else
         if minutes >= 0 then
             str = str .. minutes .. "分钟"
         end
        if seconds >= 0 then
            str = str .. seconds .. "秒"
        end

    end
    return str
end

----格式：xxdxxh or xxhxxm or xxmxxs
function TimeUtils:getStandardFormatTimeString8(time)
    local day = math.floor(time / 86400)
    time = time % 86400
    local hours = math.floor(time / 3600)
    time = time % 3600
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    local str = ""

    if day > 0 then
        str = str .. day .. "d"
        if hours >= 0 then
            str = str .. hours .. "h"
        end
    elseif hours > 0 then
        str = str .. hours .. "h"
        if minutes >= 0 then
            str = str .. minutes .. "m"
        end
    else
         if minutes >= 0 then
             str = str .. minutes .. "m"
         end
        if seconds >= 0 then
            str = str .. seconds .. "s"
        end

    end
    return str
end

function TimeUtils:getStandardFormatTimeString3(time)
    local day = math.floor(time / 86400)
    time = time % 86400
    local hours = math.floor(time / 3600)
    time = time % 3600
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    return day,hours,minutes,seconds
end

----格式：00:00
function TimeUtils:getStandardFormatTimeString4(time)
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    if minutes < 10 then
        minutes = "0" .. minutes
    end
    if seconds < 10 then
        seconds = "0" .. seconds
    end
    return  minutes .. ":" .. seconds
end

function TimeUtils:getCurDateStr()
    local str = os.date("%Y%m%d%H%M%S",os.time())
    return str
end

function TimeUtils:getDateFromCurrentTime()
    local currTime = os.time()
    local year = os.date("%Y", currTime)
    local month = os.date("%m", currTime)
    local day = os.date("%d", currTime)
    local hour = os.date("%H", currTime)
    local minute = os.date("%M", currTime)
    local second = os.date("%S", currTime)

    return year, month, day, hour, minute, second
end

function TimeUtils:getDateStrFromCurTime()
    local year, month, day, hour, minute, second = self:getDateFromCurrentTime()
    local str = year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" .. minute .. ":" .. second
    return str
end

function TimeUtils:getDateFromTime(time)
    time = tonumber(time)
    local year = os.date("%Y", time)
    local month = os.date("%m", time)
    local day = os.date("%d", time)
    local hour = os.date("%H", time)
    local minute = os.date("%M", time)
    local second = os.date("%S", time)

    return year, month, day, hour, minute, second
end

function TimeUtils:getOfflineTime(offlineTime)
    local str = ""
    if offlineTime < 60 then
        str = "刚刚"
    elseif offlineTime < 60 * 60 then
        str = math.floor(offlineTime / 60)  .. "分钟前"
    elseif offlineTime < 60 * 60 * 24 then
        str = math.floor(offlineTime / 60 / 60)  .. "小时前"
    else
        local day =  math.floor(offlineTime / 60 / 60 / 24)
        if day > 30 then
            str = "很久"
        else
            str = day .. "天前"
        end
    end
    
    return "("..str..")"
end

--时间戳转化成11-20 12:20格式
function TimeUtils:setTimestampToString(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
    local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    return  tab.month.."/"..tab.day.." ".. hour ..":".. min
end

function TimeUtils:getTimeStampDate(srcTimestamp)
    local date = os.date("*t",srcTimestamp)
    
    return date.month.."-"..date.day.." "..date.hour..":"..date.min
end

------格式：21:23:23
function TimeUtils:setTimestampToString2(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
    local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    local sec = string.format("%02d",tab.sec)
    return tab.month.."/"..tab.day.." "..hour..":"..min..":"..sec
end

---格式-- 21:35:43  不要年月日
function TimeUtils:setTimestampToString3(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
    local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    local sec = string.format("%02d",tab.sec)
    return hour.. ":" ..min .. ":" .. sec
end

---格式-- 月日 21:35:43  
function TimeUtils:setTimestampToString4(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
    
    local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    local sec = string.format("%02d",tab.sec)
    
    return tab.month.."月"..tab.day.."日"..hour..":"..min
end

--时间戳转化成23:20格式
function TimeUtils:setTimestampToString5(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
    local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    return  hour ..":".. min
end

---格式-- 2016.11.11  11:11:11
function TimeUtils:setTimestampToString6(srcTimestamp)
    if srcTimestamp <= 0 then
        return 0
    end

    local tab = os.date("*t",srcTimestamp)
    local year = string.format("%04d",tab.year)
    local month = string.format("%02d",tab.month)
    local day = string.format("%02d",tab.day)

    local hour = string.format("%02d",tab.hour)
    local min = string.format("%02d",tab.min)
    local sec = string.format("%02d",tab.sec)
    
    return year.."."..month.."."..day.."  "..hour..":"..min..":"..sec
end


----格式：00:00  时:分  分:秒
function TimeUtils:getStandardFormatTimeString9(time)
    -- local day = math.floor(time / 86400)
    time = time % 86400
    local hours = math.floor(time / 3600)
    time = time % 3600
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    local str = ""


    minutes = string.format("%02d",minutes)
    if hours > 0 then
        hours = string.format("%02d",hours)
        str = hours .. ":" .. minutes
    else
        seconds = string.format("%02d",seconds)
        str = minutes .. ":" .. seconds
    end
    return str
end

----时间格式：天+小时；小时+分钟；分钟+秒 三类
function TimeUtils:getStandardFormatTimeString10(time)
    local count = 0
    local day = math.floor(time / 86400)
    time = time % 86400
    local hours = math.floor(time / 3600)
    time = time % 3600
    local minutes = math.floor(time / 60)
    local seconds = time % 60
    local str = ""
    if day > 0 then
        str = str .. day .. "天"
        count = count + 1
        if count == 2 then
            return str
        end
    end
    if hours > 0 then
        str = str .. hours .. "小时"
        count = count + 1
        if count == 2 then
            return str
        end
    end
    if minutes >= 0 then
        str = str .. minutes .. "分钟"
        count = count + 1
        if count == 2 then
            return str
        end
    end
    if seconds > 0 then
        str = str .. seconds .. "秒"
        count = count + 1
        if count == 2 then
            return str
        end
    end
    return str
end
--限时活动显示时间格式 活动时间:****年*月*日**:**————****年*月*日**:**
--isShowTitle为true显示 "活动时间："
function TimeUtils.getLimitActFormatTimeString(startTime,endTime,isShowTitle)
    local str = ""
    local function time2string( time )
        local timeStr = os.date("%Y年%m月%d日%H:%M", time or 0)
        return timeStr
    end
    if isShowTitle == true then
        str = string.format("活动时间：%s—%s",time2string(startTime),time2string(endTime))
    else
        str = string.format("%s—%s",time2string(startTime),time2string(endTime)) 
    end
    return str
end

ClockUtils = {}
--32位系统环境下运行超过一定时间clock返回值溢出导致判断错误
function ClockUtils:getOsClock()
    local curClock = os.clock()
    if curClock < 0 then
        curClock = curClock + 2147.483647
    end
    return curClock
end
