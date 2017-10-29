
-- 一个物品，一个物品慢慢飘
BagFreshFly = class("BagFreshFly", BaseAnimation)

function BagFreshFly:finalize()
    BagFreshFly.super.finalize(self)
end

function BagFreshFly:play()

    local dir = 0
    local index = 0
    for _, v in pairs(self.data.rewards) do
        local power = v.power
        local info = RewardDefine.type[power]
        -- if power ~= GamePowerConfig.Resource then
        if power == GamePowerConfig.Soldier
            or power == GamePowerConfig.General
            or power == GamePowerConfig.Hero
            or power == GamePowerConfig.Item
            or power == GamePowerConfig.Ordnance
            or power == GamePowerConfig.HeroTreasure
            or power == GamePowerConfig.HeroTreasureFragment
            or power == GamePowerConfig.Resource
            or power == GamePowerConfig.LimitActivityItem
            or power == GamePowerConfig.HeroFragment
            or power == GamePowerConfig.OrdnanceFragment then
            if v.num > 0 then
                -- 经验或者资源，不走这里的动画
                --                if not (v.typeid == PlayerPowerDefine.POWER_exp) then
                local i = index
                local function delayGetRewardAction()
                    self:getRewardAction(v, i + dir)
                end
                EffectQueueManager:addEffect(EffectQueueType.GET_REWARD, delayGetRewardAction, false)
                --                end

                index = index + 1
            end
        else
            -- info = info..",数量为："..v.num
            -- self:showSysMessage(info)
        end
    end

end

function BagFreshFly:getRewardAction(reward, index)

    local root = cc.Node:create()
    local node = cc.Node:create()

    root.node = node
    root:addChild(node)
    local rewardIcon
    local energyImg

    local data = { }
    data.power = reward.power
    data.num = reward.num
    data.typeid = reward.typeid
    rewardIcon = UIIcon.new(node, data, true)
    rewardIcon:setTouchEnabled(false)
    rewardIcon:setScale(RewardActionConfig.ICON_SCALE)

    --        local movieChip = UIMovieClip.new("baoshi_white", 0.06)
    --        movieChip:setParent(node)
    --        movieChip:play(false)
    -- end
    local layer = self.parent
    layer:addChild(root)

    local posIndex = index % 3 + 1
    local poxX = RewardActionConfig.FLY_POS_X_LIST[posIndex]
    local poxY = RewardActionConfig.FLY_POS_Y_LIST[posIndex]
    root:setPosition(poxX, poxY)

    root:setVisible(false)

    local function callback()
        EffectQueueManager:completeEffect()
        -- TODO 这里需要判断已经播放完了
    end
    self:showGetRewardActionQueue(root, callback)
end

function BagFreshFly:showGetRewardActionQueue(root, readyCallback)
    local function callback()
        self:showGetRewardAction(root)
        readyCallback()
    end

    AudioManager:playEffect("yx_item")

    -- local noAction = cc.MoveBy:create(RewardActionConfig.INTERVAL_TIME, cc.p(0, 0))
    local delay1 = cc.DelayTime:create(RewardActionConfig.INTERVAL_TIME)
    root:runAction(cc.Sequence:create(delay1, cc.CallFunc:create(callback)))
end

function BagFreshFly:showGetRewardAction(root)
    local function callback()
        root:removeFromParent()
    end

    local x, y = root:getPosition()    
    local s1 = cc.ScaleTo:create(0.1, 1.2)
    local s2 = cc.ScaleTo:create(0.2, 1)
    local m = cc.MoveTo:create(1.5, cc.p(x, y + 80))
    
    root:setVisible(true)
    root:setScale(0.1)
    root:runAction(cc.Sequence:create(s1, s2, m, cc.CallFunc:create(callback)))

    UICCBLayer.new("rpg-wphq", root.node, nil, nil, true)
end
