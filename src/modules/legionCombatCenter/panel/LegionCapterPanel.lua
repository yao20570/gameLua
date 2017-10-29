-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-04-18 16:53:09
--  * @Description: 军团试炼场列表
--  */
LegionCapterPanel = class("LegionCapterPanel", BasicPanel)
LegionCapterPanel.NAME = "LegionCapterPanel"

function LegionCapterPanel:ctor(view, panelName)
    LegionCapterPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionCapterPanel:finalize()
    LegionCapterPanel.super.finalize(self)
end

function LegionCapterPanel:initPanel()
	LegionCapterPanel.super.initPanel(self)

    self._listview = self:getChildByName("ListView")
    self._topPanel = self:getChildByName("topPanel")
    self.Label_left = self._topPanel:getChildByName("Label_left")
    local Label_tip = self._topPanel:getChildByName("Label_tip")
    Label_tip:setString(self:getTextWord(3605))
    local item = self._listview:getItem(0)
    item:setVisible(false)
    
    self._conf = ConfigDataManager:getConfigData(ConfigData.LegionCapterConfig)
    self._dungeonXProxy = self:getProxy(GameProxys.DungeonX)
end

function LegionCapterPanel:doLayout()
    local tabsPanel = self:getTabsPanel()

    NodeUtils:adaptiveTopPanelAndListView(self._topPanel,self._listview ,GlobalConfig.downHeight,tabsPanel,10)
end

function LegionCapterPanel:registerEvents()
	LegionCapterPanel.super.registerEvents(self)
end


function LegionCapterPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionCapterPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
    self:onChapterUpdate()
end

-- 章节信息更新
function LegionCapterPanel:onChapterUpdate()
    if self:isModuleRunAction() then
        return
    end

    local allData = self._dungeonXProxy:getAllDungeonData()
    local tabData = clone(allData.dungeonInfos)

    self:renderListView(self._listview, tabData, self, self.onRenderListView)
    self:updateDownPanel(allData)
end


function LegionCapterPanel:updateDownPanel(data)
    -- 纯文字富文本显示
    local color = ColorUtils.wordColorDark1603 --red
    if data.curCount == 0 then
        color = ColorUtils.wordColorDark1604
    end
    local text = {{{self:getTextWord(3604),20,"#ffffff"},{data.curCount,20,color},{"/"..data.totalCount,20,"#ffffff"}}}

    local rickLabel = self.Label_left._rickLabel
    if rickLabel == nil then
        rickLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        rickLabel:setPosition(self.Label_left:getPosition())
        self.Label_left:getParent():addChild(rickLabel)
        self.Label_left._rickLabel = rickLabel
    end
    rickLabel:setString(text)
    self.Label_left._rickLabel:setVisible(true)
end

function LegionCapterPanel:onRenderListView(itemPanel, info)
    itemPanel:setVisible(true)

    local infoPanel = itemPanel:getChildByName("infoPanel")
    local bgImg = itemPanel:getChildByName("bgImg")
    local nameImg = itemPanel:getChildByName("nameImg")
    local num1 = infoPanel:getChildByName("num1")
    local allNum1 = infoPanel:getChildByName("allNum1")
    local num2 = infoPanel:getChildByName("num2")
    local allNum2 = infoPanel:getChildByName("allNum2")
    local tipTxt = itemPanel:getChildByName("tipTxt")

    local url = string.format("bg/legionCombatCenter/bg%d.jpg",info.id)
    TextureManager:updateImageViewFile(bgImg,url)

    local url = string.format("images/legionCombatCenter/title%d.png",info.id)
    TextureManager:updateImageView(nameImg,url)

    itemPanel.info = info
    self:addTouchEventListener(itemPanel, self.onCallItemTouch)

    if info.openFlag == 1 then -- 已开启
        infoPanel:setVisible(true)
        tipTxt:setVisible(false)
        num1:setString(info.curCapterCount.."/")
        allNum1:setString(info.maxCapterCount)
        num2:setString(info.curBoxCount.."/")
        allNum2:setString(info.maxBoxCount)
    else
        local str 
        if info.id ~= 1 then
            str = string.format(self:getTextWord(3603), self._conf[info.id-1].name)
        else
            str = self:getTextWord(3606)
        end
        tipTxt:setString(str)
        infoPanel:setVisible(false)
        tipTxt:setVisible(true)
    end
    self:showBoxCcb(info.curBoxCount, bgImg)

end

-- 打开关卡地图
function LegionCapterPanel:onCallItemTouch(item)
    logger:info("LegionCapterPanel:onCallItemTouch(item) -- 打开关卡地图 ..........0")
    if item.info.openFlag == 1 then
        self._dungeonXProxy:setCurChapterID(item.info.id)
        self:dispatchEvent(LegionCombatCenterEvent.SHOW_OTHER_EVENT,{moduleName = ModuleName.DungeonXModule, info = item.info})
        -- self:dispatchEvent(LegionCombatCenterEvent.SHOW_OTHER_EVENT,{name = ModuleName.DungeonXModule,id = sender.data.id,type = 1,info = sender.info})
    end
end

------
-- 显示可领取宝箱
function LegionCapterPanel:showBoxCcb(count, bgImg)
    local boxEffect = bgImg.boxEffect
    if count > 0 then
        if boxEffect == nil then
            boxEffect = UICCBLayer.new("rgb-zy-xiang", bgImg)
            boxEffect:setPosition(bgImg:getContentSize().width* 0.9, bgImg:getContentSize().height* 0.2)
            bgImg.boxEffect = boxEffect
        else
            boxEffect:setVisible(true)
        end
    else
        -- 隐藏
        if boxEffect ~= nil then
            boxEffect:setVisible(false)
        end
    end
end
