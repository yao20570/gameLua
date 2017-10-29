HeroPatchPanel = class("HeroPatchPanel",BasicPanel)
HeroPatchPanel.NAME = "HeroPatchPanel"
HeroPatchPanel.INSTEAD_HERO_PEICE_ID = 28  -- 升星魂的typeId

function HeroPatchPanel:ctor(view, panelName)
	HeroPatchPanel.super.ctor(self, view, panelName)
	
    self:setUseNewPanelBg(true)
end

function HeroPatchPanel:finalize()
	HeroPatchPanel.super.finalize(self)
end

function HeroPatchPanel:hideCallBack()
    -- 关闭时滑到最高
    if self._listView then
        self._listView:jumpToTop()
    end
end

function HeroPatchPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    local listView =  self:getChildByName("patchListView")
    NodeUtils:adaptiveListView(listView, GlobalConfig.downHeight,tabsPanel,GlobalConfig.topTabsHeight)
end

function HeroPatchPanel:initPanel()
    HeroPatchPanel.super.initPanel(self)
    self._listView = self:getChildByName("patchListView")
    --读取本地配置表
    self._HeroPieceConfig = ConfigDataManager:getConfigDataBySortId("HeroPieceConfig")
    local item = self._listView:getItem(0)
    item:setVisible(false)
end

function HeroPatchPanel:registerEvents()
    HeroPatchPanel.super.registerEvents(self)
end

function HeroPatchPanel:onAfterActionHandler()
    self:onShowHandler()
end

--碎片合成后更新界面
function HeroPatchPanel:onUpdateView()
    self:onShowHandler()
end


function HeroPatchPanel:onShowHandler()
	if self:isModuleRunAction() then
        return
    end
    
    local heroProxy = self:getProxy(GameProxys.Hero)
    local heroPiece = heroProxy:getHeroPiece()
    local heroPieceList = {}
    local heroPieceIndex = 1
    local HeroPieceConfig = self._HeroPieceConfig

    --根据服务端返回来的ID,到配置表得到对应的英雄
    for k,v in pairs(heroPiece) do
        for j,i in pairs(HeroPieceConfig) do
            if v.typeid == i.ID and v.num > 0 then
                heroPieceList[heroPieceIndex] = HeroPieceConfig[j]
                heroPieceList[heroPieceIndex].owner = v.num
                --索引从1开始
                heroPieceIndex = heroPieceIndex +  1
                break
            end
        end
    end
    
    --排序
    local heroData = self:sortByQuality(heroPieceList)
    --对数据处理，渲染时一行渲染两个
    local itemList = self:sortList(heroData)
    self:renderListView(self._listView, itemList, self, self.renderItemPanel, 6)
end


--排序：先排品质，再排ID
function HeroPatchPanel:sortByQuality(data)
    local temp = {}
    for i=1,table.size(data) do
        for j=1,table.size(data)-i do
            if data[j].quality < data[j+1].quality then
                temp = data[j]
                data[j] = data[j+1]
                data[j+1] = temp
            elseif data[j].quality == data[j+1].quality then
                if data[j].ID > data[j+1].ID then
                    temp = data[j]
                    data[j] = data[j+1]
                    data[j+1] = temp
                end
            end
        end
    end
    return data
end

