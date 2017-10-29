module("game.utils", package.seeall)

SoldierUtils = {}

function SoldierUtils:getQualityNameByType(type)
    local name = {"白色","绿色","绿色+1","蓝色","蓝色+1","蓝色+2","紫色","紫色+1","紫色+2","橙色","橙色+1","橙色+2"}
    return name[type] 
end

function SoldierUtils:qualityChange(type) -- num1 返回 0-4 对应框  num2 返回 0-2 对应+几 0则不显示   num3 返回颜色
    local color = {}
    color[1] = cc.c3b(225,225,225)                 
    color[2] = cc.c3b(17,238,102)
    color[3] = cc.c3b(17,156,238)
    color[4] = cc.c3b(238,17,132)
    color[5] = cc.c3b(238,225,17)
    local string = {}
    string[1] = "白"
    string[2] = "绿"
    string[3] = "蓝"
    string[4] = "紫"
    string[5] = "橙"
    local numTable = {}
    numTable[1] = 0
    numTable[2] = 1
    numTable[4] = 2
    numTable[7] = 3
    numTable[10] = 4
    local num1 = 0
    local num2 = 0
    if type == 1 or type == 2 or type == 4 or type == 7 or type == 10 then
        num1 = numTable[type]
        num2 = 0
    elseif type == 3 or type == 5 or type == 8 or type == 11 then
        num1 = numTable[type-1]
        num2 = 1
    elseif type == 6 or type == 9 or type == 12 then
        num1 = numTable[type-2]
        num2 = 2
    end
    local num3 = color[num1+1]
    local num4 = string[num1+1]
    if num2 ~= 0 then 
        num4 = num4 .. "+" .. num2
    end
    return num1,num2,num3,num4
end