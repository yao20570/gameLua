--装备升级自定义进度条
local EquipLoadingBar = class("EquipLoadingBar")


--[[参数说明
    loaderBar 原进度条
    url 进度条图片路径
    reSetDefault 动作完成默认设置
]]
function EquipLoadingBar:ctor(data)
	local loaderBar = data.loaderBar
	local url = data.url
    self.reSetDefault = data.reSetDefault
	self:Create(loaderBar, url) 
end

function EquipLoadingBar:Create(loaderBar, url)
    local posx, posy = loaderBar:getPosition()
    local zOrder = loaderBar:getLocalZOrder()
    local parent = loaderBar:getParent()
    local size = loaderBar:getContentSize()
    local color = loaderBar:getColor()
    local opacity = loaderBar:getOpacity()
    local dir = loaderBar:getDirection()
    local ratePos = nil
    local midPoint = nil
    if dir == ccui.LoadingBarDirection.LEFT then
        ratePos = cc.p(1, 0)
        midPoint = cc.p(0, 0)
    else
        ratePos = cc.p(1, 0)
        midPoint = cc.p(1, 0)
    end
    parent:removeChild(loaderBar, true)
    local sprite = TextureManager:createSprite(url)
    local progressTimer = cc.ProgressTimer:create(sprite)
    progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progressTimer:setMidpoint(midPoint)
    progressTimer:setBarChangeRate(ratePos)
    progressTimer:setPercentage(100)
    progressTimer:setPosition(posx, posy)
    progressTimer:setLocalZOrder(zOrder)
    parent:addChild(progressTimer)
    progressTimer:setColor(color)
    progressTimer:setOpacity(opacity)
    self.progressTimer = progressTimer
end

--[[参数说明
    percent 需要到达的进度
    times 所升等级次数
    callfunc 每升一级回调函数
]]
function EquipLoadingBar:runActions(percent,times,callfunc)
    local progressFrom = self.progressTimer:getPercentage()
    local act
    if times == 0 then
        local t = (percent-progressFrom)/100
        if t < 0.5 then
            t = 0.5
        end
        act = cc.ProgressFromTo:create(t, progressFrom, percent)
        act = cc.Sequence:create(act, cc.CallFunc:create(self.reSetDefault))
    elseif times == 1 then
        local act1 = cc.ProgressFromTo:create((100-progressFrom)/100,progressFrom,100)
        local function callBack()
            callfunc(1)
        end
        act1 = cc.Sequence:create(act1, cc.CallFunc:create(callBack))
        local act2 = cc.ProgressFromTo:create(percent/100,0,percent)
        act1 = cc.Sequence:create(act1,act2)
        act = cc.Sequence:create(act1, cc.CallFunc:create(self.reSetDefault))
    elseif times > 1 then
        local index = 1
        local function callBack()
            callfunc(index)
            index = index + 1 
        end
        local act1 = cc.ProgressFromTo:create((100-progressFrom)/100,progressFrom,100)
        local act2 = cc.Sequence:create(act1, cc.CallFunc:create(callBack))
        for i = 2, times + 1 do
            if i ~= times + 1 then
                local act3 = cc.ProgressFromTo:create(1 , 0 ,100)
                act3 = cc.Sequence:create(act3, cc.CallFunc:create(callBack))
                act2 = cc.Sequence:create(act2, act3)
            else
                local act3 = cc.ProgressFromTo:create(percent/100, 0, percent)            
                act2 = cc.Sequence:create(act2,act3)
                act = cc.Sequence:create(act2, cc.CallFunc:create(self.reSetDefault))
            end
        end
    end
    act = cc.EaseSineOut:create(act)
    self.progressTimer:runAction(act)
end

function EquipLoadingBar:getCurrentPercent()
    -- body
    return self.progressTimer:getPercentage()
end

--初始化设置进度
function EquipLoadingBar:setPercentage(percent)
	self.progressTimer:setPercentage(percent)
end

function EquipLoadingBar:stopAllActions()
	self.progressTimer:stopAllActions()
end

return EquipLoadingBar