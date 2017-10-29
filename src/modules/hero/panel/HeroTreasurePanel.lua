-- /**
--  * @DateTime:    2016-10-09 
--  * @Description: 宝具模块（宝具主界面）
--  * @Author: lizhuojian
--  */
HeroTreasurePanel = class("HeroTreasurePanel", BasicPanel)
HeroTreasurePanel.NAME = "HeroTreasurePanel"

function HeroTreasurePanel:ctor(view, panelName)
    HeroTreasurePanel.super.ctor(self, view, panelName,650)
    
    self:setUseNewPanelBg(true)
end

function HeroTreasurePanel:finalize()
    if self.treasureEffect ~= nil then
        self.treasureEffect:finalize()
        self.treasureEffect = nil
    end
    if self.treasureQianEffect ~= nil then
        self.treasureQianEffect:finalize()
        self.treasureQianEffect = nil
    end
    HeroTreasurePanel.super.finalize(self)
end

function HeroTreasurePanel:initPanel()
	HeroTreasurePanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.HeroTreasure)
    self:setTitle(true, self:getTextWord(3803))
    -- self:setTitle(true, "partsWarehouse", true)
  
    --宝具名称图
	self._treasureNameImg = self:getChildByName("mainPanel/infoPanel/treasureNameImg")
    --宝具颜色图
	self._treasureColorImg = self:getChildByName("mainPanel/infoPanel/treasureColorImg")
    --宝具阶级
	self._treasureStageNumImg = self:getChildByName("mainPanel/infoPanel/stageNumImg")
    --宝具图标
	self._treasureImg = self:getChildByName("mainPanel/infoPanel/treasureImg/img")
    --宝具图标特效节点
    self._treasureEffectNode = self:getChildByName("mainPanel/infoPanel/treasureImg/effectNode")
    self._treasureImgPanel = self:getChildByName("mainPanel/infoPanel/treasureImg")
    --基础属性
    for i=1,3 do
        self["_basalAttPanel" .. i] = self:getChildByName("mainPanel/basalAttPanel/basalAttPanel".. i)
		self["_basalAttImg" .. i] = self:getChildByName("mainPanel/basalAttPanel/basalAttPanel".. i .."/basalAttImg/iconImg")
		self["_basalAttNameLab" .. i] = self:getChildByName("mainPanel/basalAttPanel/basalAttPanel".. i .."/descLab")
		self["_basalAttNumLab" .. i] = self:getChildByName("mainPanel/basalAttPanel/basalAttPanel".. i .."/addLab")
	end
    --洗炼属性
    for i=1,4 do
        self["_highAttPanel" .. i] = self:getChildByName("mainPanel/highAttPanel/highAttPanel".. i)
		self["_highAttImg" .. i] = self:getChildByName("mainPanel/highAttPanel/highAttPanel".. i .."/attImg/iconImg")
		self["_highAttTypeLab" .. i] = self:getChildByName("mainPanel/highAttPanel/highAttPanel".. i .."/attTypeLab")
		self["_highAttlevelLab" .. i] = self:getChildByName("mainPanel/highAttPanel/highAttPanel".. i .."/attlevelLab")
	end
    --培养按钮
    local trianBtn = self:getChildByName("mainPanel/trainBtn")
    self:addTouchEventListener(trianBtn, self.showHeroTreasureTrain)
    --更换按钮
   	local changeBtn = self:getChildByName("mainPanel/changeBtn")
    self:addTouchEventListener(changeBtn, self.showHeroTreasureChange)
    --武器与坐骑偏移不一
    self._treasureImgYOffset = {130,40}
    --特效
    self.allJianEffectName = {"rgb-jianlv-hou", "rgb-jianlan-hou", "rgb-jianzi-hou", "rgb-jianhuang-hou"}
    self.allMaEffectName = {"rgb-malv-hou", "rgb-malan-hou", "rgb-mazi-hou", "rgb-mahuang-hou"}
    self.allJianQianEffectName = {"rgb-jianlv-qian", "rgb-jianlan-qian", "rgb-jianzi-qian", "rgb-jianhuang-qian"}
    self.allMaQianEffectName = {"rgb-malv-qian", "rgb-malan-qian", "rgb-mazi-qian", "rgb-mahuang-qian"}
    self.num = 10
end
function HeroTreasurePanel:onShowHandler(data)
    self:updateView(data)
end

