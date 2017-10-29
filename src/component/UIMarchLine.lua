-- 动画角度表
local AngleMap = {}
AngleMap[1] = {angleMix = -180, angleMax = -151, modelDir = cc.p(-1, 1), nameAtk = "rgb-gc-you",      nameMarch = "rgb-chubing-you", }
AngleMap[2] = {angleMix = -150, angleMax = -121, modelDir = cc.p(-1, 1), nameAtk = "rgb-gc-youxia",   nameMarch = "rgb-chubing-youxia", }
AngleMap[3] = {angleMix = -120, angleMax = -61,  modelDir = cc.p(1, 1),  nameAtk = "rgb-gc-xia",      nameMarch = "rgb-chubing-xia", }
AngleMap[4] = {angleMix = -60,  angleMax = -31,  modelDir = cc.p(1, 1),  nameAtk = "rgb-gc-youxia",   nameMarch = "rgb-chubing-youxia", }
AngleMap[5] = {angleMix = -30,  angleMax = 30,   modelDir = cc.p(1, 1),  nameAtk = "rgb-gc-you",      nameMarch = "rgb-chubing-you", }
AngleMap[6] = {angleMix = 31,   angleMax = 60,   modelDir = cc.p(1, 1),  nameAtk = "rgb-gc-youshang", nameMarch = "rgb-chubing-youshang", }
AngleMap[7] = {angleMix = 61,   angleMax = 120,  modelDir = cc.p(1, 1),  nameAtk = "rgb-gc-shang",    nameMarch = "rgb-chubing-shang", }
AngleMap[8] = {angleMix = 121,  angleMax = 160,  modelDir = cc.p(-1, 1), nameAtk = "rgb-gc-youshang", nameMarch = "rgb-chubing-youshang", }
AngleMap[9] = {angleMix = 161,  angleMax = 180,  modelDir = cc.p(-1, 1), nameAtk = "rgb-gc-you",      nameMarch = "rgb-chubing-you", }
function AngleMap:getCCBDataByAngle(angle)
    for k, v in pairs(self) do
        if type(v) ~= "function" then
            if v.angleMix <= math.floor(angle) and math.floor(angle) <= v.angleMax then
                return v
            end
        end
    end

    return nil
end

local CCB_Atk_Time = 2 -- 攻击动画播放时间(配置攻击动画的时长)
local FixLenght = 100 -- 不能大于两个格子的距离

-- 目标参数表(key对应协议的TaskTeamShortInfo.targetType)
--local TargetParamsMap = { }
--TargetParamsMap[1] = { fixLenght = 100 }    -- 玩家
--TargetParamsMap[2] = { fixLenght = 100 }    -- 矿点
--TargetParamsMap[3] = { fixLenght = 100 }    -- 空地或容错
--TargetParamsMap[4] = { fixLenght = 100 }    -- 叛军
--TargetParamsMap[5] = { fixLenght = 100 }    -- 郡城PVP
--TargetParamsMap[6] = { fixLenght = 100 }    -- 郡城PVE
--TargetParamsMap[7] = { fixLenght = 100 }    -- 皇城PVP
--TargetParamsMap[8] = { fixLenght = 100 }    -- 皇城PVE


-- 行军路线类
UIMarchLine = class("UIMarchLine", function()
    local node = cc.Node:create()
    node.oldSetVisible = node.setVisible
    return node
end )


-- images/map/roadLine.png的长度1600 ，高度18
local Const_ImgW = 1980
local Const_ImgH = 18

-- 偏移的位置,也是一个点的长度
local Const_Offset = 22

-- 行军路线类型
local Road_Type_Self = 1
local Road_Type_Legion = 2
local Road_Type_Other = 3

-- 行军路线图片路径
local Const_imgRoadLineUrl = { }
Const_imgRoadLineUrl[Road_Type_Self] = "images/map/roadLine1.png"  --[[ 橙色 ]]
Const_imgRoadLineUrl[Road_Type_Legion] = "images/map/roadLine2.png"  --[[ 黄色 ]]
Const_imgRoadLineUrl[Road_Type_Other] = "images/map/roadLine3.png"  --[[ 红色 ]]


