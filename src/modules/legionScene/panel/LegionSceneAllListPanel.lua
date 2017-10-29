-- /**
--  * @DateTime:    2016-01-14 11:07:18
--  * @Description: 军团列表
--  * @Description: 打开模块发送220100消息号获取了军团列表
--  */

LegionSceneAllListPanel = class("LegionSceneAllListPanel", BasicPanel)
LegionSceneAllListPanel.NAME = "LegionSceneAllListPanel"

function LegionSceneAllListPanel:ctor(view, panelName)
    LegionSceneAllListPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionSceneAllListPanel:finalize()
    LegionSceneAllListPanel.super.finalize(self)
end

function LegionSceneAllListPanel:initPanel()
	LegionSceneAllListPanel.super.initPanel(self)
    -- self:setBgType(ModulePanelBgType.BLACK)

    self._legionListView = self:getChildByName("center/legionListView")
    local item = self._legionListView:getItem(0)
    item:setVisible(false)
    
    --输入框
    local inputPanel = self:getChildByName("downPanel/inputPanel")
    local defualtTxt = self:getTextWord(3141)
    self._editeBox = ComponentUtils:addEditeBox(inputPanel,18,defualtTxt,nil,false)

    local topPanel = self:getChildByName("topPanel")
    local capacityTxt = topPanel:getChildByName("capacityTxt")
    capacityTxt:setString(self:getTextWord(144))
end

function LegionSceneAllListPanel:doLayout()
    --[[
    local downWidget = self:getChildByName("downPanel")
    -- local upWidget = self:getChildByName("topPanel")
    local bgPanel = self:getChildByName("center/bgPanel")--center
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptivePanelBg(bgPanel,GlobalConfig.downHeight,tabsPanel) --背景
    -- NodeUtils:adaptiveTopPanelAndListView(upWidget, self._legionListView, downWidget, tabsPanel)
    bgPanel:setContentSize(560,self._legionListView:getContentSize().height+50)
    local Image_35 =self:getChildByName("center/Image_35")
    --]]

    local downWidget = self:getChildByName("downPanel")
    local Image_35 = self:getChildByName("center/Image_35")
    local bgPanel = self:getChildByName("center/bgPanel")
    local legionListView = self:getChildByName("center/legionListView")
    local topPanel = self:getChildByName("topPanel")
    local tabsPanel = self:getTabsPanel()


    NodeUtils:adaptiveDownPanel(Image_35,downWidget,20)--固定下边缘

    NodeUtils:adaptiveUpPanel(topPanel,tabsPanel,0)--固定上边缘

    NodeUtils:adaptiveListView(legionListView, Image_35, topPanel,0)

    NodeUtils:adaptiveListView(bgPanel,Image_35,topPanel,0,0)


end

function LegionSceneAllListPanel:onTabChangeEvent(tabControl)
    local downWidget = self:getChildByName("downPanel")
    LegionSceneAllListPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

function LegionSceneAllListPanel:registerEvents()
	LegionSceneAllListPanel.super.registerEvents(self)

    local resetBtn = self:getChildByName("downPanel/resetBtn")
    local searchBtn = self:getChildByName("downPanel/searchBtn")
    self:addTouchEventListener(resetBtn,self.onCleanBtnTouch)
    self:addTouchEventListener(searchBtn,self.onSearchBtnTouch)
end

function LegionSceneAllListPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionSceneAllListPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionSceneAllListPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
    if self._legionListView then
        self._legionListView:jumpToTop()
    end
    -- body
    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220100Req({})
end


-- 军团列表界面更新 来自协议220100的数据
function LegionSceneAllListPanel:onLegionAllListResp(data)
    -- body
    self._legionListInfos = data
    if self._legionListInfos == nil then
        self._legionListInfos = {}
    end
    self:onRenderHandler(data)
    --print("刷新公会同盟列表")
end

-- 军团列表界面更新
function LegionSceneAllListPanel:onRenderHandler(data)
    -- body
    local legionListView = self._legionListView

    local roleProxy = self:getProxy(GameProxys.Role)
    local name = roleProxy:getLegionName()
    
    -- 去掉自身公会信息
    local info = nil
    for k,v in pairs(data) do
        if v.name == name then
            info = v
            table.remove(data, k)
        end
    end
    
    -- 根据rank字段排序
    table.sort(data, 
    function(a,b) 
        return a.rank < b.rank -- 根据rank字段排序 
    end)

    if info ~= nil then
        table.insert(data, 1, info) -- 插入第一个的公会信息
    end

    self:renderListView(legionListView, data, self, self.renderItemPanel)
    self._legionListView:setItemsMargin(0)
end

