UIRichLabel = class("UIRichLabel", function ()
    return UIMapNodeExtend.extend(cc.Node:create())
end)

function UIRichLabel:ctor()
    local labelNode = cc.Node:create()
    labelNode:setAnchorPoint(0, 1)
    
    local function getContentSize()
        return cc.size(labelNode.width, labelNode.height)
    end
    
    labelNode.setString = function (labelNode, lines)
        setString(lines)
    end
    
    labelNode.getContentSize = function (labelNode)
        return getContentSize()
    end
end

local function setString(lines)
    labelNode:removeAllChildren()
    if type(lines) ~= type({}) then
        return
    end
    local y = 0
    local maxWidth = 0
    local maxHeight = 0
    for _, line in pairs(lines) do
        local x = 0
        local maxH = 0
        local maxW = 0
        for _, value in pairs(line) do
            local label = ccui.Text:create()
            label:setFontName(GlobalConfig.fontName)
            label:setAnchorPoint(cc.p(0, 1))
            label:setFontSize(value.foneSize)
            local content = string.gsub(value.content, "<br/>",  "\n")
            if string.find(content, "&#37;" ) ~= nil then
                print("")
            end
            content = string.gsub(content, "&#37;",  "%%")
            label:setString(content)
            local color3b = ColorUtils:color16ToC3b(value.color)
            label:setColor(color3b)
            label:setPosition(x, y)
            labelNode:addChild(label)

            local size = label:getContentSize()
            x = x + size.width 
            if maxH < size.height then
                maxH = size.height
            end
            maxW = maxW + size.width 
        end
        y = y - maxH
        if maxWidth < maxW then
            maxWidth = maxW
        end
        maxHeight = maxHeight + maxH
    end

    labelNode.width = maxWidth
    labelNode.height = maxHeight

end