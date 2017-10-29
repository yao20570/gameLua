
UIDottedLine = class("UIDottedLine")

UIDottedLine.UpdateCD = 0.03

function UIDottedLine:ctor(nodePos1, nodePos2, parent, dottedNode, key)
    self._key = key
    self._refCount = 1
    -- 根节点
    self._rootNode = cc.Node:create()
    self._rootNode:setPosition(0, 0)
    self._rootNode:setLocalZOrder(9999)
    parent:addChild(self._rootNode)

    -- 线节点
    self._lineNode = cc.Node:create()
    self._lineNode:setPosition(0, 0)
    self._rootNode:addChild(self._lineNode)

    self:drawLine(nodePos1, nodePos2, self._lineNode, dottedNode)   
end

function UIDottedLine:finalize()
    if self._rootNode ~= nil then
        self._rootNode:removeFromParent()
        self._rootNode = nil
    end
end

function UIDottedLine:retain()
    self._refCount = self._refCount + 1
end

function UIDottedLine:release()
    self._refCount = self._refCount - 1    
end

function UIDottedLine:getRefCount()
    return self._refCount
end

function UIDottedLine:getKey()
    return self._key
end

function UIDottedLine:drawLine(nodePos1, nodePos2, lineNode, dottedNode, dirNode)

    local x1, y1 = nodePos1.x, nodePos1.y
    local x2, y2 = nodePos2.x, nodePos2.y

    local dir = cc.p(x2 - x1, y2 - y1)
    if dir.x == 0 and dir.y == 0 then
        return
    end

    local normalDir = cc.pNormalize(dir)


    local angle = math.deg(cc.pToAngleSelf(dir))

    -- images/map/roadLine.png的长度1600 ，高度18
    local imgW = 1600
    local imgH = 18

    -- 偏移的位置,也是一个点的长度
    local offset = 40

    -- 行军路线长度
    local lienLenght = cc.pGetLength(dir) - offset


    local size = math.ceil(lienLenght / imgW)
    for index = 1, size do
        local dlen = imgW *(index - 1)
        local dir2 = cc.pMul(normalDir, dlen)

        local srcPos = cc.p(x1 + dir2.x, y1 + dir2.y)

        local dotted = dottedNode:clone()

        if index == size then
            dotted:setAnchorPoint(0, 0)
            -- 求最后一段的长度并截掉不够-个点的部分
            local lastNodeWidth = lienLenght % imgW
            lastNodeWidth = lastNodeWidth - lastNodeWidth % 40

            local layout = ccui.Layout:create()
            layout:setContentSize(lastNodeWidth, imgH)
            layout:setClippingEnabled(true)
            layout:setAnchorPoint(0, 0.5)
            layout:setRotation(- angle)
            layout:setPosition(srcPos.x, srcPos.y)
            layout:addChild(dotted)
            lineNode:addChild(layout)
        else
            dotted:setAnchorPoint(0, 0.5)
            dotted:setPosition(srcPos.x, srcPos.y)
            dotted:setRotation(- angle)
            lineNode:addChild(dotted)
        end
    end

    local nextDir = cc.pMul(normalDir, offset)
    self:runLineAction(lineNode, cc.p(0, 0), nextDir)

end

function UIDottedLine:runLineAction(node, srcPos, nextDtPos)

    local function callback()
        local x, y = node:getPosition()
        node:setPosition(srcPos.x, srcPos.y)
        x = srcPos.x
        y = srcPos.y
    end

    local moveBy1 = cc.MoveTo:create(1, cc.p(nextDtPos.x, nextDtPos.y))
    local callFunc = cc.CallFunc:create(callback)
    local seq = cc.Sequence:create(moveBy1, callFunc)
    local repeatAction = cc.RepeatForever:create(seq)

    node:runAction(repeatAction)
end

