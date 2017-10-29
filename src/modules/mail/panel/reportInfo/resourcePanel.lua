resourcePanel = {}
resourcePanel.NAME = "resourcePanel"

-- 侦查资源和主城
function resourcePanel:ctor(panel,parent)
	self._panel = panel
	self._parent = parent
end

function resourcePanel:updateData(panel,data)
	local selfData = rawget(data.infos,self.NAME) 
    local reportData = data.infos -- 表示结构体 Report
    local result     = reportData.InfoPanel.result -- 0胜利，1失败，3 采集成功
    local honner     = reportData.InfoPanel.honner -- 获得荣誉
    
    local loyaltyCount = reportData.loyaltyCount -- 民忠值
	if selfData ~= nil then
        -- 侦查资源
		local function resource(panel)
			local Label_120 = panel:getChildByName("Label_120")
			local Label_120_2_3 = panel:getChildByName("Label_120_2_3")
            local config = ConfigDataManager:getInfoFindByOneKey("ResourcePointConfig","ID",selfData.resourceId)
            local speedUp = self._parent:getPlusValueByLoyalty(loyaltyCount) + self._parent:getVipSpeedUpCollectRes()
            local productNum = config.product* speedUp
            
            Label_120:setString("")
			Label_120_2_3:setString(StringUtils:formatNumberByK(selfData.get))

            -- 富文本显示
            if Label_120.richLabel == nil then
                Label_120.richLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
                Label_120.richLabel:setPositionY(Label_120.richLabel:getPositionY() + 15)
                Label_120:addChild(Label_120.richLabel)
            end
            local richTable = {}
            local richShow01 = {}
            richShow01 = { StringUtils:formatNumberByK(productNum*3600), 22, "#40E215"}
            table.insert(richTable, richShow01)

            local richShow11 = {}
            richShow11 = { "(", 22, "#EED6AA"}
            table.insert(richTable, richShow11)

            local richShow02 = {}
            richShow02 = { config.name, 22, ColorUtils:getRichColorByQuality(self._parent:getColorByLoyalty(loyaltyCount))}
            table.insert(richTable, richShow02)

            local richShow03 = {}
            richShow03 = { ")"..TextWords:getTextWord(1263), 22, ColorUtils.commonColor.MiaoShu}
            table.insert(richTable, richShow03)

            Label_120.richLabel:setString( { richTable })
		end

        -- 设置颜色
        local function setTxtColor(node, value)
            if value < 0 then
                node:setColor(ColorUtils.wordRedColor)
            elseif value > 0 then
                node:setColor(ColorUtils.wordGreenColor)
            elseif value == 0 then
                node:setColor(cc.c3b(255, 189, 48) )
            end
        end

		local function fivePosRes(panel, isCheckCity)
			local Label_104_0 = panel:getChildByName("Label_104_0")
            -- 战绩设置
            local honnerTxt = panel:getChildByName("honnerTxt")
            local honnerNumTxt = panel:getChildByName("honnerNumTxt")
            if honnerTxt ~= nil then
                if honner == 0 then
                    honnerTxt:setVisible(false)
                    honnerNumTxt:setVisible(false)
                else
                    honnerTxt:setVisible(true)
                    honnerNumTxt:setVisible(true)
                    if honner > 0 then
                        honnerNumTxt:setString("+" ..honner)
                    else
                        honnerNumTxt:setString(honner)
                    end
                    setTxtColor(honnerNumTxt, honner)
                end
            end

			local index = 1
			local total = 0
			for _,v in pairs(selfData.info.posCount) do
                local item = panel:getChildByName("item"..index)
				local count = item:getChildByName("count")
                local str = StringUtils:formatNumberByK(v)
                if v > 0 and isCheckCity == false then
                    str = string.format( "+%s", str)
                end
                count:setString(str)
                total = total + v
				index = index + 1
                if isCheckCity == false then
                    setTxtColor(count, v)
                end
			end
            local str = StringUtils:formatNumberByK(total)
            if total > 0 and isCheckCity == false then
                str = string.format( "+%s", str)
            end
			Label_104_0:setString(str)
            if isCheckCity == false then
                setTxtColor(Label_104_0, total)
            end
            local ftLable =  panel:getChildByName("ftLable1_0")
            if ftLable then
                NodeUtils:alignNodeL2R(ftLable, Label_104_0, 8)
            end
        end

        ------
        -- 设置占领信息
        local function setOccupyMsg(checkType, panel) -- panel3
            local nameTxt       = panel:getChildByName("nameTxt")        -- 名字
            local legionNameTxt = panel:getChildByName("legionNameTxt")  -- 军团名
            local powerTxt      = panel:getChildByName("powerTxt")       -- 战力名字
            local occupyTitleTxt= panel:getChildByName("Label_56")          -- 前标题
            occupyTitleTxt:setString( TextWords:getTextWord(1261))
            nameTxt:setColor(cc.c3b(255, 255, 255))
            if checkType == 0 then -- Report的Resource.type字段，玩家or资源
                -- 主城
                nameTxt:setString("Lv."..reportData.InfoPanel.level ..  data.name) -- 显示占领者的名字
                local powerNum = reportData.watchSerPanel.teamCapacity -- 侦查点的战力
                powerTxt:setString( StringUtils:formatNumberByK3(powerNum)) -- 战力 
                if reportData.InfoPanel.legionName == "" then
                    legionNameTxt:setString(reportData.InfoPanel.legionName) -- 军团名字
                else
                    legionNameTxt:setString("["..reportData.InfoPanel.legionName.."]") -- 军团名字
                end
            else
                -- 资源点
                -- 检查是否有被占领
                if reportData.isPerson == 0 then
                    -- 有人资源点
                    nameTxt:setString("Lv."..reportData.InfoPanel.level .. reportData.InfoPanel.aim) -- 玩家名字
                    local powerNum = reportData.watchSerPanel.teamCapacity -- 侦查点的战力
                    powerTxt:setString( StringUtils:formatNumberByK3(powerNum)) -- 战力 
                    if reportData.InfoPanel.legionName == "" then
                        legionNameTxt:setString(reportData.InfoPanel.legionName) -- 军团名字
                    else
                        legionNameTxt:setString("["..reportData.InfoPanel.legionName.."]") -- 军团名字
                    end
                else
                    -- 无人资源点
                    nameTxt:setString(reportData.InfoPanel.name) -- 资源名地点
                    nameTxt:setColor(self._parent:getColorValueByLoyalty(loyaltyCount))

                    legionNameTxt:setString(reportData.InfoPanel.legionName)
                    local powerNum = reportData.watchSerPanel.teamCapacity -- 侦查点的战力(无人资源点)
                    powerTxt:setString( StringUtils:formatNumberByK3(powerNum)) -- 战力 
                end
            end
            -- 文本位置修正
            NodeUtils:alignNodeL2R(nameTxt, legionNameTxt, 2)
        end
        
        
        
        -- 若是采集
        if result == 3 then
            local panel1 = panel:getChildByName("panel1")
            local panel2 = panel:getChildByName("panel2")
            local panel3 = panel:getChildByName("panel3")
            local ftLable =  panel2:getChildByName("ftLable1_0")
            ftLable:setString(TextWords:getTextWord(1257)) -- [[采集资源:]]
            panel1:setVisible(false)
			panel2:setVisible(true)
            panel3:setVisible(false)
            fivePosRes(panel2, false)
            return -- 函数停止
        end
		if selfData.type == 1 or selfData.type == 0 then  --侦察资源或者玩家
            local panel1 = panel:getChildByName("panel1")
            local panel2 = panel:getChildByName("panel2")
            local panel3 = panel:getChildByName("panel3")
            local ftLable =  panel2:getChildByName("ftLable1_0")
            ftLable:setString(TextWords:getTextWord(1258)) -- [[可掠夺:]]
			if selfData.type == 1 then 
                -- 1侦查资源
				panel1:setVisible(true)
				panel2:setVisible(false)
                panel3:setVisible(true)
				resource(panel1)
			else
                -- 0侦查主城
				panel1:setVisible(false)
				panel2:setVisible(true)
                panel3:setVisible(true)
				fivePosRes(panel2, true)
			end
            -- 设置占领信息
            setOccupyMsg(selfData.type, panel3)
		else --战斗
			fivePosRes(panel, false)
		end
	end
end

