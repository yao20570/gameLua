
HeroTreaMaterialPanel = class("HeroTreaMaterialPanel", BasicPanel)
HeroTreaMaterialPanel.NAME = "HeroTreaMaterialPanel"

function HeroTreaMaterialPanel:ctor(view, panelName)
    HeroTreaMaterialPanel.super.ctor(self, view, panelName)

end

function HeroTreaMaterialPanel:finalize()
    HeroTreaMaterialPanel.super.finalize(self)
end

function HeroTreaMaterialPanel:initPanel()
    HeroTreaMaterialPanel.super.initPanel(self)
    
    local listView = self:getChildByName("ListView")
    local item = listView:getItem(0)
    listView:setItemModel(item)
    item:setVisible(true)
--    NodeUtils:adaptive(listView)
    self._listView = listView
    
    
end

function HeroTreaMaterialPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView,GlobalConfig.downHeight,tabsPanel,GlobalConfig.topTabsHeight)
end

function HeroTreaMaterialPanel:onShowHandler()
    HeroTreaMaterialPanel.super.onShowHandler(self)
    self:updateListView()
end 
function HeroTreaMaterialPanel:updateListView(data)
    
    local materialInfos = self:getMaterialInfos()
    if materialInfos == nil then
        materialInfos = {}
    end   
    self:renderListView(self._listView, materialInfos, self, self.renderItemPanel)
     
end 

function HeroTreaMaterialPanel:renderItemPanel(listItem, data, index)

    local panelItem01 = listItem:getChildByName("panelItem01")
    local panelItem02 = listItem:getChildByName("panelItem02")
    self:setItemView(panelItem01,data[1], index)
    if #data == 1 then
        panelItem02:setVisible(false)
    else 
        panelItem02:setVisible(true)
        self:setItemView(panelItem02,data[2], index)    
    end
    
end

function HeroTreaMaterialPanel:setItemView(itemPanel,info, index)
    local configData = info.excelInfo
    local serverData = info.serverData
    --图标
    local imgIcon = itemPanel:getChildByName("iconImg")
    -- imgIcon:removeAllChildren()
    local data = {}
    data.num = serverData.num
    data.power = GamePowerConfig.Item
    data.typeid = serverData.typeid
    if imgIcon.uiIcon == nil then
        imgIcon.uiIcon = UIIcon.new(imgIcon,data,false,self)
    else
        imgIcon.uiIcon:updateData(data)
    end

    -- local uiIcon = UIIcon.new(imgIcon,data,false,self)
    -- uiIcon:setPosition(imgIcon:getContentSize().width/2,imgIcon:getContentSize().height/2)
    --名字
    local labelName = itemPanel:getChildByName("nameTxt")
    labelName:setString(configData.name)
    labelName:setColor(ColorUtils:getColorByQuality(configData.color))
    --描述
    local labelDec = itemPanel:getChildByName("memoTxt")
    labelDec:setString(configData.info)
    --数量
    local labelNum = itemPanel:getChildByName("countTxt")
    labelNum:setString("*"..serverData.num)
    local frontTxtX = labelName:getPositionX()
    local width     = labelName:getContentSize().width 
    labelNum:setPositionX(frontTxtX + width)
end 
--获取玩家材料
function HeroTreaMaterialPanel:getMaterialInfos()
    local itemProxy = self:getProxy(GameProxys.Item)
    local itemInfos= itemProxy:getItemByClassify(4, ItemBagTypeConfig.TREA_MASTRIAL_BAG)
    local materialInfos = {}
    for _,v in pairs(itemInfos) do
        local configInfo = v.excelInfo
        -- if configInfo.type == 40 then
            table.insert(materialInfos,v)
        -- end 
    end 
    table.sort(materialInfos,function(a,b) 
                                return a.serverData.typeid < b.serverData.typeid
                              end )
    
    -- 分类
    local sortData = function(itemList)
        local data = {}
	    for i = 1, #itemList do
		    local index = math.floor((i + 1)/2)
		    if not data[index] then
			    data[index] = {}
			    data[index][1] = itemList[i]
		    else 
			    data[index][2] = itemList[i]
		    end
	    end
	    return data
    end

    return sortData(materialInfos)
end 

