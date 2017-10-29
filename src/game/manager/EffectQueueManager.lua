---特效队列管理器，用来控制各种特效的顺序播放

EffectQueueType = {}
EffectQueueType.LEVEL_UP = 1 --升级特效
EffectQueueType.GET_REWARD = 2 --道具获得
EffectQueueType.TREASURE_ADVANCE = 3 --宝具进阶
EffectQueueType.CAPACTITY = 4 --战力特效
EffectQueueType.DUNGEON_STAR = 5 --副本星星
EffectQueueType.GET_REWARD_LIST = 6 --道具获得
EffectQueueType.UNLOCK = 7 --功能解锁
EffectQueueType.GET_HERO = 8 --武将获得
EffectQueueType.MessageBox = 9 --弹出二次确认


EffectQueueManager = {}

function EffectQueueManager:init(gameState)
    self._effectList = {}
    self._gameState = gameState
    self._isComplete = true --特效队列是否完成了

    self._isRunning = false --队列是否在运行中，非新手引导才会使用  新手不受队列影响
end

function EffectQueueManager:finalize()
	self._effectList = {}
end

function EffectQueueManager:setMask(visible)
	self._gameState:setMask(visible)
end

--特效队列是否完成了
function EffectQueueManager:isComplete()
	return self._isComplete
end

--添加特效
--@effectType 特效类型，用来排序
--@effectHandler 特效处理器，用来触发具体的特效逻辑
--@isSetMask 是否加屏蔽层，true加/false不加
function EffectQueueManager:addEffect(effectType, effectHandler, data, justOne)
    table.insert(self._effectList, {effectType = effectType, effectHandler = effectHandler, data = data})
    self:delayStartEffect(nil, justOne, effectType)
    logger:error("~~~~~添加特效~~类型：%d~~~剩余特效:%d~~~", effectType, #self._effectList)
    self._isComplete = false
end

function EffectQueueManager:delayStartEffect(delay, justOne, effectType)
    local isStartGuide = GuideManager:isStartGuide()
    if isStartGuide ~= true then
        if self._isRunning == true then -- 需重置的数据
            --TODO 是否只需要队列里面一个元素就可以，比如战力，不需要叠加长队列
            if justOne == true and #self._effectList >= 2 then  --删除第一个
                --副本的星星特效，不能删~~
                -- if self._effectList[1].effectType ~= EffectQueueType.DUNGEON_STAR and self._effectList[1].effectType ~= EffectQueueType.TREASURE_ADVANCE then
                --     table.remove(self._effectList, 1)
                -- end

                local removeIndex = nil
                local num = 0
                for index,effect in pairs(self._effectList) do
                    if effect.effectType == effectType then
                        num = num + 1
                        if num >= 2 then
                            break
                        end
                        removeIndex = index
                    end
                end
                if removeIndex ~= nil and num >= 2 then  --队列里面有大于同样类型的特效
                    -- logger:error("~~~~~~~~删除重叠的特效~~~~~~~~~~~~~removeIndex:%d~~", removeIndex)
                    table.remove(self._effectList, removeIndex)
                end
            end
            return
        end
    end
    -- print("~~~~~~~~~~~~~self._isRunning~~~~~~~~~~~~~~~", self._isRunning, isStartGuide)
    self._isRunning = true
	delay = delay or 100
	TimerManager:addOnce(delay, self.startEffect, self)
end

--通过特效类型，删除掉对应的所有特效
function EffectQueueManager:removeEffectByType(effectType)

    local index = 1
    while true do
        local effect = self._effectList[index]
        if effect == nil then
            break
        end
        if effect.effectType == effectType then
            table.remove(self._effectList, index)
        else
            index = index + 1
        end
    end

    self:completeEffect()
    logger:error("~~~~~~~~~清空特效完毕，重新触发~~~~~~~~~~~~~~~~~~")
end

--开始特效
--开始之前，需要对当前的特效列表进行排序
--然后拿出第一个来触发
function EffectQueueManager:startEffect()

    local isStartGuide = GuideManager:isStartGuide()
    self:setMask( isStartGuide ) 

    if #self._effectList == 0 then
        self._isRunning = false
    	logger:info("~~~~~~~~~~~~特效队列播放结束~~~~~~~~~~~~~~~")
    	self:setMask(false)
    	self._isComplete = true
    	return
    end

	local function comp(a, b)
		return a.effectType < b.effectType
	end

	table.sort(self._effectList, comp)

    local effect = self._effectList[1]
    table.remove(self._effectList, 1)

    self._curEffectType = effect.effectType --当前特效类型

    if effect.effectType == EffectQueueType.UNLOCK 
    	or effect.effectType == EffectQueueType.GET_HERO
        or effect.effectType == EffectQueueType.GET_REWARD_LIST
        or effect.effectType == EffectQueueType.MessageBox then
    	self:setMask(false)
    end


    local effectHandler = effect.effectHandler
    effectHandler(effect.data)
end

--完成特效，由外部调用，触发下一个特效
--默认是一一对应的
function EffectQueueManager:completeEffect()
	logger:error("~~~~~特效~completeEffect~类型：%d~~~~剩余特效:%d~~", self._curEffectType, #self._effectList)
    self._isRunning = false
	self:delayStartEffect()
end

function EffectQueueManager:reconnectInit()
    self._effectList = {}
    self._isRunning = false
    logger:info("~~~~~~~~~~~~重连特效队列状态重置~~~~~~~~~~~~~~~")
    self:setMask(false)
    self._isComplete = true
end