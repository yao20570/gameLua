
------全局动画工厂---
------用来生产全局的各种动画，
------比如战力飘字、升级、物品飘窗等动画
AnimationFactory = { }

AnimationFactory.Type_BagFreshFly = "BagFreshFly"
AnimationFactory.Type_CapactityAnimation = "CapactityAnimation"
AnimationFactory.Type_GetGoodsEffect = "GetGoodsEffect"
AnimationFactory.Type_GetPropAnimation = "GetPropAnimation"
AnimationFactory.Type_LevelUpAnimation = "LevelUpAnimation"
AnimationFactory.Type_GuideRewardEffect = "GuideRewardEffect"
-- 初始化
function AnimationFactory:init(gameState)
    self._gameState = gameState

    self._animationMap = { }
    self:initFactory()
end

function AnimationFactory:finalize()
    for _, animation in pairs(self._animationMap) do
        animation:finalize()
    end
    self._animationMap = { }
end

function AnimationFactory:initFactory()
    local parent = self._gameState:getLayer(GameLayer.popLayer)
    self._animationMap[AnimationFactory.Type_BagFreshFly] = BagFreshFly.new(parent)
    self._animationMap[AnimationFactory.Type_CapactityAnimation] = CapactityAnimation.new(parent)
    self._animationMap[AnimationFactory.Type_GetGoodsEffect] = GetGoodsEffect.new(parent)
    self._animationMap[AnimationFactory.Type_GetPropAnimation] = GetPropAnimation.new(parent)
    self._animationMap[AnimationFactory.Type_LevelUpAnimation] = LevelUpAnimation.new(parent)
    self._animationMap[AnimationFactory.Type_GuideRewardEffect] = GuideRewardEffect.new(parent)
end

-- 通过class播放动画 playAnimationByClass
function AnimationFactory:playAnimationByName(name, data)
    logger:error("@@@@@@@@@@@播放特效@@@@@@@@@@@@@@@@name:%s@@@@", name)
    local animation = self._animationMap[name]
    animation:setData(data)
    animation:setGameState(self._gameState)
    animation:play()
end