function UIMarchLine:ctor(worldMap, mapPanel, scene)
    self._worldMap = worldMap
    self._mapPanel = mapPanel

    local marchLineLayer = scene:getLayer(WorldMapFloor.Layer_Type_March_Line)
    marchLineLayer:addChild(self)

    self._marchActorLayer = scene:getLayer(WorldMapFloor.Layer_Type_March_Actor)
    self._nodesNameLayer = scene:getLayer(WorldMapFloor.Layer_Type_Nodes_Name)

    -- 线节点
    self._lineNode = cc.Node:create()
    self._lineNode:setPosition(0, 0)
    self:addChild(self._lineNode)

    -- 最后一根可变的line
    self._lastLine = nil

    -- 中间连接的line
    self._nomarlLineMap = { }

    -- 屏幕范围    
    self._screenRect = {}
    
    self._isShowChildren = false

    self._posActor = {}

end

-- 重写setVisible，显示并启用scheduleUpdate,或隐藏并unscheduleUpdate
function UIMarchLine:setVisible(isVisible)

    if self:isVisible() == isVisible then
        return
    end
    
    self:oldSetVisible(isVisible)

    self:setChildrenVisible(isVisible)

    if isVisible == true then
        -- 启用update(dt)
        self:scheduleUpdate()
    else
        -- 暂停更新update(dt)
        self:unscheduleUpdate()
    end
end

--显示并启用用子节点动作，或隐藏并暂停子节点动作
function UIMarchLine:setChildrenVisible(isShow)

    if self._isShowChildren == isShow then
        return
    end

    self._isShowChildren = isShow

    self._lineNode:setVisible(isShow)

    if isShow == true then
        self._lineNode:resume()
    else
        self._lineNode:pause()
    end

    if self._ccbAtk ~= nil then
        self._ccbAtk:setVisible(isShow)
    end

    if self._ccbMarch ~= nil then
        self._ccbMarch:setVisible(isShow)
    end

    if self._nameNode ~= nil then
        self._nameNode:setVisible(isShow)
    end   
end

function UIMarchLine:scheduleUpdate()
    self:unscheduleUpdate()

    local function handler(dt)
        self:update(dt)
    end
    self:scheduleUpdateWithPriorityLua(handler, 0)
end

function UIMarchLine:finalize()
    self._marchData = nil

    -- 停止定时器
    self:unscheduleUpdate()

    -- 移除行军动画
    if self._ccbMarch ~= nil then
        self._ccbMarch:finalize()
        self._ccbMarch = nil
    end

    -- 移除攻击动画
    if self._ccbAtk ~= nil then
        self._ccbAtk:finalize()
        self._ccbAtk = nil
    end

    -- 从父节点移除
    self:removeFromParent()
end

function UIMarchLine:getMarchData()
    return self._marchData
end

function UIMarchLine:updateUI(marchData)
    self._marchData = marchData
    self:setVisible(true)

    -- 开始位置
    self._pos1 = MapDef.worldTileToScreen(marchData.startX, marchData.startY)

    -- 结束位置
    self._pos2 = MapDef.worldTileToScreen(marchData.endX, marchData.endY)

    -- 方向
    self._dir = cc.p(self._pos1.x - self._pos2.x, self._pos1.y - self._pos2.y)
    
    -- 路线总长度
    self._lineTotalLenght = cc.pGetLength(self._dir) - Const_Offset

    -- line的角度
    self._angle = math.deg(cc.pToAngleSelf(self._dir))
    self._normalDir = cc.pNormalize(self._dir)
    
    -- ccb的角度
    self._dirAngle = cc.p(self._pos2.x - self._pos1.x, self._pos2.y - self._pos1.y)
    self._angleActor = math.deg(cc.pToAngleSelf(self._dirAngle))

    -- lineNode的Action偏移量
    self._actionDir = cc.pMul(self._normalDir, Const_Offset)

    -- 路线的图片
    self._imgRoadLineUrl = self:getRoadType()

    -- 清空攻击动画
    self._isCreateAtkCCB = false
    if self._ccbAtk ~= nil then
        self._ccbAtk:finalize()
        self._ccbAtk = nil
    end
        
    -- 要在距离目标点(TargetParamsMap.fixLenght)播放攻击动画(4秒)，在距离目标点(TargetParamsMap.fixLenght)返回，所以修正数据
    self:fixData()

    -- 开启update
    self:scheduleUpdate()

    self:update(0)
