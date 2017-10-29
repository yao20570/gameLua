-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

UIChatScrollviewExpand = UIChatScrollviewExpand or { }
UIChatScrollviewExpand.AddToFront = 1
UIChatScrollviewExpand.AddToBack = 2
function UIChatScrollviewExpand:expand(scrollView, itemUI)
    
    if scrollView._isExpand == true then
        return
    end
    scrollView._isExpand = true


    -- 当前使用的子项表
    scrollView._curItemUIMap = { }

    -- 移除的子项表
    scrollView._delItemUIMap = { }


    -- 子项，TODO：因为动态语言，随意在ItemUI上加属性，所以只能抽出来作为拷贝的存在
    scrollView._cloneUI = itemUI
    scrollView._cloneUI:setVisible(false)
    scrollView._itemUISize = itemUI:getContentSize()

    -- 最大子项数量
    scrollView._maxItemUICount = 50
    scrollView._curItemUICount = 0

    -- innerHeight
    local innerSize = scrollView:getInnerContainerSize()
    scrollView._innerHeight = innerSize.height

    -- 间距
    scrollView._spacing = 6

    -- 设置最大ItemUI数量
    function scrollView:setMaxItemUICount(count)
        scrollView._maxItemUICount = count or scrollView._maxItemUICount
    end

    -- 设置间距
    function scrollView:setSpacing(spacing)
        scrollView._spacing = spacing or scrollView._spacing
    end


    -- 添加ItemUI
    -- chatData     数据
    -- addType      UIChatScrollviewExpand.AddToFront,UIChatScrollviewExpand.AddToBack
    -- sender       回调函数的sender
    -- updateFun    回调函数
    -- isDoLayout   nil,false:不设置ItemUI位置    true:设置ItemUI位置
    function scrollView:addItemUI(chatData, addType, sender, updateFun, isDoLayout)
        
        if scrollView._curItemUICount >= scrollView._maxItemUICount then
            scrollView:delItemUI()
        end

        local delCount = #scrollView._delItemUIMap
        local itemUI = scrollView._delItemUIMap[delCount]
        if itemUI == nil then
            itemUI = scrollView._cloneUI:clone()
            scrollView:addChild(itemUI)
        else
            table.remove(scrollView._delItemUIMap, delCount)
        end

        if addType == UIChatScrollviewExpand.AddToFront then
            table.insert(scrollView._curItemUIMap, 1, itemUI)
        else
            table.insert(scrollView._curItemUIMap, itemUI)
        end
        scrollView._curItemUICount = scrollView._curItemUICount + 1

        itemUI:setVisible(true)

        -- 更新ItemUI后，获取ItemUI的高
        itemUI.autoHeight = updateFun(sender, itemUI, chatData)
        
        if isDoLayout == true then
            scrollView:resetPos()
        end
        
    end

    -- 移除ItemUI
    function scrollView:delItemUI(isDoLayout)
        local itemUI = scrollView._curItemUIMap[#scrollView._curItemUIMap]
        itemUI:setVisible(false)

        table.insert(scrollView._delItemUIMap, itemUI)
        table.remove(scrollView._curItemUIMap, #scrollView._curItemUIMap)

        scrollView._curItemUICount = scrollView._curItemUICount - 1


        if isDoLayout == true then
            scrollView:resetPos()
        end
    end

    function scrollView:delAllItemUI()
        for k, v in pairs(scrollView._curItemUIMap) do
            v:setVisible(false)
            table.insert(scrollView._delItemUIMap, v)
        end

        scrollView._curItemUIMap = {}
        scrollView._curItemUICount = 0
        scrollView:resetPos()
    end

    function scrollView:resetPos()
        --logger:info("=======================>function scrollView:resetPos()")
        local inner = scrollView:getInnerContainer()
        local innerSize = inner:getContentSize()
        local svSize = scrollView:getContentSize()
    
        local height = 0

        for i = 1, #scrollView._curItemUIMap do
            local itemUI = scrollView._curItemUIMap[i]
            height = height + scrollView._spacing
            --logger:info("========>index:%s, itemUI:setPositionY(%s)", i, height)
            itemUI:setPositionY(height)
            itemUI:setVisible(true)
    
            height = height + itemUI.autoHeight
        end

        height = height + scrollView._spacing


        -- 如果子项不满屏，修正子项的位置
        if height < svSize.height then
            local offset = svSize.height - height    
            for k, v in pairs(scrollView._curItemUIMap) do
                --logger:info("========>fix = > index:%s, itemUI:setPositionY(%s)", k, v:getPositionY() + offset)
                v:setPositionY(v:getPositionY() + offset)
            end
        end

        -- 子项越多,setInnerContainerSize就越耗时
        if svSize.height < height and innerSize.height ~= height then
            scrollView:setInnerContainerSize(cc.size(svSize.width, height))
        end
    
        -- TODO:这里下面写的代码都会执行两次。。。诡异，求解
        -- print("============================================>1")    
    end

    function scrollView:isInBottom()
        local inner = scrollView:getInnerContainer()
        local y = inner:getPositionY()
        --logger:info("===================>isInBottom:%s", y)
        return y >= -20
    end
end