--把二维数组变成三维数组
function HeroPatchPanel:sortList(itemList)
    local data = {}
    for i = 1, #itemList do
        --local index = math.floor((i + 1)/2)
        --if not data[index] then
        --    data[index] = {}
        --    data[index][1] = itemList[i]
        --else 
        --    data[index][2] = itemList[i]
        --end
        local index = math.floor((i - 1)/3)+1
        if not data[index] then
            data[index] = {}
        end 
        table.insert(data[index],#data[index]+1,itemList[i])
    end
    return data
end 


function HeroPatchPanel:renderItemPanel(listItem, data, index)
    listItem:setVisible(true)
    local itemBtn01 = listItem:getChildByName("Button_51")
    local itemBtn02 = listItem:getChildByName("Button_52")
    local itemBtn03 = listItem:getChildByName("Button_53")
    self:setItemView(itemBtn01,data[1], index)
    if #data == 1 then
        itemBtn02:setVisible(false)
        itemBtn03:setVisible(false)
    elseif #data == 2 then
        self:setItemView(itemBtn02,data[2], index)   
        itemBtn03:setVisible(false)
    else
        itemBtn02:setVisible(true)
        itemBtn03:setVisible(true)
        self:setItemView(itemBtn02,data[2], index)   
        self:setItemView(itemBtn03,data[3], index)    
    end
end


function HeroPatchPanel:setItemView(item, itemInfo, index)
    item:setVisible(true)
    local patchName = item:getChildByName("patchName")
    local contain = item:getChildByName("contain")
    local labDesc = item:getChildByName("labDesc")
    local btnHuoQu = item:getChildByName("btnHuoQu")
    local btnZhaoMu = item:getChildByName("btnZhaoMu")

    local patchCount = item:getChildByName("patchCount")
    local Label_80 = item:getChildByName("Label_80")
    patchCount:setVisible(false)
    Label_80:setVisible(false)

    patchCount:setString(itemInfo.owner)

    patchName:setString(itemInfo.name)
    local color = ColorUtils:getColorByQuality(itemInfo.quality)
    patchName:setColor(color)

    local icon = contain.icon
    local data = {}
    --data.customNumStr = self:getTextWord(290015)
    data.customNumStr = string.format(self:getTextWord(290083),itemInfo.owner)
    print("=========================>",itemInfo.owner,itemInfo.ID ,index)
    data.typeid = itemInfo.ID
    
    if itemInfo.ID == HeroPatchPanel.INSTEAD_HERO_PEICE_ID then
        data.power = GamePowerConfig.HeroFragment
    else
        data.power = GamePowerConfig.Hero
    end

    if icon == nil then
        icon = UIIcon.new(contain, data, true, self)
        contain.icon = icon
    else
        icon:updateData(data)
    end

    labDesc:setString(itemInfo.desc)

    if not (itemInfo.ID == HeroPatchPanel.INSTEAD_HERO_PEICE_ID) then
        if  itemInfo.owner >= itemInfo.num then
            btnHuoQu:setVisible(false)
            btnZhaoMu:setVisible(true)
            btnZhaoMu.data= itemInfo
            self:addTouchEventListener(btnZhaoMu,self.zhaoMuEvents)
        else
            btnHuoQu:setVisible(true)
            btnZhaoMu:setVisible(false)
            btnHuoQu.data= itemInfo
            self:addTouchEventListener(btnHuoQu,self.huoQuEvents)
        end
    else
        btnHuoQu:setVisible(true)
        btnZhaoMu:setVisible(false)
        btnHuoQu.data= itemInfo
        self:addTouchEventListener(btnHuoQu,self.huoQuEvents)
    end


    --item.data = itemInfo
    -- self:addTouchEventListener(item,self.useEvents)
end

function HeroPatchPanel:useEvents(sender)
	local panel = self:getPanel(HeroCompoundPanel.NAME)
    local data = sender.data
    panel:show(data)
end

--获取
function HeroPatchPanel:huoQuEvents(sender)
    local data = sender.data
    local roleProxy = self:getProxy(GameProxys.Role)
    local isOpen = roleProxy:isFunctionUnLock(6)
    if isOpen then
        local dungeonProxy = self:getProxy(GameProxys.Dungeon)
        -- dungeonProxy:sendNotification(AppEvent.PROXY_COLSE_EVENT)
        dungeonProxy:onExterInstanceSender(1)
        self:onClosePanelHandler()
        self:dispatchEvent(HeroHallEvent.HIDE_SELF_EVENT, {})
    else
        logger:warn("=========还没有开放===========")
    end
end

--招募
function HeroPatchPanel:zhaoMuEvents(sender)
    local data = sender.data
    --合成碎片
    local heroProxy = self:getProxy(GameProxys.Hero)
    -- 合成前先判断有没有该武将
    if heroProxy:getHeroNumById(data.compound) > 0 then
        self:showSysMessage(self:getTextWord(290077))
        return
    end
    
    heroProxy:onTriggerNet300100Req(data.ID)
    --self:onClosePanelHandler()
end