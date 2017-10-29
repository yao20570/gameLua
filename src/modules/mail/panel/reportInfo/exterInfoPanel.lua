exterInfoPanel = {}
exterInfoPanel.NAME = "exterInfoPanel"

function exterInfoPanel:ctor(panel,parent)
	self._panel = panel
	self._parent = parent


end

function exterInfoPanel:updateData(panel,data)
	local selfData = data.context
	if selfData ~= nil then
        --local clonePanel = self._panel:clone()
        local Image_18_0_0 = panel:getChildByName("Image_18_0_1")
        local title = Image_18_0_0:getChildByName("ftlabel")
		-- local str = StringUtils:getStringAddBackEnter(selfData,15)

        local space = 10
        local svWorld = panel:getChildByName("svWorld")
        local world = svWorld:getChildByName("world")
        local richLab = svWorld:getChildByName("richLab")
        

        local params = nil
        if string.find(selfData, "^({{).+(txt).+(=).+(}})$") == nil then
           
            world:setString(selfData)
            world:setVisible(true)
            if richLab ~= nil then
                richLab:setVisible(false)
            end
        else    
            params = loadstring("return " .. selfData)()

            world:setVisible(false)

            if richLab == nil then
                local x, y = world:getPosition()
                local richLabWidth = svWorld:getContentSize().width - 2 * space
                richLab = RichTextMgr:getInstance():getRich( { }, richLabWidth, nil, nil, nil, RichLabelAlign.left_top)    
                richLab:setName("richLab")
                richLab:setPositionX(x + space)
                
                richLab:setLocalZOrder(world:getLocalZOrder())
                world:getParent():addChild(richLab)
                world:setVisible(false)
            end

            richLab:setVisible(true)
            richLab:setData(params)
            local svWorldSize = svWorld:getContentSize()
            local richLabSize = richLab:getContentSize()
            
            local innerSize = {}
            innerSize.width = svWorldSize.width
            innerSize.height = richLabSize.height + 2 * space
            svWorld:setInnerContainerSize(innerSize)


            innerSize = svWorld:getInnerContainerSize()
            richLab:setPositionY(innerSize.height - space)
        end
            		


		title:setString(data.title)


        local rechargeTipTxt = panel:getChildByName("rechargeTipTxt")
        local state =  string.find(selfData, TextWords:getTextWord(1500))
        rechargeTipTxt:setVisible(state ~= nil) 

        local Panel_17 = panel:getChildByName("Panel_17")
        local sendLab = Panel_17:getChildByName("sendName")
        sendLab:setString(data.name)

        local themeLabel = Panel_17:getChildByName("themeLabel")
        themeLabel:setString(data.title)
        local timeLabel = Panel_17:getChildByName("timeLabel")
        timeLabel:setString(TimeUtils:setTimestampToString(data.createTime))

        --// ¸½¼þ ºá·ù
        local Image_27 = Panel_17:getChildByName("Image_27")
        if #data.reward > 0 then 
        Image_27:setVisible(true)
        else
        Image_27:setVisible(false)
        end
	end
end
