
RichTextAnimation = class("RichTextAnimation") 

function RichTextAnimation:ctor(panel,data,coverPanel)
    self._panel = panel
    self._coverPanel = coverPanel
    self._histories = data
    self.visSize = cc.Director:getInstance():getVisibleSize()
    self:createRiches()
end

function RichTextAnimation:setVisible(isShow)
    -- body
    if self.layer then
        self.layer:setVisible(isShow)
    end
    if self._coverPanel then
        self._coverPanel:setVisible(isShow)
    end
end

function RichTextAnimation:setTouchEnabled(isEnable)
    -- body
    if self.layer then
        self.layer:setTouchEnabled(isEnable)
    end
end

function RichTextAnimation:removeAll()
    if self.layer then
        self.layer:stopAllActions()
        self.layer:removeAllChildren()
        self.SpriteTab = {}
        self.index = nil
        self.lineBg = nil
    end

end

-- 添加行背景
function RichTextAnimation:addLineBg()
    if self.lineBg == nil then
        local url = "images/pub/Bg_message1.png"
        local lineBg = TextureManager:createImageView(url)
        lineBg:setAnchorPoint(0.5,1)
        local size = lineBg:getContentSize()
        local dy = (size.height - GlobalConfig.RichTxt_X_FontSize) / 2 - 2
        lineBg:setPosition(self.visSize.width / 2, self.visSize.height / 2 - GlobalConfig.RichTxt_X_MoveInitY + dy)  --富文本初始坐标

        self.layer:addChild(lineBg)
        self.lineBg = lineBg
    end
end

function RichTextAnimation:createRiches()
    if self._histories == nil then
        logger:error("玩家抽奖记录为空，我不执行RichTextAnimation:createRiches()")
        return
    end
    local tableSize = table.size(self._histories) or 0
    if tableSize == 0 then
        -- print("居然没有人抽到好武将.....good")
        return
    end
    print("历史记录 tableSize=",tableSize) 

    if self.layer == nil then
        self.layer = cc.Layer:create()
        -- self.layer = cc.LayerColor:create(cc.c4b(255, 255, 255, 100))
        self._panel:addChild(self.layer)
        self.layer:setTouchEnabled(false)
        self.layer:setLocalZOrder(100)
    end
    self:addLineBg()

    if self.index == nil then
        self.index = 1
    end
    
    if self.SpriteTab == nil then
        self.SpriteTab = {}
    end
    
    -- 干掉全部重新创建
    -- self.layer:removeAllChildren()
    -- self.SpriteTab = {}

    local function createSprite(index)
        if rawget(self.SpriteTab,"sp"..index) == nil then
            --print("创建新的sprite ",index)
            local sprite = cc.Sprite:create()
            sprite:setVisible(true)
            -- sprite:setName("sp"..index)
            self.layer:addChild(sprite)
            self.SpriteTab["sp"..index] = sprite
        end

        -- self.SpriteTab["sp"..index]:stopAllActions()
        self:createOrUpdateRichLabel( self.SpriteTab["sp"..index], index )
        self:playTextActionX(self.SpriteTab["sp"..index].rickLabel,index,tableSize)
    end

    local function createMoreSprite()
        if self.index == nil then
            return
        end
        if self.index <= tableSize then
            createSprite(self.index)
            self.index = self.index + 1
            TimerManager:addOnce(1,createMoreSprite,self)
        else
            -- TimerManager:addOnce(1,self.delayRepeat,self)  --循环播放
        end
    end

    TimerManager:addOnce(1,createMoreSprite,self)
end

function RichTextAnimation:delayRepeat()
    -- body
    self.index = nil
    self:createRiches()
end

-- 刷新滚屏的玩家信息
function RichTextAnimation:updateTextInfos( tableSize )
    -- body
     if tableSize ~= nil and table.size(tableSize) > 0 then
        --重置位置
        if self.SpriteTab ~= nil and table.size(self.SpriteTab) > 0 then
            for k , v in  pairs(self.SpriteTab) do 
                v.rickLabel:setPosition(0,0)
                v.rickLabel:stopAllActions()
            end
            self._histories = tableSize
            self:delayRepeat()
            return
        end
    end

    -- for index=1,#tableSize do
    --     if rawget(self.SpriteTab,"sp"..index) ~= nil then
    --     -- if self.SpriteTab["sp"..index] then

    --         print("刷新玩家信息 index=",index)

    --         local rickLabel = self.SpriteTab["sp"..index].rickLabel
    --         local history = self._histories[index]
    --         local reward
    --         if history then
    --             reward = ConfigDataManager:getConfigByPowerAndID(history.reward.power, history.reward.typeid)
    --         end

    --         if reward == nil or history == nil then
    --             return
    --         end
            
    --         local type = rawget(reward,"color") or rawget(reward,"quality")
    --         local iconColor = ColorUtils:getRichColorByQuality(type) or "#ffffff"
    --         local fontSize = GlobalConfig.RichTxt_X_FontSize
    --         local info = {{{history.name,fontSize,GlobalConfig.RichTxt_X_NameColor},{"获得",fontSize,GlobalConfig.RichTxt_X_InfoColor},{reward.name,fontSize,iconColor},{"*"..history.reward.num,fontSize,iconColor}}}
    --         rickLabel:setString(info)

    --     end
    -- end

