
PWMaterialPanel = class("PWMaterialPanel", BasicPanel)
PWMaterialPanel.NAME = "PWMaterialPanel"

function PWMaterialPanel:ctor(view, panelName)
    PWMaterialPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function PWMaterialPanel:finalize()
    PWMaterialPanel.super.finalize(self)
end

function PWMaterialPanel:initPanel()
    PWMaterialPanel.super.initPanel(self)
    
    local listView = self:getChildByName("ListView")
    local item = listView:getItem(0)
    listView:setItemModel(item)
    item:setVisible(true)
--    NodeUtils:adaptive(listView)
    self._listView = listView

--[[
    self.midTabConf = {
        {
            title = "刀兵",
            selectColor = ColorUtils:color16ToC3b(ColorUtils.commonColor.White),
            unSelectColor = ColorUtils:color16ToC3b(ColorUtils.commonColor.MiaoShu),
        },
        {
            title = "骑兵",
            selectColor = ColorUtils:color16ToC3b(ColorUtils.commonColor.White),
            unSelectColor = ColorUtils:color16ToC3b(ColorUtils.commonColor.MiaoShu),
        },
        {
            title = "枪兵",
            selectColor = ColorUtils:color16ToC3b(ColorUtils.commonColor.White),
            unSelectColor = ColorUtils:color16ToC3b(ColorUtils.commonColor.MiaoShu),
        },
        {
            title = "弓兵",
            selectColor = ColorUtils:color16ToC3b(ColorUtils.commonColor.White),
            unSelectColor = ColorUtils:color16ToC3b(ColorUtils.commonColor.MiaoShu),
        }
    }
    self._pnlMid = self:getChildByName("pnlMid")
    self._midTab = {}
    for i =1,4 do
        self._midTab[i] = self._pnlMid:getChildByName("midTab" .. i)
        self._midTab[i].idx = i
        self._midTab[i]:setTitleText(self.midTabConf[i].title)
        if self._midTab[i] == 1 then
            self:setMidTabSelect(self._midTab[i],true)
        else
            self:setMidTabSelect(self._midTab[i],false)
        end
        self:addTouchEventListener(self._midTab[i], self.midTabTouch)
    end
    --]]
end

function PWMaterialPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listView,GlobalConfig.downHeight,tabsPanel,GlobalConfig.topTabsHeight)
end

function PWMaterialPanel:onShowHandler()
    PWMaterialPanel.super.onShowHandler(self)
    self:updateListView()
end 
function PWMaterialPanel:updateListView(data)
    
    local materialInfos = self:getMaterialInfos()
    if materialInfos == nil then
        materialInfos = {}
    end   
    self:renderListView(self._listView, materialInfos, self, self.renderItemPanel,nil,nil,LayoutConfig.scrollViewRowSpace)
     
end 

function PWMaterialPanel:renderItemPanel(listItem, data, index)
    --[[
    local panelItem01 = listItem:getChildByName("panelItem01")
    local panelItem02 = listItem:getChildByName("panelItem02")
    self:setItemView(panelItem01,data[1], index)
    if #data == 1 then
        panelItem02:setVisible(false)
    else 
        panelItem02:setVisible(true)
        self:setItemView(panelItem02,data[2], index)    
    end
    --]]
    for i = 1,3 do
        local panelItem = listItem:getChildByName("panelItem0" .. i)
        if  data[i] then
            panelItem:setVisible(true)
            self:setItemView(panelItem,data[i], index)  
        else
            panelItem:setVisible(false)
        end

    end
end

function PWMaterialPanel:setItemView(itemPanel,info, index)
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
        local uiIcon = UIIcon.new(imgIcon,data,false,self)
        uiIcon:setPosition(imgIcon:getContentSize().width/2,imgIcon:getContentSize().height/2)
        imgIcon.uiIcon = uiIcon
    else
        imgIcon.uiIcon:updateData(data)
    end
    --名字
    local labelName = itemPanel:getChildByName("nameTxt")
    labelName:setString(configData.name)
    labelName:setColor(ColorUtils:getColorByQuality(configData.color))
    --描述
    local labelDec = itemPanel:getChildByName("memoTxt")
    labelDec:setString(configData.info)
    --数量
    local labelNum = itemPanel:getChildByName("countTxt")
    labelNum:setString(StringUtils:formatNumberByK3(serverData.num))
    local frontTxtX = labelName:getPositionX()
    local width     = labelName:getContentSize().width 
    -- labelNum:setPositionX(frontTxtX + width)
    -- 数量:
    local labShuLiang = itemPanel:getChildByName("labShuLiang")
    NodeUtils:centerNodes(imgIcon,{
            labelNum,labShuLiang
        })

end 
--获取玩家材料
function PWMaterialPanel:getMaterialInfos()
    local itemProxy = self:getProxy(GameProxys.Item)
    local itemInfos= itemProxy:getItemByClassify(4, ItemBagTypeConfig.PARTS_MASTERIAL_BAG)
    local materialInfos = {}
    for _,v in pairs(itemInfos) do
        local configInfo = v.excelInfo
        -- if configInfo.type == 17 then
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
		    local index = math.floor((i - 1)/3)+1
		    if not data[index] then
			    data[index] = {}
		    end
            table.insert(data[index],itemList[i])
	    end
	    return data
    end

    return sortData(materialInfos)
end 



function PWMaterialPanel:midTabTouch(sender)
    local idx = sender.idx 
    if idx then
        logger:info("idx ===================== " .. idx)
    end    
end

PWMaterialPanel.MidSelectEnableUrl = string.format("images/newGui2/BtnTab_normal.png")
PWMaterialPanel.MidSelectDisableUrl = string.format("images/newGui2/BtnTab_selected.png")
function PWMaterialPanel:setMidTabSelect(midTabItem,bool)
    if midTabItem then
        local idx = midTabItem.idx
        if idx then
            if bool then
                TextureManager:updateButtonNormal(midTabItem, 
                                                    PWMaterialPanel.MidSelectEnableUrl,
                                                    PWMaterialPanel.MidSelectEnableUrl)
                midTabItem:setTitleColor(self.midTabConf[idx].selectColor)
            else
                TextureManager:updateButtonNormal(midTabItem, 
                                                    PWMaterialPanel.MidSelectDisableUrl,
                                                    PWMaterialPanel.MidSelectDisableUrl)
                midTabItem:setTitleColor(self.midTabConf[idx].unSelectColor)
            end
        else
            logger:error("PWMaterialPanel:setMidTabSelect:idx 为空")
        end
    else
        logger:error("PWMaterialPanel:setMidTabSelect:midTabItem 为空")
    end
end