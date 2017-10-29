-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
EmperorCityHelpPanel = class("EmperorCityHelpPanel", BasicPanel)
EmperorCityHelpPanel.NAME = "EmperorCityHelpPanel"

function EmperorCityHelpPanel:ctor(view, panelName)
    EmperorCityHelpPanel.super.ctor(self, view, panelName)

end

function EmperorCityHelpPanel:finalize()
    EmperorCityHelpPanel.super.finalize(self)


--    if self._picPanel.listenner ~= nil then
--        local touchPanel = self:getChildByName("mainPanel/touchPanel")
--        local eventDispatcher = touchPanel:getEventDispatcher()
--        eventDispatcher:removeEventListenersForTarget(touchPanel)
--        self._picPanel.listenner = nil
--    end
end

function EmperorCityHelpPanel:initPanel()
	EmperorCityHelpPanel.super.initPanel(self)
    
    self._emperorCityProxy = self:getProxy(GameProxys.EmperorCity)

    self._showIndex = 1 -- 默认选择界面1

    self._index = 1 -- 默认picPanel1
    
    -- 坐标
    self.allPos = {}
    self.allPos[1] = {0, 570, 1140, -570}
    self.allPos[2] = {-570, 0, 570, 1140}
    self.allPos[3] = {1140, -570, 0, 570}
    self.allPos[4] = {570, 1140, -570, 0}
end

function EmperorCityHelpPanel:registerEvents()
	EmperorCityHelpPanel.super.registerEvents(self)
    self._mainPanel = self:getChildByName("mainPanel")

    self._indexBtn1    = self._mainPanel:getChildByName("indexBtn1")
    self._indexBtn2    = self._mainPanel:getChildByName("indexBtn2")

    self:addTouchEventListener(self._indexBtn1, self.onIndexBtn1)
    self:addTouchEventListener(self._indexBtn2, self.onIndexBtn2)

    self._memoPanel = self._mainPanel:getChildByName("panel1")
    self._helpListView = self._memoPanel:getChildByName("listView")
    self._picPanel  = self._mainPanel:getChildByName("panel2")

    self._bgBottom = self._mainPanel:getChildByName("bgBottom")

    self._indexPanel = self._picPanel:getChildByName("indexPanel")
end


function EmperorCityHelpPanel:doLayout()
    local tabsPanel = self:getTabsPanel() 
    NodeUtils:adaptiveTopPanelAndListView(self._mainPanel, nil, nil, tabsPanel, 0)
end


function EmperorCityHelpPanel:onShowHandler()
    self.isTouch = true

    self:setShowPanel(self._showIndex)
    
    -- 设置玩法说明
    self:setHelpMemoPanel()

    -- 设置图文帮助
    self:setHelpPicPanel()
end



function EmperorCityHelpPanel:setShowPanel(index)
    for i = 1, 2 do
        local panel = self._mainPanel:getChildByName("panel"..i)
        if i == index then 
            panel:setVisible(true)
        else
            panel:setVisible(false)
        end
    end

    self._bgBottom:setVisible(index == 2)

    self:setTabBtnState(index)
end

function EmperorCityHelpPanel:onIndexBtn1(sender)
    self._showIndex = 1
    self:setShowPanel(self._showIndex)
end


function EmperorCityHelpPanel:onIndexBtn2(sender)
    self._showIndex = 2
    self:setShowPanel(self._showIndex)
end

------
-- 设置按钮显示状态
function EmperorCityHelpPanel:setTabBtnState(index)
    for i = 1, 2 do
        local btn = self._mainPanel:getChildByName("indexBtn"..i)
        if i == index then
            btn:loadTextures("images/newGui2/BtnTab_selected.png", "images/newGui2/BtnTab_normal.png", "", 1)
            btn:setTouchEnabled(false)
            btn:setTitleColor(ColorUtils.wordWhiteColor)
        else
            btn:loadTextures("images/newGui2/BtnTab_normal.png", "images/newGui2/BtnTab_selected.png", "", 1)
            btn:setTouchEnabled(true)
            btn:setTitleColor(ColorUtils.wordYellowColor03)
        end
    end
