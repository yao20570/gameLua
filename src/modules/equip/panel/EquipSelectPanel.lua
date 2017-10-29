EquipSelectPanel = class("EquipSelectPanel", BasicPanel)  --将军府武将查看
EquipSelectPanel.NAME = "EquipSelectPanel"

function EquipSelectPanel:ctor(view, panelName)
    EquipSelectPanel.super.ctor(self, view, panelName,true)
    self._currAttr = 12
    self._equipProxy = self:getProxy(GameProxys.Equip)
end

function EquipSelectPanel:finalize()
    EquipSelectPanel.super.finalize(self)
end

function EquipSelectPanel:initPanel()
    EquipSelectPanel.super.initPanel(self)
    self:setTitle(true,"equiphouse",true)
    self._listview = self:getChildByName("downPanel/itemsListView")
    self._upBtn = self:getChildByName("downPanel/upBtn")
    self._changeBtn = self:getChildByName("downPanel/changeBtn")
    local downPanel = self:getChildByName("downPanel")
    self:setNewbgImg({Widget = downPanel})
    self.equipBgImg = self:getChildByName("topPanel/equipBgImg")
    self.posX, self.posY = self.equipBgImg:getPosition()
    self.topLab = {}
    self.topLab[1] = self:getChildByName("topPanel/equipInfoLab")
    self.topLab[2] = self:getChildByName("topPanel/equipNameLab")
    self.topLab[3] = self:getChildByName("topPanel/shuxingLab")
    self.topLab[4] = self:getChildByName("topPanel/emptyEquipLab")
end

function EquipSelectPanel:onClosePanelHandler()
    --还原node状态
    for i=1, 4 do
        self.topLab[i]:stopAllActions()
        self.topLab[i]:setOpacity(255)
    end
    self.equipBgImg:stopAllActions()
    self.equipBgImg:setOpacity(255)
    self.equipBgImg:setPosition(self.posX, self.posY)

    EquipSelectPanel.super.onClosePanelHandler(self)
    self:hide()
end

function EquipSelectPanel:registerEvents()
    EquipSelectPanel.super.registerEvents(self)
    self:addTouchEventListener(self._upBtn, self.onExitEquip)
    self:addTouchEventListener(self._changeBtn, self.onCallItemTouch)
end

function EquipSelectPanel:onExitEquip()
    self.btnType = 1
    local data = {}
    if self._upBtn.data == nil then
        self:showSysMessage("没有可卸下的装备！")
    else
        data.id = self._upBtn.data.id
        self:dispatchEvent(EquipEvent.PUTOFF_EQUIP_REQ,data) 
    end
end

function EquipSelectPanel:onShowHandler()
    if self.oldSender then
        local url = "images/equip/equipNormal.png"
        TextureManager:updateImageView(self.oldSender, url)
        self.oldSender = nil
    end
end

--topEquipInfo 当前穿戴装备信息
--pos 几号位
function EquipSelectPanel:updateTopInfo(topEquipInfo,pos)
    self._currPos = pos or self._currPos
    if pos == nil then
        --self:setTopInfo(topEquipInfo)
        --panel内部事件导致 执行动作
        if self.equipWear then
            if topEquipInfo then
                self:runAction1(topEquipInfo)   --更换装备
            else
                self:runAction2(topEquipInfo)   --卸下装备
            end
        else
            if topEquipInfo then
                self:runAction3(topEquipInfo)   --穿上装备
            end
        end
    else
        --panel跳转todo 刷新顶部信息
        self:setTopInfo(topEquipInfo)
    end
end

function EquipSelectPanel:setTopInfo(data)
    self._upBtn.data = data
    if data then
        self:emptyOrEquip(true)
        local config = ConfigDataManager:getInfoFindByOneKey("WarriorsConfig","ID",data.typeid) 
        self:updateMovieChip(self.equipBgImg,config)
        self.topLab[1]:setString("第"..self._currPos.."号武将穿戴中")
        self.topLab[2]:setString(config.name)
        local config1 = ConfigDataManager:getInfoFindByTwoKey("WarriorProConfig","lv",data.level,"quality",data.quality)
        local value = config1[SoliderPowerDefine.equipAttribute[data.upproperty]] / 100
        value = self:getTextWord(720+data.upproperty)..":+"..value.."%"
        self.topLab[3]:setString(value)
        local equipImg = self.equipBgImg:getChildByName("equipImg")
        local url = "images/general/"..config.icon..".png"
        TextureManager:updateImageView(equipImg, url)
        local url = "images/gui/Frame_character"..data.quality.."_none.png"
        TextureManager:updateImageView(self.equipBgImg,url)
    else
        self:emptyOrEquip(false)
        self.topLab[4]:setString("第"..self._currPos.."号武将未穿戴")
    end 
