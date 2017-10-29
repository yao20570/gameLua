--
-- Author: zlf
-- Date: 2016年9月2日14:42:37
-- 武将布阵界面

HeroTeamPanel = class("HeroTeamPanel", BasicPanel)
HeroTeamPanel.NAME = "HeroTeamPanel"

function HeroTeamPanel:ctor(view, panelName)
    HeroTeamPanel.super.ctor(self, view, panelName, 500)
    
    self:setUseNewPanelBg(true)
end

function HeroTeamPanel:finalize()
    HeroTeamPanel.super.finalize(self)
end

function HeroTeamPanel:initPanel()
	HeroTeamPanel.super.initPanel(self)
    self:setTitle(true, "武将布阵")
    self.proxy = self:getProxy(GameProxys.Hero)
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)

    self.allImg = {}
    self.allPos = {}
    for i=1,6 do
        self.allImg[i] = self:getChildByName("Panel_30/Panel_21/Img"..i)
        self.allPos[i] = cc.p(self.allImg[i]:getPosition())
        self.allImg[i].ID = i
    end
    -- self.imgSize = self.allImg[1]:getContentSize()
    self.imgSize = cc.size(86, 86)
    self.nodeParent = self.allImg[1]:getParent()
    self.posDesc = {"1号位", "2号位", "3号位", "4号位", "5号位", "6号位"}
    self.canMove = true
end

function HeroTeamPanel:registerEvents()
end

function HeroTeamPanel:onShowHandler(data)
    self:initPosView(data)
end