end

function UIMarchLine:fixData()
    marchData = self._marchData

    
    self._fixTime = 0
    self._fixLenght = 0
    self._fixMarchTime = marchData.totalTime
    self._isShowAtkCCB = false

    if marchData.targetType == 5 or marchData.targetType == 6 then
        -- 打郡城不播放

    elseif marchData.type == SoldierProxy.March_Atk then
        -- 进攻修正
        local fixDir = cc.pMul(self._normalDir, FixLenght)
        rawset(marchData, "retPos1", cc.p(self._pos2.x + fixDir.x, self._pos2.y + fixDir.y))

        self._posAtk = self._pos2 -- cc.p(self._pos2.x + fixDir.x, self._pos2.y + fixDir.y)
        self._fixTime = CCB_Atk_Time
        self._fixLenght = FixLenght --TargetParamsMap[marchData.targetType].fixLenght
        self._fixMarchTime = marchData.totalTime - self._fixTime
        self._isShowAtkCCB = true

    elseif marchData.type == SoldierProxy.March_Ret then
        -- 返回修正
        local goData = rawget(marchData, "goData")
        if goData ~= nil then
            self._pos1 = rawget(goData, "retPos1")
            self._dir = cc.p(self._pos1.x - self._pos2.x, self._pos1.y - self._pos2.y)
            self._lineTotalLenght = cc.pGetLength(self._dir) - Const_Offset
            self._isShowAtkCCB = true
        end

    end

end