end


-- 创建OR刷新富文本显示信息
function RichTextAnimation:createOrUpdateRichLabel( parent, index, string )
    -- local visSize = cc.Director:getInstance():getVisibleSize()

    local rickLabel = parent.rickLabel
    if rickLabel == nil then
        --print("创建新rich。。。。。。。")
        rickLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        parent:addChild(rickLabel)
        parent.rickLabel = rickLabel    
        parent:setPosition(self.visSize.width, self.visSize.height/2-GlobalConfig.RichTxt_X_MoveInitY)  --富文本初始坐标
    end

    local history = self._histories[index]
    local reward
    if history then
        reward = ConfigDataManager:getConfigByPowerAndID(history.reward.power, history.reward.typeid)
    end

    -- 道具颜色
    -- 道具字体
    local type = rawget(reward,"color") or rawget(reward,"quality")
    local iconColor = ColorUtils:getRichColorByQuality(type) or "#ffffff"
    local fontSize = GlobalConfig.RichTxt_X_FontSize
    local info = {{{history.name,fontSize,GlobalConfig.RichTxt_X_NameColor},{"获得",fontSize,GlobalConfig.RichTxt_X_InfoColor},{reward.name,fontSize,iconColor},{"*"..history.reward.num,fontSize,iconColor}}}

    rickLabel:setString(info)
    -- self.rickLabelSize = rickLabel:getContentSize()

end

-- 竖屏滚动屏幕动画
function RichTextAnimation:playTextActionY( rickLabel, index, tableSize )
    -- body
    if rickLabel then
        rickLabel:stopAllActions()
        -- 遍历富文本所有子节点播放动画
        local children = rickLabel:getChildren()
        for k,child in pairs(children) do
            local x,y = child:getPosition()

            -- 动画分两段：进场/离场
            local delayTime = GlobalConfig.RichTxt_LineDelay  --每行间隔时间
            local delay = cc.DelayTime:create(delayTime*index)
            local delay2 = cc.DelayTime:create(delayTime*(tableSize-index))
            local fadeIn = cc.FadeIn:create(GlobalConfig.RichTxt_FadeInDelay)
            local fadeOut = cc.FadeOut:create(GlobalConfig.RichTxt_FadeOutDelay)
            local initPos = cc.MoveTo:create(0,cc.p(x, y))
            local move = cc.MoveTo:create(GlobalConfig.RichTxt_MoveToDelay,cc.p(x, y+GlobalConfig.RichTxt_MoveDstY1))
            local move2 = cc.MoveTo:create(GlobalConfig.RichTxt_MoveToDelay,cc.p(x, y+GlobalConfig.RichTxt_MoveDstY2))
            local Spawn = cc.Spawn:create(move,fadeIn)
            local Spawn2 = cc.Spawn:create(move2,fadeOut)
            local action = cc.Sequence:create(delay,initPos,Spawn,Spawn2,delay2)
            local repeatAction = cc.RepeatForever:create(action)

            child:setOpacity(0)
            child:stopAllActions()
            child:runAction(repeatAction)
        end
    end
end

-- 横屏滚动屏幕动画
function RichTextAnimation:playTextActionX( rickLabel, index, tableSize )
    if rickLabel then
        local x,y = rickLabel:getPosition()
        local size = rickLabel:getContentSize()
        local delayTime = GlobalConfig.RichTxt_X_LineDelay  --每行间隔时间
        local delay = cc.DelayTime:create(delayTime*index)
        local delay2 = cc.DelayTime:create(delayTime*(tableSize-index))
        local initPos = cc.MoveTo:create(0,cc.p(x, y))
        local move2 = cc.MoveTo:create(GlobalConfig.RichTxt_X_MoveToDelay,cc.p(x-self.visSize.width-size.width, y))
        local action = cc.Sequence:create(delay,initPos,move2,delay2)
        local repeatAction = cc.RepeatForever:create(action)

        -- rickLabel:setOpacity(255)
        rickLabel:stopAllActions()
        rickLabel:runAction(repeatAction)

    end


end