end


-- 设置玩法帮助
function EmperorCityHelpPanel:setHelpMemoPanel()
--    self._memoPanel
--    self._picPanel 
    local listData = ConfigDataManager:getConfigData(ConfigData.HelpInfoConfig)
    
    self:renderListView(self._helpListView, listData, self, self.renderItem, nil, nil, 0)
end

function EmperorCityHelpPanel:renderItem(itemPanel, data, index)
    local memoTxt = itemPanel:getChildByName("memoTxt")

    local color3b = ColorUtils:color16ToC3b("#"..data.color)
    memoTxt:setColor(color3b)
    memoTxt:setFontSize(data.font)
    memoTxt:setString(data.info)
end

-- 设置图文帮助
function EmperorCityHelpPanel:setHelpPicPanel()
    for i = 1, 4 do
        local panel = self:getChildByName("mainPanel/panel2/panel"..i)
        panel:setPositionX(self.allPos[self._index][i])
    end

    local touchPanel = self:getChildByName("mainPanel/touchPanel")
    self:addTouch(touchPanel, self._picPanel)

    self:setHelpBgImgAndMemo()
end

function EmperorCityHelpPanel:setHelpBgImgAndMemo()
    for i = 1, 4 do
        local panel = self:getChildByName("mainPanel/panel2/panel"..i)
        local helpImg = panel:getChildByName("helpImg")
        TextureManager:updateImageViewFile(helpImg, string.format("bg/emperorCity/img_help%d.jpg", i))
        self["setHelpMemo"..i](self, panel)  
    end
end







function EmperorCityHelpPanel:addTouch(panel, obj)
	local x, ox
	if obj.listenner == nil then
		obj.listenner = cc.EventListenerTouchOneByOne:create()
		obj.listenner:setSwallowTouches(false)

		obj.listenner:registerScriptHandler(function(touch, event)  
	        local location = touch:getLocation()   
	        x = location.x
	        ox = x
	        return (obj:isVisible() and self.isTouch)
	    end, cc.Handler.EVENT_TOUCH_BEGAN )

		obj.listenner:registerScriptHandler(function(touch, event)
			local location = touch:getLocation()
	        self:touchMoved(location.x - ox)
	        ox = location.x
	    end, cc.Handler.EVENT_TOUCH_MOVED )

	    obj.listenner:registerScriptHandler(function(touch, event)
	    	local location = touch:getLocation()
	    	self:touchEnded(location.x - x)
	    end, cc.Handler.EVENT_TOUCH_ENDED ) 

	    local eventDispatcher = panel:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(obj.listenner, panel)
	end
end

function EmperorCityHelpPanel:touchMoved(offsetX)
    for i = 1 , 4 do
        local panel = self:getChildByName("mainPanel/panel2/panel"..i)
        local x = panel:getPositionX()
        panel:setPositionX(x + offsetX)
        local posX = x + offsetX
        if posX > -0.3 and posX < 0.3 then
            self._index = i
            self:adjustPanelPos()
            return true
        end
    end
end


function EmperorCityHelpPanel:touchEnded(dir)
    local minDistance = 9999
    local showIndex = 0
    for i = 1,4 do
        local panel = self:getChildByName("mainPanel/panel2/panel"..i)
        local x = panel:getPositionX()
        if (x < 0 and dir > 10) or (dir < -10 and x > 0 and x < 570) then
            local offsetX = math.abs(x)
            if offsetX < minDistance then
                showIndex = i
                minDistance = offsetX
            end
            self._canClick = false
        end
    end
    if showIndex ~= 0 then
        self._index = showIndex
    end
    -- 点击结束，回调响应函数
    self:adjustPanelPos(true, dir) 
end


