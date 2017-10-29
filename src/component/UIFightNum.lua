
UIFightNum = class("UIFightNum")

function UIFightNum:ctor(parent)
	self._uiSkin = UISkin.new("UIFightNum")
	self._uiSkin:setTouchEnabled(false)
    self._uiSkin:setLocalZOrder(100)
    self._uiSkin:setParent(parent)
    self._parent = parent
    -- 加入的层级
    self._addPanel = self:getChildByName("mianPanle/dowmNum")
    self._mianPanle = self:getChildByName("mianPanle")
end

function UIFightNum:hide()
	self._uiSkin:setVisible(false)
end

function UIFightNum:show()
	self._uiSkin:setVisible(true)
end

function UIFightNum:setPosition(x,y)
	self._mianPanle:setPosition(x,y)
end

function UIFightNum:finalize()
  	self._uiSkin:finalize()
    for k,v in pairs(self) do
        self[key] = nil
    end
end

function UIFightNum:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end
-- 删除
function UIFightNum:removeFromParent(parent)
	parent:removeChild(self._uiSkin, true)
end

function UIFightNum:setPowerNum(pos, powerNum )
    self._pos = pos
    self._powerNum = powerNum
    self._textAtlas = ccui.TextAtlas:create()
    self._textAtlas:setAnchorPoint(cc.p(0, 0))
    self._textAtlas:setProperty("1234567890", "ui/images/fonts/num_small.png", 24, 30, "0")
    self._textAtlas:setPosition(pos*25 + 20 , -23)
    self._textAtlas:setVisible(true)
    self._textAtlas:setString(powerNum)
    self._parent:addChild( self._textAtlas)
end

function UIFightNum:getAtlas()
    return self._textAtlas
end

function UIFightNum:setAtlasString(str)
    if str ~= nil then
        self._textAtlas:setString(str)
    end
end

function UIFightNum:setAtlasVisible(state)
    self._textAtlas:setVisible(state)
end
-- 返回旧的值
function UIFightNum:getOldNum()
    return self._powerNum 
end

----------------------------------------------------------------------
UIFightNumGroup = class("UIFightNumGroup")
UIFightNumGroup.STEP_COUNT = 3
UIFightNumGroup.STEP_TIME  = 0.03* 1000
----- 
-- 旧的战力
function UIFightNumGroup:ctor(parent, oldPower, newPower)
	self._parent = parent 
	-- 获取构建数字列表
    self._oldPowerList = self:numChangeList(oldPower)
    self._newPowerList = self:numChangeList(newPower)
    self._biggerSize = 0
    if self._newPowerList:size() > self._oldPowerList:size() then
        self._biggerSize = self._newPowerList:size()
    else
        self._biggerSize = self._oldPowerList:size()
    end
    self._timerList = {}
    -- Atlas类表
    self._numItemList = List.new() 
    -- 一定时间间隔初始化
    self:intOldPower( self._oldPowerList )

end

--统一添加定时器入口，跳过时，统一释放掉定时器，以免出现问题
function UIFightNumGroup:addTimerOnce(delay, func, obj, ...)
    TimerManager:addOnce(delay, func, obj, ...)
    table.insert(self._timerList, {func = func, obj = obj})
end

function UIFightNumGroup:finalize()
    for _, timer in pairs(self._timerList) do
        local func = timer.func
        local obj = timer.obj
        TimerManager:remove(func,obj)
    end
    self:removeFromParent()

    for k,v in pairs(self) do
        if key ~= nil then
            self[key] = nil
        end
    end
end

function UIFightNumGroup:removeFromParent()
	self._parent:removeChild(self._uiSkin, true)
end

------
-- 初始化战力函数
function UIFightNumGroup:intOldPower(powerList)
	for i = 1, self._biggerSize  do
        local uiFightNum
        local function setString()
            uiFightNum = UIFightNum.new(self._parent)
            -- 比旧战力位数多用0补足，且隐藏
            if i > self._oldPowerList:size() then
                uiFightNum:setPowerNum( i , math.random(0, 9) )
                uiFightNum:setAtlasVisible(false)
                self._oldPowerList:pushBack(0)
            else
                uiFightNum:setPowerNum( i ,powerList:at(i) )
            end
            self._numItemList:pushBack(uiFightNum)
            self._parent:addChild(uiFightNum)
            -- 全部加载后，进行变换
            if self._numItemList:size() == self._biggerSize then
                self:addTimerOnce(0.2* 1000, self.startChange, self)
            end
        end
        -- 按顺序初始化，一定的时间间隔
        self:addTimerOnce(0.03 * 1000 *i, setString,self)
    end
end

------
-- 开始变动
function UIFightNumGroup:startChange()
    -- 控制显示
    if self._oldPowerList:size() > self._newPowerList:size() then
        for i = 1, self._oldPowerList:size() do
            if i > self._newPowerList:size() then
                self._numItemList:at(i):setAtlasVisible(false)
            end
        end
    end
    -- 调用控制函数pushToChange
    for i = 1, self._newPowerList:size()  do
        local function pushChange()
            local oldValue = self._oldPowerList:at(i)
            local newValue = self._newPowerList:at(i)
            self:pushToChange(i, oldValue, newValue)
            self._numItemList:at(i):setAtlasVisible(true)
        end
        self:addTimerOnce(0.03 * 1000 *i, pushChange,self)
    end
end

-- 返回战力列表
function UIFightNumGroup:numChangeList(power)
    local powerList = List.new() -- 战力数字表
    local numLen = string.len(tostring(power))
    for i = 1, numLen do
        local numStr = string.sub (tostring(power),i, i) 
        powerList:pushBack(tonumber(numStr) )
	end
    return powerList
end

------
-- 传值
function UIFightNumGroup:pushToChange(index, oldValue, newValue)
    local function trueValue(trueIndex)
        self._numItemList:at(trueIndex):getOldNum()
        local new = self._newPowerList:at(trueIndex)
        local old = self._numItemList:at(trueIndex):getOldNum()
        old = old + UIFightNumGroup.STEP_COUNT 
        local count = 0
        local function setCount()
            old = old + UIFightNumGroup.STEP_COUNT 
            if old >= 10 then
                old = old - 10
            end
            self._numItemList:at(trueIndex):getAtlas():setString(old)  --TODO 这里可能会被释放掉
            if new ~= old then
                count = count + 1
                self:addTimerOnce(UIFightNumGroup.STEP_TIME, setCount, self)
            else
                self._numItemList:at(trueIndex):getAtlas():setString(new)
            end
        end
        setCount()
    end

    -- 预先随机次数
    local times = 1
    local function bengin()
        if times ~= 0 then
            local num = self._numItemList:at(index):getOldNum() + math.random(1, 9)
            if index ~= nil then
                self._numItemList:at(index):setAtlasString(self:toSingle(num))
            end
            times = times - 1
            self:addTimerOnce(UIFightNumGroup.STEP_TIME , bengin,self)
        else
            trueValue(index)
        end
    end
    bengin()
end

-- 转化个位数
function UIFightNumGroup:toSingle(num)
    local singleNum = num
    if singleNum >= 10 then
        singleNum = singleNum - 10
    end
    return singleNum
end

function  UIFightNumGroup:newListSize()
    return self._newPowerList:size()
end