end

function EquipSelectPanel:emptyOrEquip(bool)


    self.equipWear = bool
    for i = 1, 3 do
        self.topLab[i]:setVisible(bool)
    end
    self.equipBgImg:setVisible(bool)
    self.topLab[4]:setVisible(not bool)
end

function EquipSelectPanel:wearResp()
    if self.btnType == 2 then
        self:updateTopInfo(self._willWearData)
    elseif self.btnType == 1 then
        self:updateTopInfo(nil)
    end
    self:updateListData(self._currAttr,self._currPos)
end

function EquipSelectPanel:updateListData(attr,pos)
    self._currAttr = attr 
    self._currPos = pos 
    local data = self._equipProxy:getSoldierByAttr(attr,pos)
    local newData = self:getSoldierByAttr(data)
    self:renderListView(self._listview, newData, self, self.registerItemEvents)
end

function EquipSelectPanel:getSoldierByAttr(data)
    local dataTmp = {}
    for i = 1, #data do
        if not dataTmp[math.floor((i + 1)/2)] then
            dataTmp[math.floor((i + 1)/2)] = {}
            dataTmp[math.floor((i + 1)/2)][1] = data[i]
        else
            dataTmp[math.floor((i + 1)/2)][2] = data[i]
        end
    end
    return dataTmp
end

function EquipSelectPanel:registerItemEvents(item,data,index)
    local item1 = item:getChildByName("item1")
    local item2 = item:getChildByName("item2")
    item1.data = data[1]
    self:updateItemImg(item1)
    if #data == 1 then
        item2:setVisible(false)
    else
        item2.data = data[2]
        item2:setVisible(true)
        self:updateItemImg(item2)    
    end
end

function EquipSelectPanel:updateItemImg(node)
    local data = node.data
    local config = ConfigDataManager:getInfoFindByOneKey("WarriorsConfig","ID",data.typeid)
    local name = node:getChildByName("nameLvLab")
    name:setString(config.name.." Lv."..data.level)
    name:setColor(ColorUtils:getColorByQuality(data.quality))
    local equipImg = node:getChildByName("equipImg")
    self:updateMovieChip(equipImg,config)

    local person = equipImg:getChildByName("person")
    local url = "images/general/"..config.icon..".png"
    TextureManager:updateImageView(person, url)
    url =  "images/gui/Frame_character"..config.quality.."_none.png"
    TextureManager:updateImageView(equipImg, url)
    local valueLab = node:getChildByName("valueLab")
    config = ConfigDataManager:getInfoFindByTwoKey("WarriorProConfig","lv",data.level,"quality",data.quality)
    local value = config[SoliderPowerDefine.equipAttribute[data.upproperty]] / 100
    value = "+"..value.."%"
    valueLab:setString(value)
    
    local shuxingLab = node:getChildByName("shuxingLab")
    value = self:getTextWord(720+data.upproperty)
    shuxingLab:setString(value)

    local pos = node:getChildByName("describleLab")
    if data.position == 0 then
        pos:setString("空闲")
    else
        pos:setString(data.position..self:getTextWord(741))
    end
    self:addTouchEventListener(node,self.onNodeTouch)
end

function EquipSelectPanel:onNodeTouch(sender)
    local url = "images/equip/equipNormal.png"
    if self.oldSender then
        TextureManager:updateImageView(self.oldSender, url)
    end
    url = "images/equip/equipPress.png"
    TextureManager:updateImageView(sender, url)
    self.oldSender = sender
end

function EquipSelectPanel:onCallItemTouch(sender)
    self.btnType = 2
    if not self.oldSender then 
        self:showSysMessage("请选择你需要更换的装备！")
        return 
    end
    local sender = self.oldSender
    local data = {}
    data.id = sender.data.id
    data.position = self._currPos
    data.type = 1
    data.upproperty = sender.data.upproperty
    self._willWearData = sender.data
    self:dispatchEvent(EquipEvent.WEAR_EQUIP_REQ,data)
    --清空已选择
    local url = "images/equip/equipNormal.png"
    TextureManager:updateImageView(self.oldSender, url)
    self.oldSender = nil
end