--界面刷新
function HeroTreasurePanel:updateView(data)
    self.treasureData = data
    local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, self.treasureData.typeid)


    local  treasureNameImgUrl = self.proxy:getTreasureNameImgUrl(self.treasureData.typeid)
    TextureManager:updateImageView(self._treasureNameImg, treasureNameImgUrl)

    local  colorImgUrl = self.proxy:getTreasureColorImgUrl(self.treasureData.typeid)
    TextureManager:updateImageView(self._treasureColorImg, colorImgUrl)

    local  stageNumImgUrl = self.proxy:getTreasureStageNumImgUrl(self.treasureData.id)
    TextureManager:updateImageView(self._treasureStageNumImg, stageNumImgUrl)

    local  treasureImgUrl = self.proxy:getTreasureImgUrl(self.treasureData.typeid)
    TextureManager:updateImageView(self._treasureImg, treasureImgUrl)
    if self.treasureEffect ~= nil then
        self.treasureEffect:finalize()
        self.treasureEffect = nil
    end
    if self.treasureQianEffect ~= nil then
        self.treasureQianEffect:finalize()
        self.treasureQianEffect = nil
    end
    
    if self.treasureData.part == 0 then
                        --剑需要浮动动画
        self:playAction("jian_fudong")
        self._treasureImgPanel:setScale(0.7)
        self._treasureImgPanel:setPositionY(self._treasureImgYOffset[1])  
        local color = config.color or 1
        if color > 1 then
            self.treasureEffect = UICCBLayer.new(self.allJianEffectName[color-1], self._treasureEffectNode)
            local size = self._treasureImg:getContentSize()
            self.treasureEffect:setPosition(0, size.height*0.5)
            self.treasureQianEffect = UICCBLayer.new(self.allJianQianEffectName[color-1], self._treasureImgPanel)
            self.treasureQianEffect:setPosition(0, size.height*0.5)
            
        end
        
    else
        self:stopAction("jian_fudong")
        self._treasureImgPanel:setScale(0.9)
        self._treasureImgPanel:setPositionY(self._treasureImgYOffset[2])  
        local color = config.color or 1
        if color > 1 then
            self.treasureEffect = UICCBLayer.new(self.allMaEffectName[color-1], self._treasureEffectNode)
            local size = self._treasureImg:getContentSize()
            self.treasureEffect:setPosition(size.width*0.1, size.height*0.2)
            self.treasureQianEffect = UICCBLayer.new(self.allMaQianEffectName[color-1], self._treasureImgPanel)
            self.treasureQianEffect:setPosition(0, size.height*0.2)
        end
    end


    --基础属性
    for i=1,3 do
        self["_basalAttPanel" .. i]:setVisible(false)
	end
    local addInfo = self.proxy:getBasalAttInfoByTreasureDbID(self.treasureData.id)
    for k,v in pairs(addInfo) do
        local nameInfo = ConfigDataManager:getConfigById(ConfigData.ResourceConfig, v[1])
        self["_basalAttPanel" .. k]:setVisible(true)
        self["_basalAttNameLab" .. k]:setString(nameInfo.name)
        self["_basalAttNumLab" .. k]:setString("+" .. self.proxy:handleBasalAttNum(v))
        TextureManager:updateImageView(self["_basalAttImg" .. k], self.proxy:getBasalAttImgUrl(nameInfo.ID))
    end
    --洗炼属性
    for i=1,4 do
        self["_highAttPanel" .. i]:setVisible(false)
	end
    for k,v in pairs(self.treasureData.baseInfo) do
        local nameInfo = ConfigDataManager:getConfigById(ConfigData.TreasureEnchantConfig, v.typeid)
        self["_highAttPanel" .. k]:setVisible(true)
        self["_highAttTypeLab" .. k]:setString(nameInfo.name)
        self["_highAttlevelLab" .. k]:setString(v.level .. "级")
        if v.level == 10 then
            self["_highAttlevelLab" .. k]:setString("满级")
            else
            self["_highAttlevelLab" .. k]:setString(v.level .. "级")
        end
        TextureManager:updateImageView(self["_highAttImg" .. k], self.proxy:getHighAttImgUrl(nameInfo.ID))
    end

end
function HeroTreasurePanel:showHeroTreasureTrain(sender)
	self.proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.HeroTreaTrainModule, extraMsg = self.treasureData})
end
function HeroTreasurePanel:showHeroTreasureChange(sender)
    local tempData = {}
    tempData.postId = self.treasureData.postId
    tempData.post = self.treasureData.part
	self.proxy:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.HeroTreaPutModule, extraMsg = {putData = tempData}})
end

function HeroTreasurePanel:registerEvents()
	HeroTreasurePanel.super.registerEvents(self)
end
function HeroTreasurePanel:onClosePanelHandler()
    self.view:dispatchEvent(HeroEvent.HIDE_SELF_EVENT)
end