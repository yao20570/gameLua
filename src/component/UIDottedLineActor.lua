
UIDottedLineActor = class("UIDottedLineActor")

UIDottedLineActor.UpdateCD = 0.03

function UIDottedLineActor:ctor(nodePos1, nodePos2, targetNode, dirNode, lineKey)
    self._lineKey = lineKey
    -- 目标节点
    self._targetNode = targetNode

    self._dirNode = dirNode


    self:drawLine(nodePos1, nodePos2, targetNode, dirNode)
    if dirNode ~= nil then
        self.infoNode = dirNode.infoNode
    end
    if self.infoNode ~= nil then
        self.timeTxt = self.infoNode:getChildByName("timeTxt")
    end

    local function update(dt)
        self:update(dt)
    end
    self._idSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, UIDottedLineActor.UpdateCD, false)
end

function UIDottedLineActor:finalize()

    if self._targetNode ~= nil then
        if self._targetNode.ccb ~= nil then
            self._targetNode.ccb:finalize()
            self._targetNode.ccb = nil
        end

        self._targetNode:removeFromParent()
        self._targetNode = nil
    end

    if self._dirNode ~= nil then
        self._dirNode:finalize()
        self._dirNode = nil
    end

    if self.infoNode ~= nil then
        self.infoNode:removeFromParent()
        self.infoNode = nil
    end

    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._idSchedule)
end

function UIDottedLineActor:getLineKey()
    return self._lineKey
end

-- dirNode的移动参数
function UIDottedLineActor:setMoveData(data)
    if self._dirNode == nil then
        return
    end

    self._moveData = data
    local totalTime = self._moveData.totalTime
    local alreadyTime = self._moveData.alreadyTime

    self._localStartTime = os.time()

    self._alreadyTime = alreadyTime
    self._totalTime = totalTime
    self._time = totalTime - alreadyTime
    if self.timeTxt ~= nil then
        local timeStr = TimeUtils:getStandardFormatTimeString4(self._totalTime)
        self.timeTxt:setString(timeStr)
    end

    self._speedDir = cc.pMul(self._distance, 1 / totalTime)

    self:update()
end

function UIDottedLineActor:getTargetPosition()
    return self._endX, self._endY
end

function UIDottedLineActor:getTargetNode()
    return self._targetNode
end

function UIDottedLineActor:drawLine(nodePos1, nodePos2, targetNode, dirNode)
    local dottedGroup = { }

    local x1, y1 = nodePos1.x, nodePos1.y
    local x2, y2 = nodePos2.x, nodePos2.y

    self._endX = x2
    self._endY = y2


    local dir = cc.p(x2 - x1, y2 - y1)
    if dir.x == 0 and dir.y == 0 then
        targetNode:setPosition(x1, y1)
        return
    end

    self._startPos = nodePos1
    self._distance = dir

    targetNode:setPosition(x2, y2)


    if dirNode ~= nil then
        dirNode:setPosition(x1, y1)
        if self.infoNode ~= nil then
            self.infoNode:setPosition(x1, y1)
        end
    end    
end


function UIDottedLineActor:update(dt)
    if dt ~= nil and self._alreadyTime ~= nil and self._dirNode ~= nil then
        
        self._curAlreadyTime = (self._curAlreadyTime or 0) + dt

        local checkTime = os.time() - self._localStartTime
        if checkTime - self._curAlreadyTime > 1 then
            self._curAlreadyTime = checkTime
        end

        local alreadyTime = self._alreadyTime + self._curAlreadyTime

        self._time = self._totalTime - alreadyTime

        if self._time < 0 then
            self._time = 0
        end

        local s = cc.pMul(self._speedDir, alreadyTime)
        local curPosX = self._startPos.x + s.x
        local curPosY = self._startPos.y + s.y        
        self._dirNode:setPosition(self._startPos.x + s.x, self._startPos.y + s.y)

       

        if self.timeTxt ~= nil then
            local timeStr = TimeUtils:getStandardFormatTimeString4( math.ceil(self._time) )
            self.timeTxt:setString(timeStr)
        end

        if self.infoNode ~= nil then
            local offsetPos = self.infoNode.timePos
            self.infoNode:setPosition(self._startPos.x + s.x + offsetPos.x, self._startPos.y + s.y + 30 + offsetPos.y)
        end

    end
end