function LegionSceneAllListPanel:renderItemPanel(itemPanel, info, index)
    
    itemPanel:setVisible(true)
    local rankTxt = itemPanel:getChildByName("rankTxt")
    local rankImg = itemPanel:getChildByName("rankImg")
    local nameTxt = itemPanel:getChildByName("nameTxt")
    local levelTxt = itemPanel:getChildByName("levelTxt")
    local numTxt = itemPanel:getChildByName("numTxt")
    local capacityTxt = itemPanel:getChildByName("capacityTxt")
    local imgTouch = itemPanel:getChildByName("imgTouch")
    --活跃度
    local activeLevel = itemPanel:getChildByName("activeLevel")
    -- activeLevel:setVisible(false)
    local activeUrl = "images/legionScene/activeLevel_" .. info.oomph .. ".png"
    TextureManager:updateImageView(activeLevel,activeUrl)
    if info.oomph == 0 then
        activeLevel:setVisible(false)
    else
        activeLevel:setVisible(true)
    end 

    imgTouch:setVisible(false)
    rankTxt:setString(info.rank)
    nameTxt:setString(info.name)
    levelTxt:setString(info.level)
    numTxt:setString(string.format("(%d/%d)", info.curNum, info.maxNum))
    capacityTxt:setString(StringUtils:formatNumberByK(info.capacity, 0))

    -- print("列表显示数据：军团名称 name= "..info.name.."，排名 rank= "..info.rank.."，等级 level= "..info.level)

    local mineBg = itemPanel:getChildByName("mineBg")
    if index == 0 then
        mineBg:setVisible(true)
    else
        mineBg:setVisible(false)
    end

    local bgImg = itemPanel:getChildByName("bgImg")
    -- if info.rank % 2 == 1 then
    if index % 2 == 1 then
        bgImg:setVisible(true)
    else
        bgImg:setVisible(false)
    end

    
    local color = cc.c3b(255,255,255)--ColorUtils.wordColorLight02
    local rank = info.rank
    rankTxt:setVisible(true)
    rankImg:setVisible(false)
    if rank > 3 then
        rankTxt:setString(rank)
    else
        local url = ""
        if rank == 1 then
            url = "images/newGui2/IconNum_1.png"
            color = ColorUtils:color16ToC3b(ColorUtils.commonColor.Orange)--ColorUtils.wordAddColor
        elseif rank == 2 then
            url = "images/newGui2/IconNum_2.png"
            color = ColorUtils:color16ToC3b(ColorUtils.commonColor.Violet)--ColorUtils.wordPurpleColor
        elseif rank == 3 then
            url = "images/newGui2/IconNum_3.png"
            color = ColorUtils:color16ToC3b(ColorUtils.commonColor.Blue)--ColorUtils.wordBlueColor
        end

        -- TextureManager:updateImageView(rankImg, url)
        rankImg:loadTexture(url, ccui.TextureResType.plistType)
        rankImg:setVisible(true)
        rankTxt:setString("")
    end

    nameTxt:setColor(color)
    
    itemPanel.info = info
    if itemPanel.isAddEvent ~= true then
        itemPanel.isAddEvent = true
        self:addTouchEventListener(itemPanel, self.onItemPanelTouch,self.onItemPanelTouchBegin)
        itemPanel.cancelCallback = function() 
            imgTouch:setVisible(false)
        end
    end 
end
function LegionSceneAllListPanel:onItemPanelTouchBegin(sender)
    local imgTouch = sender:getChildByName("imgTouch")
    imgTouch:setVisible(true)
end
--查看其他军团详细信息
function LegionSceneAllListPanel:onItemPanelTouch(sender)
    local info = sender.info
    --TODO 查看其他军团详细信息

    local panel = self:getPanel(LegionSceneOtherInfoPanel.NAME)
    panel:show()
    panel:onShowHandlerNew(info) -- 发送消息

    local imgTouch = sender:getChildByName("imgTouch")
    imgTouch:setVisible(false)
end


--清除
function LegionSceneAllListPanel:onCleanBtnTouch(sender)
    self._editeBox:setText("")
    -- local infos = self._legionListInfos
    self:updateLegionList(self._legionListInfos)
end

--搜索
function LegionSceneAllListPanel:onSearchBtnTouch(sender)
    local name = self._editeBox:getText()
    -- print("name===",name)
    if name == "" or name == nil then
        local tempStr = self:getTextWord(3142)
        self:showSysMessage(tempStr)
        return 
    end 
    local data = {}
    data.name = name
    self.view:dispatchEvent(LegionSceneEvent.LEGIONSCENE_SEARCH_REQ ,data)
end 

function LegionSceneAllListPanel:onSearchLegionInfos(data)
    -- body
    -- print("···onSearchLegionInfos ")
    self:updateLegionList(data)
end

--筛选、清除、搜索
function LegionSceneAllListPanel:updateLegionList(listInfos)
    -- print("updateLegionList ")
    self:onRenderHandler(listInfos)
end 