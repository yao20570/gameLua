

UITip = class("UITip") 

--[[
游戏里面简要Tip的实现
@params isNoAction 不需要执行动作填true
]]
function UITip:ctor(parent,_minHeight,isNoAction, closeNotFinalize)

    local root = cc.Node:create()
    self._isNoAction = true --isNoAction
    local layout = ccui.Layout:create()
    layout:setName("UITip")
    root:addChild(layout)
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
    layout:setContentSize(cc.size(640,960))
    self._layout = layout
    
    self._width = 400
    self._centerY = 480
    self._minHeight = _minHeight or 240--220  --弹窗最小高度
    self._closeNotFinalize = closeNotFinalize or false  --关闭不释放，只是隐藏  默认关闭释放

    
    self._root = root
    parent:addChild(self._root, 10, 9991)
    
    self:initView(parent)
    self:registerEvents()

    -- print("~~~~~~~~~~UITip:ctor~~~~~~~~~~~~")
    
end

function UITip:finalize()
    self._root:setVisible(false)
    self._root:removeFromParent()
end

function UITip:hide()
    self._root:setVisible(false)
end

function UITip:registerEvents()
    ComponentUtils:addTouchEventListener(self._layout,self.onCloseTouch,nil,self)
end

function UITip:isVisible()
    return self._root:isVisible()
end

function UITip:onCloseTouch(sender)
    if not self._isNoAction then
        self:closeAction()
    else
        if self._closeNotFinalize == true then  --关闭不释放
            self:hide() 
        else
            TimerManager:addOnce(10, self.finalize, self)
        end
    end
end

function UITip:initView(parent)
    -- 新的背景
    --[[
    new一个二级背景,将messageBox的全部子节点clone到二级背景下，
    再删除messageBox的全部子节点    
    ]]
    --begin-------------------------------------------------------------------
    local bagNode = cc.Node:create()
    local secLvBg = UISecLvPanelBg.new(bagNode, self, nil, true)
    secLvBg:setTitle(TextWords:getTextWord(142))
    secLvBg:setBackGroundColorOpacity(120)
    self.secLvBg = secLvBg
    secLvBg:hideCloseBtn(false)
    secLvBg:setTouchEnabled(false)
    self.mainPanel = secLvBg:getMainPanel()
    -- secLvBg:setBgVisible(true)

    self._root:addChild(bagNode)

    bagNode:setLocalZOrder(1)
    self._layout:setLocalZOrder(10)

    --end-------------------------------------------------------------------

    
--    local label = ComponentUtils:createRichLabel(
--        [[<font face="fn24" color = "#e6ffe0">这个一个测试文本</font>]],cc.size(self._width - 40,0))
    local label = ComponentUtils:createRichLabel(true, cc.size(self._width - 40,0))
    label:setPosition(320 - 550 / 2 + 20 , self._centerY) --- self._width / 2 + 20
    label:setAnchorPoint(cc.p(0, 0.5))    
    label:setLocalZOrder(100)
    self._root:addChild(label)
    
    self._bg = secLvBg
    self._tipLabel = label
    self._bagnode = bagNode
    
    if not self._isNoAction then
        self:initAction()
    end

end


function UITip:initAction(callback)
    self._tipLabel:setVisible(false)
    self._bagnode:setScale(GameConfig.TwoLevelShells.SCALE_MIN)
    self._bagnode:setOpacity(GameConfig.TwoLevelShells.OPACITY_MIN)
    self._bagnode:setAnchorPoint(cc.p(0.5,0.5))
    local function localcallback()
        if callback then
            callback()
        end

        self._tipLabel:setVisible(true)
    end
    local actionScale = cc.ScaleTo:create(GameConfig.TwoLevelShells.TIME, GameConfig.TwoLevelShells.SCALE_MAX)
    local actionFade = cc.FadeTo:create(GameConfig.TwoLevelShells.TIME, GameConfig.TwoLevelShells.OPACITY_MAX)
    local actionSpawn = cc.Spawn:create(actionScale,actionFade)
    self._bagnode:runAction(cc.Sequence:create(actionSpawn, cc.CallFunc:create(localcallback)))
end

function UITip:closeAction(callback)
    local actionScale = cc.ScaleTo:create(GameConfig.TwoLevelShells.TIME, GameConfig.TwoLevelShells.SCALE_MIN)
    local actionFade = cc.FadeTo:create(GameConfig.TwoLevelShells.TIME, GameConfig.TwoLevelShells.OPACITY_MIN)
    local actionSpawn = cc.Spawn:create(actionScale,actionFade)
    local function localcallback()
        if callback then
            callback()
        end
        if self._root then
            self:finalize()
        end
    end
        self._tipLabel:setVisible(false)
    self._bagnode:runAction(cc.Sequence:create(actionSpawn, cc.CallFunc:create(localcallback)))
end

--渲染所有的Tip行
--TipLine: {
--{{content =, foneSize =, color =}, {content =, foneSize =, color = ,args}},
--{{content =, foneSize =, color = }, {content =, foneSize =, color = ,args}}
--} //tip一行的数据格式  二维数组
--content 文本内容  foneSize字体大小 color颜色 格式如"#ffffff" args额外参数，处理一行文本有多种格式
function UITip:setAllTipLine(lines)
    self:setTip(lines)
end

------------直接文本设置--------------------------------------------------
function UITip:setTip(content)
    self._root:setVisible(true)
    self._tipLabel:setString(content)
    

    local visSize = cc.Director:getInstance():getVisibleSize()
    self._centerY = visSize.height/2 - 10
    local scale = NodeUtils:getAdaptiveScale()

    local contentSize = self._tipLabel:getContentSize()

    -- 先居中兼容处理
    self._tipLabel:setPosition(320 - contentSize.width / 2 , self._centerY + contentSize.height / 2 )
    --self._tipLabel:setPosition(100 * scale, self._centerY + contentSize.height / 2 )


    local posNode = self._tipLabel:convertToNodeSpace(cc.p(0, 0))

    local height = contentSize.height * scale + 85  --上下边缘约40像素

    if height < self._minHeight then
        height = self._minHeight
    end
    self._bg:setContentHeight(height)
end

function UITip:setTitle(titleName)
    self._bg:setTitle(titleName)
end