function UIMarchLine:drawActorMarch()

    local ccbData = AngleMap:getCCBDataByAngle(self._angleActor)
    if ccbData == nil then
        logger:error("UIMarchLine:drawActorMarch() ccbData:nil, self._angleActor:%s", self._angleActor)
        return
    end        

    -- logger:info("@@@@@@@@@@@@@@@@@@@@@@@@@@@@ self._angleActor = " , self._angleActor)
    -- if ccbData.angleMax == 160 then
    --     logger:info("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    -- end

    -- 有角色但名称不一样
    if self._ccbMarch ~= nil and self._ccbMarch:getName() ~= ccbData.nameMarch then
        self._ccbMarch:finalize()
        self._ccbMarch = nil
    end

    -- 创建行军军队
    if self._ccbMarch == nil then
        self._ccbMarch = self._mapPanel:createUICCBLayer(ccbData.nameMarch, self._marchActorLayer)
        self._ccbMarch:setLocalZOrder(100000001)
    end

    -- 设置
    self._ccbMarch:setDirection(ccbData.modelDir)


    if self._nameNode == nil then
        self._nameNode = TextureManager:createSprite("images/map/Bg_resLvBg.png")
        self._nameNode:setAnchorPoint(0, 0.5)
        -- self._nameNode:setContentSize(cc.size(88, 18))
        self._nodesNameLayer:addChild(self._nameNode)
    end


    if self._clockImg == nil then
        self._clockImg = TextureManager:createSprite("images/map/Bg_horse.png")
        self._clockImg:setAnchorPoint(0, 0.5)
        self._clockImg:setPosition(-4, 12)
        self._nameNode:addChild(self._clockImg)
    end

    if self._timeTxt == nil then
        self._timeTxt = ccui.Text:create()
        self._timeTxt:setAnchorPoint(0, 0.5)
        self._timeTxt:setFontName(GlobalConfig.fontName)
        self._timeTxt:setFontSize(14)
        self._timeTxt:setColor(ColorUtils.wordGreenColor)
        self._timeTxt:setString("00:00")
        local clockSize = self._clockImg:getContentSize()
        self._timeTxt:setPosition(clockSize.width, 14)
        self._nameNode:addChild(self._timeTxt)
    end
end




function UIMarchLine:drawActorAtk()

    local ccbData = AngleMap:getCCBDataByAngle(self._angleActor)
    if ccbData == nil then
        logger:error("UIMarchLine:drawActorAtk() ccbData:nil, self._angleActor:%s", self._angleActor)
        return
    end

    -- 创建行军军队
    if self._ccbAtk == nil then
        self._ccbAtk = self._mapPanel:createUICCBLayer(ccbData.nameAtk, self._marchActorLayer, nil, function()
             self._ccbAtk:finalize()
             self._ccbAtk = nil
        end , true)
        self._ccbAtk:setLocalZOrder(100000001)
        self._ccbAtk:setDirection(ccbData.modelDir)
        self._isCreateAtkCCB = true
    end
end


function UIMarchLine:getRoadType()
    local roleProxy = self._mapPanel:getProxy(GameProxys.Role)

    if self._marchData.playerId == roleProxy:getPlayerId() then
        return Const_imgRoadLineUrl[Road_Type_Self]

    elseif StringUtils:isFixed64Zero(roleProxy:getLegionId()) == false and self._marchData.legionId == roleProxy:getLegionId() then
        return Const_imgRoadLineUrl[Road_Type_Legion]

    end

    return Const_imgRoadLineUrl[Road_Type_Other]
end


function UIMarchLine:isLineCrossRectangle(pos1, pos2, r)
    local LeftTopX = r.x
    local LeftTopY = r.y + r.height
    local RightBottomX = r.x + r.width
    local RightBottomY = r.y

    local lineHeight = pos1.y - pos2.y
    local lineWidth = pos2.x - pos1.x
    -- 计算叉乘
    local c = pos1.x * pos2.y - pos2.x * pos1.y

    if ((lineHeight * LeftTopX + lineWidth * LeftTopY + c >= 0 and lineHeight * RightBottomX + lineWidth * RightBottomY + c <= 0)
        or(lineHeight * LeftTopX + lineWidth * LeftTopY + c <= 0 and lineHeight * RightBottomX + lineWidth * RightBottomY + c >= 0)
        or(lineHeight * LeftTopX + lineWidth * RightBottomY + c >= 0 and lineHeight * RightBottomX + lineWidth * LeftTopY + c <= 0)
        or(lineHeight * LeftTopX + lineWidth * RightBottomY + c <= 0 and lineHeight * RightBottomX + lineWidth * LeftTopY + c >= 0)) then


        if (LeftTopX > RightBottomX) then
            local temp = LeftTopX
            LeftTopX = RightBottomX
            RightBottomX = temp
        end

        if (LeftTopY < RightBottomY) then
            local temp1 = LeftTopY
            LeftTopY = RightBottomY
            RightBottomY = temp1
        end

        if ((pos1.x < LeftTopX and pos2.x < LeftTopX)
            or(pos1.x > RightBottomX and pos2.x > RightBottomX)
            or(pos1.y > LeftTopY and pos2.y > LeftTopY)
            or(pos1.y < RightBottomY and pos2.y < RightBottomY)) then
            return false
        else
            return true
        end
    end

    return false
end

-- 屏幕在地图的范围
function UIMarchLine:setScreenRect()
    local x, y  = MapDef.worldTileToScreenXY(self._worldMap.currTileX, self._worldMap.currTileY)
    self._screenRect.x = x - 320
    self._screenRect.y = y - 480
    self._screenRect.width = 640
    self._screenRect.height = 960
end

-- 行军路线是否穿过屏幕
function UIMarchLine:isMarchLineCrossScreen()    
    return self:isLineCrossRectangle(self._posActor, self._pos2, self._screenRect) 
end

-- 军队是否在屏幕内
function UIMarchLine:isActorInScene()    
    return self._screenRect.x < self._posActor.x 
        and self._posActor.x < self._screenRect.x + self._screenRect.width 
        and self._screenRect.y < self._posActor.y 
        and self._posActor.y < self._screenRect.y + self._screenRect.height
end

function UIMarchLine:update(dt)

    -- 设置屏幕范围
    self:setScreenRect()

    local marchData = self._marchData
    if marchData.alreadyTime == marchData.totalTime then
        self:setVisible(false)

    else
        -- 更新时间
        marchData.alreadyTime = math.min(marchData.alreadyTime + dt, marchData.totalTime)

        -- 行军路线长度(在修正的时间内走完修正后的路程)
        local per = 1 - marchData.alreadyTime / self._fixMarchTime
        self._lineLenght = math.max(0, per) * (self._lineTotalLenght - self._fixLenght) + self._fixLenght

        local xLen = self._normalDir.x * self._lineLenght
        local yLen = self._normalDir.y * self._lineLenght
        self._posActor.x = self._pos2.x + xLen
        self._posActor.y = self._pos2.y + yLen

        -- 是否播放攻击动画
        -- 因为攻击和返回不是同一个UIMarchLine
        local isShowAtkCCB = false
        if marchData.type == SoldierProxy.March_Atk or
            marchData.type == SoldierProxy.March_Go_Help then
            if self._lineLenght <= self._fixLenght then
                isShowAtkCCB = true and self._isShowAtkCCB
            end            
        elseif marchData.type == SoldierProxy.March_Ret then
            if self._lineLenght >= self._lineTotalLenght - self._fixLenght then
                isShowAtkCCB = true and self._isShowAtkCCB
            end
        end



        -- 行军路线是否穿过屏幕
        if self:isMarchLineCrossScreen() == true then
            self:setChildrenVisible(true)

            self:updateLine(isShowAtkCCB)

            self:updateLineMove(isShowAtkCCB)

            self:updateActor(isShowAtkCCB)
        else
            self:setChildrenVisible(false)
        end
    end
end

function UIMarchLine:updateLine(isShowAtkCCB)

    if isShowAtkCCB == true then
        self._lineNode:setVisible(false)
    else
        self._lineNode:setVisible(true)

        local marchData = self._marchData

        local x1, y1 = self._pos1.x, self._pos1.y
        local x2, y2 = self._pos2.x, self._pos2.y

        local dir = self._dir
        if dir.x == 0 and dir.y == 0 then
            return
        end

        local size = math.ceil(self._lineLenght / Const_ImgW)

        local normalDirX = self._normalDir.x
        local normalDirY = self._normalDir.y
        local dir2X = 0
        local dir2Y = 0
        local srcPosX = 0
        local srcPosY = 0

        -- 显示line
        for index = 1, size do
            local dlen = Const_ImgW *(index - 1)
            dir2X = normalDirX * dlen
            dir2Y = normalDirY * dlen
            srcPosX = x2 + dir2X
            srcPosY = y2 + dir2Y
            -- local dir2 = cc.pMul(self._normalDir, dlen)

            -- local srcPos = cc.p(x2 + dir2.x, y2 + dir2.y)

            if index == size then
                local lastLine = self._lastLine
                if lastLine == nil then
                    lastLine = TextureManager:createSprite(self._imgRoadLineUrl)
                    lastLine:setAnchorPoint(0, 0.5)
                    self._lineNode:addChild(lastLine)
                    self._lastLine = lastLine
                else
                    TextureManager:updateSprite(lastLine, self._imgRoadLineUrl)
                end

                -- local tempLineLenght = self._lineLenght - cc.pGetLength(self._actionDir)
                local x = lastLine:getTextureRect()
                x.width = self._lineLenght % Const_ImgW
                x.width = x.width -(x.width + cc.pGetLength(self._actionDir)) % Const_Offset
                lastLine:setTextureRect(x)

                lastLine:setVisible(true)
                lastLine:setRotation(- self._angle)
                lastLine:setPosition(srcPosX, srcPosY)

            else
                local nomarlLine = self._nomarlLineMap[index]
                if nomarlLine == nil then
                    nomarlLine = TextureManager:createSprite(self._imgRoadLineUrl)
                    nomarlLine:setAnchorPoint(0, 0.5)
                    self._lineNode:addChild(nomarlLine)
                    self._nomarlLineMap[index] = nomarlLine
                else
                    TextureManager:updateSprite(nomarlLine, self._imgRoadLineUrl)
                end

                nomarlLine:setVisible(true)
                nomarlLine:setRotation(- self._angle)
                nomarlLine:setPosition(srcPosX, srcPosY)

            end

        end

        -- 隐藏多余的line
        for k, v in pairs(self._nomarlLineMap) do
            if k >= size then
                v:setVisible(false)
            end
        end

    end
end

function UIMarchLine:updateActor(isShowAtkCCB)

    if self:isActorInScene() == true then
        -- 创建军队(只有在屏幕才创建行军军队)

        if self._ccbAtk then
            self._ccbAtk:setVisible(isShowAtkCCB == true)
        end

        if self._ccbMarch then
            self._ccbMarch:setVisible(isShowAtkCCB == false)
        end

        if self._nameNode then
            self._nameNode:setVisible(isShowAtkCCB == false)
        end

        if isShowAtkCCB == true and self._isCreateAtkCCB ~= true then
            self:drawActorAtk()

            self._ccbAtk:setPosition(self._posAtk.x, self._posAtk.y)

        else
            self:drawActorMarch()

            local srcPos = self._posActor
            self._ccbMarch:setPosition(srcPos.x, srcPos.y)
            self._nameNode:setPosition(srcPos.x - 40, srcPos.y + 60)

            local tempTime = math.ceil(self._marchData.totalTime - self._marchData.alreadyTime)
            if self._remainingTime ~= tempTime then
                self._remainingTime = tempTime
                local timeStr = TimeUtils:getStandardFormatTimeString4(tempTime)
                self._timeTxt:setString(timeStr)
            end
        end

    else
        if self._ccbAtk then
            self._ccbAtk:setVisible(false)
        end

        if self._ccbMarch then
            self._ccbMarch:setVisible(false)
        end

        if self._nameNode then
            self._nameNode:setVisible(false)
        end
    end
end

function UIMarchLine:updateLineMove(isShowAtkCCB)

    if isShowAtkCCB then

    else
        local normalDirX = self._normalDir.x * Const_Offset
        local normalDirY = self._normalDir.y * Const_Offset

        local x, y = self._lineNode:getPosition()
        -- local y = self._lineNode:getPositionY()
        if math.abs(x) > math.abs(normalDirX) or math.abs(y) > math.abs(normalDirY) then
            self._lineNode:setPosition(0, 0)
        else
            -- 一秒40帧
            self._lineNode:setPosition(x - normalDirX / 40, y - normalDirY / 40)
        end
    end
end


--function UIMarchLine:runLineAction(node, srcPos, nextDtPos)

--    local function callback()
--        node:setPosition(srcPos.x, srcPos.y)
--    end

--    local moveBy1 = cc.MoveTo:create(1, cc.p(nextDtPos.x, nextDtPos.y))
--    local callFunc = cc.CallFunc:create(callback)
--    local seq = cc.Sequence:create(moveBy1, callFunc)
--    local repeatAction = cc.RepeatForever:create(seq)

--    callback()
--    node:stopAllActions()
--    node:runAction(repeatAction)
--end