--- 翻页回调函数，只刷新下方属性，左右红点，标签页
function EmperorCityHelpPanel:adjustPanelPos(isAction, dir)

    -- 点击回调
    local function call()
        if self._oldIndex ~= self._index then
            logger:info(self._index)
        end
    end

    -- 页面标签
    self:setIndexPanelShow(self._index)
    
    for i = 1, 4 do
        local panel = self:getChildByName("mainPanel/panel2/panel"..i)
        if isAction then
            panel._code = i
            local posX = panel:getPositionX()
            local targetPos = cc.p(self.allPos[self._index][i], panel:getPositionY())
            --防止其他panel在移动造成界面闪烁
            if dir < 0 then
                if self.allPos[self._index][i] > posX and posX <= -570 then
                    panel:setVisible(false)
                end
            elseif dir > 0 then
                if self.allPos[self._index][i] < posX and posX >= 570 then
                    panel:setVisible(false)
                end
            end

            local move = cc.MoveTo:create(0.15, targetPos)
            local callFunc = cc.CallFunc:create(function(sender)
                self._canClick = true
                --再设置一下位置
                sender:setVisible(true)
                sender:setPositionX(self.allPos[self._index][sender._code])
                if sender._code == 4 then
                    call()
                    TimerManager:addOnce(80, function()
                        
                    end, self)
                end
            end)
            panel:runAction(cc.Sequence:create(move, callFunc))
        else
            panel:setPositionX(self.allPos[self._index][i])
        end
    end

    if not isAction then
        call()
    end
end


function EmperorCityHelpPanel:onHideHandler()
	self.isTouch = false
end


function EmperorCityHelpPanel:setHelpMemo1(panel)
    local titleTxt = panel:getChildByName("titleTxt")
    titleTxt:setString(self:getTextWord(550013))
    local memoTxt01 = panel:getChildByName("memoTxt01")
    local memoTxt02 = panel:getChildByName("memoTxt02")
    local memoTxt03 = panel:getChildByName("memoTxt03")

    memoTxt01:setString(self:getTextWord(550017))
    memoTxt02:setString(self:getTextWord(550018))
end

function EmperorCityHelpPanel:setHelpMemo2(panel)
    local titleTxt = panel:getChildByName("titleTxt")
    titleTxt:setString(self:getTextWord(550014))
    local memoTxt01 = panel:getChildByName("memoTxt01")
    local memoTxt02 = panel:getChildByName("memoTxt02")
    local memoTxt03 = panel:getChildByName("memoTxt03")

    memoTxt01:setString(self:getTextWord(550019))
    memoTxt02:setString(self:getTextWord(550020))
    memoTxt03:setString(self:getTextWord(550021))
end

function EmperorCityHelpPanel:setHelpMemo3(panel)
    local titleTxt = panel:getChildByName("titleTxt")
    titleTxt:setString(self:getTextWord(550015))
    local memoTxt01 = panel:getChildByName("memoTxt01")
    local memoTxt02 = panel:getChildByName("memoTxt02")
    local memoTxt03 = panel:getChildByName("memoTxt03")

    memoTxt01:setString(self:getTextWord(550022))
    memoTxt02:setString(self:getTextWord(550023))
    memoTxt03:setString(self:getTextWord(550024))

end


function EmperorCityHelpPanel:setHelpMemo4(panel)
    local titleTxt = panel:getChildByName("titleTxt")
    titleTxt:setString(self:getTextWord(550016))
    local memoTxt01 = panel:getChildByName("memoTxt01")
    local memoTxt02 = panel:getChildByName("memoTxt02")
    local memoTxt03 = panel:getChildByName("memoTxt03")

    memoTxt01:setString(self:getTextWord(550025))
    memoTxt02:setString(self:getTextWord(550026))
end


-- 设置页面亮点标记
function EmperorCityHelpPanel:setIndexPanelShow(curDataIndex)
    local showIcon = self._indexPanel:getChildByName("showIcon")
    for i = 1, 4 do
        if i ==  curDataIndex then
            local indexIcon = self._indexPanel:getChildByName("indexIcon".. i)
            showIcon:setPositionX(indexIcon:getPositionX())
            break
        end
    end
end
