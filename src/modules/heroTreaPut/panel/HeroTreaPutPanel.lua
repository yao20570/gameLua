
HeroTreaPutPanel = class("HeroTreaPutPanel", BasicPanel)
HeroTreaPutPanel.NAME = "HeroTreaPutPanel"

function HeroTreaPutPanel:ctor(view, panelName)
    HeroTreaPutPanel.super.ctor(self, view, panelName,true)

end

function HeroTreaPutPanel:finalize()
    HeroTreaPutPanel.super.finalize(self)
end

function HeroTreaPutPanel:initPanel()
	HeroTreaPutPanel.super.initPanel(self)
	self._listView = self:getChildByName("ListView")
    self:setBgType(ModulePanelBgType.NONE)
    self.proxy = self:getProxy(GameProxys.HeroTreasure)
    --self:setTitle(true, self:getTextWord(3802))
    self:setTitle(true, "chuandai", true)
end

function HeroTreaPutPanel:doLayout()
	local topPanel = self:topAdaptivePanel()
	NodeUtils:adaptiveListView(self._listView, GlobalConfig.downHeight, topPanel)
end
function HeroTreaPutPanel:onShowHandler(data)
	self:updatePutView(data)
end
function HeroTreaPutPanel:updatePutView(data)
	local proxy = self:getProxy(GameProxys.HeroTreasure)
    local itemList = {}
    if data.post == 0 then
        itemList = proxy:getWTreasureInfosList()
    elseif data.post == 1 then
        itemList = proxy:getHTreasureInfosList()
    end
    local tipsPanel = self:getChildByName("tipsPanel")
    if #itemList == 0 then
        self:showSysMessage(self:getTextWord(3809))
        tipsPanel:setVisible(true)
    else
        tipsPanel:setVisible(false)
    end
    self:renderListView(self._listView, itemList, self, self.renderItemPanel, false) --只更新数据，不刷新
