
------升级特效---
LevelUpAnimation = class("LevelUpAnimation", BaseAnimation)

function LevelUpAnimation:ctor(parent, data)
	LevelUpAnimation.super.ctor(self, parent, data)
end

function LevelUpAnimation:finalize()
    
    LevelUpAnimation.super.finalize(self)
end

function LevelUpAnimation:playComplete()

    if self._lvUpPanel ~= nil then
        self._lvUpPanel:finalize()
        self._lvUpPanel = nil
    end

    EffectQueueManager:completeEffect()
end

function LevelUpAnimation:play()

	local function handler()
        self:runLvUpAction({})
    end
    EffectQueueManager:addEffect(EffectQueueType.LEVEL_UP, handler)

end

function LevelUpAnimation:runLvUpAction(data)
	local layer = self.parent
	local ccbLayer = UICCBLayer.new("rgb-zgsj", layer, nil, function()
        self:playComplete()
    end)

    self._lvUpPanel = ccbLayer
    local winSize = cc.Director:getInstance():getWinSize()
    -- 根据窗口大小做缩放
    local scaleX = GameConfig.LvUp.X
    local scaleY = GameConfig.LvUp.Y
    ccbLayer:setPosition(winSize.width * scaleX, winSize.height * scaleY)
end




