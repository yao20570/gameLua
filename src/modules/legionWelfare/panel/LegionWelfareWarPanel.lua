-- 战事福利
LegionWelfareWarPanel = class("LegionWelfareWarPanel", BasicPanel)
LegionWelfareWarPanel.NAME = "LegionWelfareWarPanel"

function LegionWelfareWarPanel:ctor(view, panelName)
    LegionWelfareWarPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionWelfareWarPanel:finalize()
    LegionWelfareWarPanel.super.finalize(self)
end

function LegionWelfareWarPanel:initPanel()
	LegionWelfareWarPanel.super.initPanel(self)
    local listView = self:getChildByName("ListView")
    local downPanel = self:getChildByName("downPanel")
    self._listView = listView
    self._downPanel = downPanel

    self._tipTxt = self._downPanel:getChildByName("Label_tip")
    self._tipTxt:setString(self:getTextWord(3418)) -- "同盟战中获得奖品，盟主或副盟主可以分配给盟员"

    self:updateListView()

    --self.view:dispatchEvent(LegionWelfareEvent.WELFARE_ALLOT_LIST_REQ,nil) --请求战事福利数据
    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220016Req()
end

function LegionWelfareWarPanel:doLayout()
    local downPanel = self:getChildByName("downPanel")
    local upWidget = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView,downPanel,upWidget,GlobalConfig.topTabsHeight)
end

function LegionWelfareWarPanel:registerEvents()
    LegionWelfareWarPanel.super.registerEvents(self)
    
    -- local detailBtn = self:getChildByName("Panel_bottom/Button_detail")
    local detailBtn = self._downPanel:getChildByName("Button_detail")
    self:addTouchEventListener(detailBtn,self.onDetailBtnClicked)

    

end
function LegionWelfareWarPanel:onShowHandler(data)
    if self:isModuleRunAction() then
        return
    end
    
    LegionWelfareWarPanel.super.onShowHandler(self)
    if self._listView ~= nil then
        self._listView:jumpToTop()
    end
    self:updateListView()
end

function LegionWelfareWarPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionWelfareWarPanel:updateListView()
    local len = 0
    local newlist = {}

    local legionProxy = self:getProxy(GameProxys.Legion)
    local itemList = legionProxy:getWelfareLists() or {}

    for i, data in ipairs( itemList ) do
        if data.number and data.number>0 then
            len = len + 1
            local index = math.ceil( len/3 )
            newlist[index] = newlist[index] or {}
            table.insert( newlist[index], data )
        end
    end
    self:renderListView(self._listView, newlist, self, self.renderItemPanel)
end

-- --重设数量
-- function LegionWelfareWarPanel:updateListData( typeid, number )
--     -- for i, data in ipairs( self._itemList ) do
--     --     if typeid and typeid==data.type then 
--     --         data.number = number
--     --     end
--     -- end
--     -- self:updateListView( self._itemList )
-- end

function LegionWelfareWarPanel:renderItemPanel( listItem, data )
    -- local itemBtn01 = listItem:getChildByName("itemBtn01")
    -- local itemBtn02 = listItem:getChildByName("itemBtn02")
    -- self:setItemView(itemBtn01,data[1], index)
    -- if #data == 1 then
    --     itemBtn02:setVisible(false)
    -- else
    --     itemBtn02:setVisible(true)
    --     self:setItemView(itemBtn02,data[2], index)    
    -- end
    local itemBtn01 = listItem:getChildByName("itemBtn01")
    local itemBtn02 = listItem:getChildByName("itemBtn02")
    local itemBtn03 = listItem:getChildByName("itemBtn03")
    self:setItemView(itemBtn01,data[1], index)
    if #data == 1 then
        itemBtn02:setVisible(false)
        itemBtn03:setVisible(false)
    elseif #data == 2 then
        itemBtn02:setVisible(true)
        itemBtn03:setVisible(false)
        self:setItemView(itemBtn02,data[2], index)  
    else
        itemBtn02:setVisible(true)
        self:setItemView(itemBtn02,data[2], index)  
        itemBtn03:setVisible(true)
        self:setItemView(itemBtn03,data[3], index)  
    end
end

function LegionWelfareWarPanel:setItemView( itemPanel, data )
    local imgIcon = itemPanel:getChildByName("Image_icon")
    local labelName = itemPanel:getChildByName("nameTxt")
    local labelNum = itemPanel:getChildByName("count")
    local btnSelect = itemPanel:getChildByName("btnSelect")
    local labelNumKey = itemPanel:getChildByName("descripe")

    local typeid = data.type or 0
    local number = data.number or 0
    local info = ConfigDataManager:getInfoFindByOneKey("ItemConfig", "ID", typeid) or {}
    labelName:setString( info.name or "" )
    labelName:setColor( ColorUtils:getColorByQuality(info.color or 1) )
    labelNum:setString( number )

    NodeUtils:alignNodeL2R(labelNumKey,labelNum)
    NodeUtils:centerNodes(imgIcon, {labelNumKey,labelNum})

    local itemData = {
        power = data.power or 0,
        typeid = typeid,
        num = number,
    }
    local icon = imgIcon.icon
    if icon == nil then
        icon = UIIcon.new(imgIcon, itemData, true, self)
        imgIcon.icon = icon
    else
        icon:updateData( itemData )
    end

    -- itemPanel.data = data
    -- self:addTouchEventListener( itemPanel, self.onClickItemfn )

    btnSelect.data = data
    self:addTouchEventListener( btnSelect, self.onClickItemfn )

end 
-------------回调函数定义----------------

--民情跳转
function LegionWelfareWarPanel:onDetailBtnClicked(sender)
    ModuleJumpManager:jump( ModuleName.LegionAdviceModule, "LegionAdvicePeoplePanel" )
end

--点击item  ->弹分配福利界面
function LegionWelfareWarPanel:onClickItemfn( obj )
    local legionProxy = self:getProxy(GameProxys.Legion)
    legionProxy:onTriggerNet220016Req()
    print("------------------再次请求 220016")
    local nJob = legionProxy:getMineJob()
    if nJob == 7 or nJob == 6 then  -- 需要盟主或副盟主才可以分配战事福利
        local panel = self:getPanel(LegionWelfareWarAllotPanel.NAME)
        panel:show()
        panel:updateInfo( obj.data )
    else
        self:showSysMessage(self:getTextWord(3034))
    end
end

function LegionWelfareWarPanel:tryCloseAllotPanel()
    
end