--武将换位，拖动头像。end或者cancel的时候判断有没有相交（不跟自身或者那些未解锁的槽位判断相交）
--有就请求协议，返回成功（交换位置）  失败就恢复原样
function HeroTeamPanel:initPosView(data)
    self.posData = data

    local function onTouchHandler(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:touchEndCall(sender)
        elseif eventType == ccui.TouchEventType.moved then
            local pos = sender:getTouchMovePosition() 
            self:touchMoveCall(sender, pos)
        elseif eventType == ccui.TouchEventType.began then
            local pos = sender:getTouchBeganPosition()
            self:touchBeganCall(sender, pos)
        elseif eventType == ccui.TouchEventType.canceled then
            self:touchEndCall(sender)
        end
    end

    for i=1,6 do
        self.allImg[i]:setPosition(self.allPos[i])
        local state = data[i]
        local iconImg = self.allImg[i]:getChildByName("iconImg")
        TextureManager:updateImageView(iconImg, "images/newGui2/SpBuDuiHeadBg.png")
        local infoImg = iconImg:getChildByName("infoImg")
        --infoImg 未解锁 显示锁  解锁上阵了不显示    解锁未上阵显示数字
        local heroData = self.proxy:getHeroInfoWithPos(i)
        -- infoImg:setVisible((not state) or (state and (heroData == nil)))
        local url = ""
        local text = state and self.posDesc[i] or "未解锁"
        local color = state and cc.c3b(255,255,255) or cc.c3b(255,255,255)
        self.allImg[i]:setTouchEnabled(state)

        if state then
            self.allImg[i]:addTouchEventListener(onTouchHandler)
            infoImg:setVisible(heroData == nil)
            -- TextureManager:updateImageView(infoImg, string.format("images/hero/%d.png", i))
            TextureManager:updateImageView(infoImg, string.format("images/newGui2/SpBuDuiNum%d.png", i))

            if heroData ~= nil then
                TextureManager:updateImageView(iconImg, "images/newGui1/none.png")
                local icon = iconImg.uiIcon
                local iconData = {}
                iconData.power = 409
                iconData.num = 1
                iconData.typeid = heroData.heroId
                if icon == nil then
                    icon = UIIcon.new(iconImg, iconData, false, self)
                    iconImg.uiIcon = icon
                else
                    icon:updateData(iconData)
                end
                icon:setVisible(true)
                icon:setTouchEnabled(false)
                -- icon:setScale(1.1)
            else
                local icon = iconImg.uiIcon
                if icon ~= nil then
                    icon:setVisible(false)
                end
            end
        else
            infoImg:setVisible(true)
            url = "images/newGui1/IconLock.png"
            TextureManager:updateImageView(infoImg, url)
            color = ColorUtils:color16ToC3b("#bf4949")
        end
        
        local descLab = self.allImg[i]:getChildByName("descLab")
        descLab:setString(text)
        descLab:setColor(color)
    end
end

function HeroTeamPanel:touchBeganCall(sender, pos)
    if not self.canMove then
        return
    end
    self.curID = sender.ID
    self.beganPos = pos
end

function HeroTeamPanel:touchEndCall(sender)
    if not self.canMove then
        return
    end
    self:check(cc.p(sender:getPosition()), sender)
end

function HeroTeamPanel:touchMoveCall(sender, pos)
    if not self.canMove then
        return
    end

    for key ,val in pairs(self.allImg) do
        if val == sender then
            val:setLocalZOrder(2)
        else
            val:setLocalZOrder(1)
        end
    end

    local Offsetx = pos.x - self.beganPos.x
    local Offsety = pos.y - self.beganPos.y
    local x = self.allPos[sender.ID].x + Offsetx
    local y = self.allPos[sender.ID].y + Offsety
    sender:setPosition(x, y)
end

function HeroTeamPanel:check(pos, sender)
    local maxHeight = self.imgSize.height
    local maxWidth = self.imgSize.width
    local targetPos = nil
    for i=1,6 do
        local itemPos = self.allPos[i]
        local distanceX = math.abs(pos.x - itemPos.x)
        local distanceY = math.abs(pos.y - itemPos.y)
        if distanceY < maxHeight and distanceX < maxWidth and i ~= sender.ID and self.posData[i] then
            targetPos = i
            break
        end
    end
    self.targetPosition = targetPos
    if targetPos ~= nil then
        
        local targetData = self.proxy:getHeroInfoWithPos(targetPos)
        local curData = self.proxy:getHeroInfoWithPos(sender.ID)
        if targetData == nil and curData == nil then
            sender:setPosition(self.allPos[sender.ID])
            self.canMove = true
            return
        end
        local sendData = {}
        sendData.heroPositionInfo = {}
        if targetData ~= nil then
            local posInfo = {}
            posInfo.heroId = targetData.heroDbId
            posInfo.position = sender.ID
            table.insert(sendData.heroPositionInfo, posInfo)
        end
        if curData ~= nil then
            local posInfo = {}
            posInfo.heroId = curData.heroDbId
            posInfo.position = targetPos
            table.insert(sendData.heroPositionInfo, posInfo)
        end
        self.proxy:onTriggerNet300005Req(sendData)
    else
        self.canMove = true
        sender:setPosition(self.allPos[sender.ID])
    end
end

function HeroTeamPanel:onPosChangeUpdate(data)
    if data == 0 then
        self:updatePosition(self.targetPosition, self.curID)
    else
        self.allImg[self.curID]:setPosition(self.allPos[self.curID])
    end
    self.canMove = true
end

function HeroTeamPanel:updatePosition(targetPos, id)
    self.allImg[targetPos]:setPosition(self.allPos[id])
    self.allImg[id]:setPosition(self.allPos[targetPos])
    self.allImg[targetPos], self.allImg[id] = self.allImg[id], self.allImg[targetPos]
    self.allImg[targetPos].ID, self.allImg[id].ID = targetPos, id
    -- local descLab1 = self.allImg[targetPos]:getChildByName("descLab")
    -- local descLab2 = self.allImg[id]:getChildByName("descLab")
    -- descLab1:setString(self.posDesc[targetPos].ID)
    -- descLab2:setString(self.posDesc[id].ID)
end