function EquipSelectPanel:updateMovieChip(parent,config)
    if config.effectbigframe ~= nil then
        if parent.movieChip ~= nil then
            if parent.effectbigframe ~= config.effectbigframe then
                parent.movieChip:finalize()
                local movieChip = UIMovieClip.new(config.effectbigframe)
                movieChip:setParent(parent)
                movieChip:setNodeAnchorPoint(cc.p(0.06, 0.1))
                movieChip:setScale(1.0)
                parent.movieChip = movieChip
                parent.effectbigframe = config.effectbigframe
            end
                parent.movieChip:play(true)
        else
            local movieChip = UIMovieClip.new(config.effectbigframe)
            movieChip:setParent(parent)
            movieChip:setNodeAnchorPoint(0.06, 0.1)
            movieChip:play(true)
            movieChip:setScale(1.0)
            parent.movieChip = movieChip
            parent.effectbigframe = config.effectbigframe
        end
    else
        if parent.movieChip ~= nil then
            parent.movieChip:finalize()
            parent.movieChip = nil
            parent.effectbigframe = nil
        end 
    end
end


function EquipSelectPanel:runAction1(data)
    local function callBack()
        self:setTopInfo(data)
        self.equipBgImg:setPosition(self.posX, self.posY + GameConfig.EquipWear.Y)
    end
    self.equipBgImg:stopAllActions()
    self.equipBgImg:setPosition(self.posX,self.posY)
    self.equipBgImg:setOpacity(255)
    local action1 = cc.MoveBy:create(GameConfig.EquipWear.TIME, cc.p(0 - GameConfig.EquipWear.X, 0))
    local action2 = cc.FadeTo:create(GameConfig.EquipWear.TIME, 0)
    action1 = cc.Spawn:create(action1, action2)
    local action = cc.Sequence:create(action1,cc.CallFunc:create(callBack))
    local action1 = cc.FadeTo:create(GameConfig.EquipWear.TIME, 255)
    local action2 = cc.MoveTo:create(GameConfig.EquipWear.TIME, cc.p(self.posX,self.posY))
    action2 = cc.Spawn:create(action1,action2)
    local action = cc.Sequence:create(action,action2)
    self.equipBgImg:runAction(action)
    for i=1,3 do
        self:textAction1(self.topLab[i])
    end
end

function EquipSelectPanel:textAction1(node)
    node:stopAllActions()
    node:setOpacity(255)
    local action1 = cc.FadeTo:create(GameConfig.EquipWear.TIME,0)
    local action2 = cc.FadeTo:create(GameConfig.EquipWear.TIME,255)
    local actSeq = cc.Sequence:create(action1,action2)
    node:runAction(actSeq)
end

function EquipSelectPanel:runAction2(data)
    local function callBack()
        self:setTopInfo(data)
    end
    self.equipBgImg:stopAllActions()
    self.equipBgImg:setPosition(self.posX, self.posY)
    local action1 = cc.MoveBy:create(GameConfig.EquipWear.TIME, cc.p(0-GameConfig.EquipWear.X, 0))
    local action2 = cc.FadeTo:create(GameConfig.EquipWear.TIME, 0)
    action1 = cc.Spawn:create(action1, action2)
    local action = cc.Sequence:create(action1,cc.CallFunc:create(callBack))
    self.equipBgImg:runAction(action)
    for i=1,3 do
        self:textAction2(self.topLab[i])
    end
end

function EquipSelectPanel:textAction2(node)
    node:stopAllActions()
    node:setOpacity(255)
    local action1 = cc.FadeTo:create(GameConfig.EquipWear.TIME,0)
    node:runAction(action1)
end

function EquipSelectPanel:runAction3(data)
    self:setTopInfo(data)
    self.equipBgImg:stopAllActions()
    self.equipBgImg:setPosition(self.posX, self.posY + GameConfig.EquipWear.Y)
    local action1 = cc.FadeTo:create(GameConfig.EquipWear.TIME, 255)
    local action2 = cc.MoveTo:create(GameConfig.EquipWear.TIME, cc.p(self.posX,self.posY))
    action2 = cc.Spawn:create(action1,action2)
    self.equipBgImg:runAction(action2)
    for i=1,3 do
        self:textAction3(self.topLab[i])
    end
end

function EquipSelectPanel:textAction3(node)
    node:stopAllActions()
    node:setOpacity(0)
    local action1 = cc.FadeTo:create(GameConfig.EquipWear.TIME, 255)
    node:runAction(action1)
end