end
function HeroTreaPutPanel:renderItemPanel(item, itemInfo, index)
	local nameLab = item:getChildByName("nameLab")
	local belongNameLab = item:getChildByName("belongNameLab")
    local postImg = item:getChildByName("postImg")
    self.putOffBtn = item:getChildByName("putOffBtn")
    self.putOnBtn = item:getChildByName("putOnBtn")
    self:addTouchEventListener(self.putOffBtn, self.putOffBtnHandler)
    self:addTouchEventListener(self.putOnBtn, self.putOnBtnHandler)
    self.putOffBtn.treasuredId = itemInfo.id
    self.putOnBtn.treasuredId = itemInfo.id
	local iconbgImg = item:getChildByName("iconImg")
    local iconImg = iconbgImg:getChildByName("img")
    local basalAttPanel = item:getChildByName("basalAttPanel")
    local highAttItemPanel = item:getChildByName("highAttItemPanel")
    
    for i = 1, 3 do
        self["basalAttItem" .. i] = basalAttPanel:getChildByName("basalAttItem" .. i)
        self["basalAttItem" .. i .."nameLab"] = self["basalAttItem" .. i]:getChildByName("nameLab")
        self["basalAttItem" .. i .."numLab"] = self["basalAttItem" .. i]:getChildByName("numLab")
        self["basalAttItem" .. i .."attImg"] = self["basalAttItem" .. i]:getChildByName("attImg")
        self["basalAttItem" .. i .."img"] = self["basalAttItem" .. i .."attImg"]:getChildByName("img")
    end
    for i = 1, 4 do
        self["highAttItem" .. i] = highAttItemPanel:getChildByName("highAttItem" .. i)
        self["highAttItem" .. i .."nameLab"] = self["highAttItem" .. i]:getChildByName("nameLab")
        self["highAttItem" .. i .."numLab"] = self["highAttItem" .. i]:getChildByName("numLab")
    end
    



    local config = ConfigDataManager:getConfigById(ConfigData.TreasureBaseConfig, itemInfo.typeid)
    -- 名称
	nameLab:setString(config.name)
    local quality = config.color
    nameLab:setColor(ColorUtils:getColorByQuality(quality))
    local addInfo = self.proxy:getBasalAttInfoByTreasureDbID(itemInfo.id)

    --基础
    for i = 1, 3 do
        self["basalAttItem" .. i]:setVisible(false)
    end
    for k,v in pairs(addInfo) do
       local nameInfo = ConfigDataManager:getConfigById(ConfigData.ResourceConfig, v[1])
       local url = self.proxy:getBasalAttImgUrl(nameInfo.ID)
        TextureManager:updateImageView(self["basalAttItem" .. k .."img"], url)
        self["basalAttItem" .. k .."nameLab"]:setString(string.sub(nameInfo.name,1,6))
        self["basalAttItem" .. k .."numLab"]:setString("+" .. self.proxy:handleBasalAttNum(v))
        self["basalAttItem" .. k]:setVisible(true)
    end
     local data = {}
    data.power = GamePowerConfig.HeroTreasure 
    data.typeid = itemInfo.typeid
    data.parts = itemInfo
    data.equip = 1
    if iconbgImg._uiIcon == nil then
        local uiIcon = UIIcon.new(iconbgImg,data,false, self)
        uiIcon:setPosition(iconImg:getPositionX(), iconImg:getPositionY())
        iconbgImg._uiIcon = uiIcon
    else
        iconbgImg._uiIcon:updateData(data)
        -- iconbgImg._uiIcon:finalize()
        -- iconbgImg._uiIcon = nil
        -- local uiIcon = UIIcon.new(iconbgImg,data,false, self)
        -- uiIcon:setPosition(iconImg:getPositionX(), iconImg:getPositionY())
        -- iconbgImg._uiIcon = uiIcon
    end 
	--local  url = ComponentUtils:getTreasureIconImgUrl(itemInfo.typeid)
	--TextureManager:updateImageView(iconImg, url)

    --洗炼
    for i = 1, 4 do
        self["highAttItem" .. i]:setVisible(false)
    end
    for key, var in ipairs(itemInfo.baseInfo) do
        local nameInfo = ConfigDataManager:getConfigById(ConfigData.TreasureEnchantConfig, var.typeid)
        self["highAttItem" .. key .."nameLab"]:setString(nameInfo.name)
        self["highAttItem" .. key .."numLab"]:setString(var.level .. "级")
        self["highAttItem" .. key]:setVisible(true)
    end
    belongNameLab:setString("")
    ---local heroInfo = self.proxy.heroProxy:getInfoById(itemInfo.heroId)
    if itemInfo.postId ~= 0 then 
        --local config = ConfigDataManager:getConfigById(ConfigData.HeroConfig, heroInfo.heroId)
        belongNameLab:setString(itemInfo.postId .. "号位")
        self.putOffBtn:setVisible(true)
        self.putOnBtn:setVisible(false)
    else
        belongNameLab:setString("")
        self.putOffBtn:setVisible(false)
        self.putOnBtn:setVisible(true)
    end
    --几号位图
    local postUrl = itemInfo.postId == 0 and "images/newGui1/none.png" or string.format("images/component/hero_%d.png", itemInfo.postId)
    TextureManager:updateImageView(postImg, postUrl)
    --洗炼星星
     --0级以上的洗炼属性为黄星，0级的灰星
    local showYellowStarNum = 0
    local showGrayStarNum = 0
    local curBaseInfoNum = #itemInfo.baseInfo
    showGrayStarNum = curBaseInfoNum
    showGrayStarNum = showGrayStarNum == 3 and 4 or curBaseInfoNum
    for _,v in ipairs(itemInfo.baseInfo) do
        if v.level > 0 then
            showYellowStarNum = showYellowStarNum + 1
        end
    end
    local starPanel = item:getChildByName("starPanel")
    for i=1,4 do
        local starImg = starPanel:getChildByName("starImg" .. i)
        local starHuiImg = starPanel:getChildByName("starHuiImg" .. i)
        if i <= showYellowStarNum then
            starImg:setVisible(true)
        else
            starImg:setVisible(false)
        end
        if i <= showGrayStarNum then
            starHuiImg:setVisible(true)
        else
            starHuiImg:setVisible(false)
        end
    end


end

--穿戴
function HeroTreaPutPanel:putOnBtnHandler(sender)
    local heroIdAndPostData = self.view:getCurHeroIdAndPostDataData()
    local data = {}
    data.treasuredId = sender.treasuredId
    data.post = heroIdAndPostData.post
    data.postId = heroIdAndPostData.postId
    self.proxy:onTriggerNet350000Req(data)
end
--卸下
function HeroTreaPutPanel:putOffBtnHandler(sender)
    local heroIdAndPostData = self.view:getCurHeroIdAndPostDataData()
    local data = {}
    data.treasuredId = sender.treasuredId
    data.post = heroIdAndPostData.post
    data.postId = 0
    self.proxy:onTriggerNet350000Req(data)
end

function HeroTreaPutPanel:registerEvents()
	HeroTreaPutPanel.super.registerEvents(self)
end
function HeroTreaPutPanel:onClosePanelHandler()
    self.view:dispatchEvent(HeroTreaPutEvent.HIDE_SELF_EVENT)
end
function HeroTreaPutPanel:treasurePutHandler()
    self:onClosePanelHandler()
end

