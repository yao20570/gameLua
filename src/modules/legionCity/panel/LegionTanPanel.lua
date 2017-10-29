--region LegionTanPanel.lua
--Author : admin
--Date   : 2017/9/18
--此文件由[BabeLua]插件自动生成


LegionTanPanel = class("LegionTanPanel", BasicPanel)
LegionTanPanel.NAME = "LegionTanPanel"

function LegionTanPanel:ctor(view, panelName)
    LegionTanPanel.super.ctor(self, view, panelName,500)

    self:setUseNewPanelBg(true)
end

function LegionTanPanel:finalize()
    LegionTanPanel.super.finalize(self)

        if self._leftEffect~=nil then 
        self._leftEffect:finalize()
        self._leftEffect=nil
    end
    if self._rightEffect~=nil then 
        self._rightEffect:finalize()
        self._rightEffect=nil
    end
end

function LegionTanPanel:initPanel()
    LegionTanPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(560511))
    self._proxy = self:getProxy(GameProxys.Legion)
end

function LegionTanPanel:registerEvents()
	LegionTanPanel.super.registerEvents(self)
end

function LegionTanPanel:onShowHandler(data)
       logger:info("show handler info .."..data.cityName)

       self:resetData()
       self:updateData(data)

    local Panel_34 =self:getChildByName("Panel_1/left")
    if self._leftEffect == nil then
      self._leftEffect = self:createUICCBLayer("rgb-fanye", Panel_34)
      self._leftEffect:setPosition(Panel_34:getContentSize().width/2+10,Panel_34:getContentSize().height/2)
    end
    local Panel_35 =self:getChildByName("Panel_1/right")
    if self._rightEffect ==nil then
       self._rightEffect = self:createUICCBLayer("rgb-fanye", Panel_35)
       self._rightEffect:setPosition(Panel_35:getContentSize().width/2+10,Panel_35:getContentSize().height/2)
       self._rightEffect:setScale(-1)
    end
    
end

function LegionTanPanel:resetData()
    
end

function LegionTanPanel:updateData(data)   
    if data.panel == LegionTownPanel.NAME then 
        self:updateTown(data)
    elseif data.panel == LegionCapitalPanel.NAME then 
        self:updateCapital(data)
    end
end

function LegionTanPanel:updateTown(data)
    local cityId =data.cityId
    local townWar =ConfigDataManager:getConfigById(ConfigData.TownWarConfig, cityId)
    --
    local pointRewardGroupID =townWar.pointRewardGroupID
    local configTownWarReward = ConfigDataManager:getInfosFilterByOneKey(ConfigData.TownWarPointRewardConfig, "rewardGroup",pointRewardGroupID )
    local level =self._proxy:getMineInfo().level

    local rewardGroup = {}
    for k,v in pairs(configTownWarReward) do
           local legionLv =v.legionLv
           local lv1 = StringUtils:jsonDecode(legionLv)
           if level >= lv1[1] and level <= lv1[2] then
                rewardGroup = v.pointReward
           end
    end
    local cityBuffID = StringUtils:jsonDecode(townWar.cityBuffID)
    logger:info("cityBuffID    .."..cityBuffID[1])

    local townWarBuff = ConfigDataManager:getInfosFilterByOneKey(ConfigData.TownWarBuffConfig,"buffGroundId",cityBuffID[1])
    local len =#townWarBuff
    local labs = {}
    for i=1,4 do
        labs[i] = self:getChildByName("Panel_1/lab"..i)
        if i<= len then
            labs[i]:setVisible(true)
            labs[i]:setString(townWarBuff[i].buffInfo)
        else
            labs[i]:setVisible(false)
        end
    end

    
    --local rewardShow =StringUtils:jsonDecode(townWar.rewardShow)
    local ListView_37 =self:getChildByName("Panel_1/rewardList")
    self:renderListView(ListView_37, StringUtils:jsonDecode(rewardGroup), self, self.renderItemRewardPanel,nil,true,0)

    local resetLab =self:getChildByName("Panel_1/resetLab")
    resetLab:setString(TextWords:getTextWord(560529))

end

function LegionTanPanel:updateCapital(data)

    local cityId =data.cityId
    logger:info("city id  "..cityId)
    local cityTips =ConfigDataManager:getInfosFilterByOneKey(ConfigData.CityTipConfig,"groupID", cityId)
    local len =#cityTips
    local labs = {}
    for i=1,4 do
        labs[i] = self:getChildByName("Panel_1/lab"..i)
        if i<= len then
            labs[i]:setVisible(true)
            labs[i]:setString(cityTips[i].panelTip)
        else
            labs[i]:setVisible(false)
        end
    end

    local reward =ConfigDataManager:getConfigById(ConfigData.CityRewardConfig,cityId)
    local rewardShow =StringUtils:jsonDecode(reward.cityReward)
    local ListView_37 =self:getChildByName("Panel_1/rewardList")
    self:renderListView(ListView_37,rewardShow,self,self.renderItemRewardPanel)

    local resetLab =self:getChildByName("Panel_1/resetLab")
    resetLab:setString(TextWords:getTextWord(560530))
end


function LegionTanPanel:renderItemRewardPanel(itemPanel,data,index)
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
