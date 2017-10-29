--region LegionKingTanPanel.lua
--Author : admin
--Date   : 2017/9/18
--此文件由[BabeLua]插件自动生成
LegionKingTanPanel = class("LegionKingTanPanel", BasicPanel)
LegionKingTanPanel.NAME = "LegionKingTanPanel"

function LegionKingTanPanel:ctor(view, panelName)
    LegionKingTanPanel.super.ctor(self, view, panelName,320)

    self:setUseNewPanelBg(true)
end

function LegionKingTanPanel:finalize()
    LegionKingTanPanel.super.finalize(self)

    if self._leftEffect~=nil then 
        self._leftEffect:finalize()
        self._leftEffect=nil
    end
    if self._rightEffect~=nil then 
        self._rightEffect:finalize()
        self._rightEffect=nil
    end
end

function LegionKingTanPanel:initPanel()
    LegionKingTanPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(560511))
end

function LegionKingTanPanel:registerEvents()
	LegionKingTanPanel.super.registerEvents(self)
end

function LegionKingTanPanel:onShowHandler(data)

     logger:info("show handler info .."..data.cityName)

     self:updateData(data)

    local Panel_34 =self:getChildByName("Panel_1/left_0")
    if self._leftEffect == nil then
      self._leftEffect = self:createUICCBLayer("rgb-fanye", Panel_34)
      self._leftEffect:setPosition(Panel_34:getContentSize().width/2+10,Panel_34:getContentSize().height/2)
    end
    local Panel_35 =self:getChildByName("Panel_1/right_0")
    if self._rightEffect ==nil then
       self._rightEffect = self:createUICCBLayer("rgb-fanye", Panel_35)
       self._rightEffect:setPosition(Panel_35:getContentSize().width/2+10,Panel_35:getContentSize().height/2)
       self._rightEffect:setScale(-1)
    end
end


function LegionKingTanPanel:updateData(data)
    local rewardList_1 =self:getChildByName("Panel_1/rewardList_1")

    local cityId =data.cityId
    local config =ConfigDataManager:getInfosFilterByOneKey(ConfigData.EmperorWarConfig,"ID" , cityId)
    local city =StringUtils:jsonDecode(config[1].occupyBuff)
    logger:info("         "..city[1])
    local buf = ConfigDataManager:getConfigById(ConfigData.EmperorWarBuffConfig, city[1])

    local rewardShow =StringUtils:jsonDecode(buf.buffInfo)
    self:renderListView(rewardList_1,rewardShow,self,self.renderItemRewardPanel)
    
end

function LegionKingTanPanel:renderItemRewardPanel(itemPanel,data,index)
    logger:info("第 "..index.." 四个字段 "..data[1].." "..data[2].."  "..data[3])
    local rewardInfo={}
    rewardInfo.power=data[1]
    rewardInfo.typeid = data[2]
    rewardInfo.num =data[3]
    local Label_40 =itemPanel:getChildByName("Label_40")
    Label_40:setVisible(false)
    local limitImg =itemPanel:getChildByName("limitImg")
    limitImg:setVisible(false)
   
    local Panel_39 = itemPanel:getChildByName("Panel_39")
    if itemPanel.icon == nil then
        local icon =UIIcon.new(Panel_39,rewardInfo,true,self,false,true)
        itemPanel.icon =icon
    else
        itemPanel.icon:updateData(rewardInfo)
    end


end
--endregion
