

UITreasureSelect = class("UITreasureSelect")

function UITreasureSelect:ctor(parent, panel,isShow,callfunc)
    local uiSkin = UISkin.new("UITreasureSelect")
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(640, 960))
    layout:setAnchorPoint(cc.p(0.5,0.5))
    local winSize = cc.Director:getInstance():getWinSize()
    layout:setPosition(winSize.width/2, winSize.height/2)
    parent:addChild(layout)

        uiSkin:setTouchEnabled(false)


    local extra = {}
    extra["closeBtnType"] = 2
    extra["callBack"] = self.hide
    extra["obj"] = self
    local secLvBg = UISecLvPanelBg.new(layout, self,extra) -- 新版的底图框
    secLvBg:setContentHeight(560)
    secLvBg:setTitle(TextWords:getTextWord(3814))
    secLvBg:setBackGroundColorOpacity(120)

    
    uiSkin:setParent(parent)
    uiSkin:setVisible(false)
    layout:setVisible(false)

    secLvBg:setLocalZOrder(2)
     
    self._parent = layout
    self._uiSkin = uiSkin
    self._panel = panel
    self.secLvBg = secLvBg
    self.callfunc = callfunc

    self["pos5"] = {40, 151, 262, 373, 485}
    for i=1,4 do
        self["pos"..i] = {}
        for j=1,i do
            self["pos"..i][j] = 525/(i + 1) * j
        end
    end

    self.bgImg = self:getChildByName("mainPanel/bgImg")
    if self.posY == nil then
        self.posY = self.bgImg:getPositionY()
    end

    self.sureBtn = self:getChildByName("mainPanel/sureBtn")
    self.sureBtn:setVisible(false)
    self.btnX = self.sureBtn:getPositionX()
    self.bgImgX = self.bgImg:getPositionX()
    self._mainPanel = self:getChildByName("mainPanel")


    self._selectNum = 1
    self.listView = self:getChildByName("mainPanel/ListView_1")
    self.listView.from = self
end

function UITreasureSelect:setTitle(titileStr)
    self.secLvBg:setTitle(titileStr)
end

function UITreasureSelect:hide()

    self._uiSkin:setVisible(false)
    self._parent:setVisible(false)
    if type(self.callfunc) == "function" then
        self.callfunc(self._panel,self.listView._selectNum)
    end

end

function UITreasureSelect:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end

function UITreasureSelect:playAction(callback)    
    -- 半透明背景坐标偏移的微调
    local size = self._uiSkin:getContentSize()
    local scale =  NodeUtils:getAdaptiveScale()
    local tmp = math.abs(scale - 1)/6
    scale = math.abs(scale - tmp)    
    self._uiSkin:setPosition(size.width/2 * scale, size.height/2)

    self._uiSkin:setOpacity(GameConfig.TwoLevelShells.OPACITY_MIN)
    self._uiSkin:setScale(0)
    -- self._parent:setVisible(true)
    --self.callfunc = callback
    self.secLvBg:setTitle(TextWords:getTextWord(3814))
    --self.secLvBg:hideCloseBtn(true)
    self._uiSkin:setVisible(true)

    
    self._uiSkin:setAnchorPoint(cc.p(0.5,0.5))
    local actionScale = cc.ScaleTo:create(GameConfig.TwoLevelShells.TIME, GameConfig.TwoLevelShells.SCALE_MAX)
    local actionFade = cc.FadeTo:create(GameConfig.TwoLevelShells.TIME, GameConfig.TwoLevelShells.OPACITY_MAX)
    local actionSpawn = cc.Spawn:create(actionScale,actionFade)
    local function localcallback()
        -- self:renderAllGoods(info)
        self._parent:setVisible(true)
        --self:createEffect()
        local function call()
            self:playEffect()
        end
        TimerManager:addOnce(60,call,self)  
    end
    self._uiSkin:runAction(cc.Sequence:create(actionSpawn, cc.CallFunc:create(localcallback)))

end


function UITreasureSelect:show(info, callback)
    -- body
    self:renderAllGoods(info)  --先渲染道具
    self:playAction(callback)  --再播放动画

end

function UITreasureSelect:renderAllGoods(infos)
    self._uiSkin:setVisible(true)
    self.secLvBg:setVisible(true)
    local scale = NodeUtils:getAdaptiveScale()
    self.listView._selectNum = nil

    ComponentUtils:renderTreasureRecover(self.listView, self.bgImg, self.secLvBg, self.sureBtn,infos, self._panel,self.addfunc,self.sureBtnHandler)

    -- local closeBtn = self:getChildByName("mainPanel/sureBtn")
    ComponentUtils:addTouchEventListener(self.sureBtn, self.hide, nil, self)
    
end
function UITreasureSelect:addfunc(selectData,index)
    self._selectNum = selectData.number
    self._oldSelectIndex = self._selectIndex or 1
    self._selectIndex = index
    if self._oldSelectIndex ~= self._selectIndex then
        local item = self:getItem(self._oldSelectIndex)
        item:hideSelect()
    end

end
function UITreasureSelect:sureBtnHandler(selectData,index)
    self._selectNum = selectData.number
    self.from:hide()
end
function UITreasureSelect:isSelected(number)
    return self._selectNum == number
end

-- 特效
function UITreasureSelect:createEffect()
    -- body
    local mainPanel = self:getChildByName("mainPanel")
    local size = mainPanel:getContentSize()
    if self.movieChip == nil then
        self.movieChip = UIMovieClip.new("rpg-Criticalpoints")
        self.movieChip:setParent(mainPanel)
        self.movieChip:setLocalZOrder(12)
        self.movieChip:setPosition(size.width / 2 - 5, size.height / 2 + 10)
    end
    self.movieChip:setVisible(true)
    self.movieChip:play(false,function () self.movieChip:setVisible(false) end)

    
end


-- 加载获得物品的背景特效
function UITreasureSelect:playEffect()
    -- 取得seclvbg下的mianpanel
    local ccbLayer = self._parent.ccbLayer
    if ccbLayer == nil then
        print("物品的特效ccb...")
        local ccbLayer = UICCBLayer.new("rgb-res-light", self._parent)        
        local size = self._parent:getContentSize()
        ccbLayer:setPosition(size.width/2,size.height/2)
        ccbLayer:setLocalZOrder(1)
        ccbLayer:setVisible(true)
        self._parent.ccbLayer = ccbLayer
    else
        ccbLayer:setVisible(true)
    end
end



function UITreasureSelect:scrollToEnd()
    self._listView:scrollToBottom(2.5,true)
end



function UITreasureSelect:removeFromParent()
    if self.movieChip ~= nil then
        self.movieChip:finalize()
    end
    self._parent:removeChild(self._uiSkin, true)
end
