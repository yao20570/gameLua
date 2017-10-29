-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MailCollectPanel = class("MailCollectPanel", BasicPanel)
MailCollectPanel.NAME = "MailCollectPanel"

function MailCollectPanel:ctor(view, panelName)
    MailCollectPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function MailCollectPanel:finalize()
    MailCollectPanel.super.finalize(self)
end

function MailCollectPanel:initPanel()
	MailCollectPanel.super.initPanel(self)
    self._mailActionPanel = self:getPanel(MailActionPanel.NAME)
    self._listview = self:getChildByName("bgListView")
    self._mailProxy = self:getProxy(GameProxys.Mail)
    self._worldProxy= self:getProxy(GameProxys.World)
end

function MailCollectPanel:registerEvents()
	MailCollectPanel.super.registerEvents(self)
end

-- ����Ӧ
function MailCollectPanel:doLayout()
	local panel = self:getPanel(MailActionPanel.NAME)
    local downWidget = panel:getDownPanel()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listview,downWidget,tabsPanel)
end

function MailCollectPanel:onShowHandler()
    

    self:updateCollectListView()
end

-- �б�ˢ��
function MailCollectPanel:updateCollectListView()
    local collectData = self._mailProxy:getCollectData()

    self:renderListView(self._listview, collectData, self, self.registerCollectItem)
    self._mailActionPanel:setBeingDelectMail(collectData)
end
-- ˢ���б�MailShortInfo
-- type = 6;//�ʼ�����1:ϵͳ��2�������䣻3���ʼ���4������
function MailCollectPanel:registerCollectItem(item, data, index)
    -- ��Ϊ���࣬����ͷǱ���
    local mailImg   = item:getChildByName("mailImg")
    local reportImg = item:getChildByName("reportImg")
    mailImg:setVisible(false)
    reportImg:setVisible(false)
    if data.type == 4 then
        reportImg:setVisible(true)
        -- ���ñ���
        self:setReportMailItemShow(item, data)
    else
        mailImg:setVisible(true)
        self:setMailItemShow(item, data)
    end
end

------
-- ��ͨ�ʼ�item����
function MailCollectPanel:setMailItemShow(item, data)
    if item == nil then
		return
	end
	item:setVisible(true)
	item.data = data -- �ʼ�����
	local Image_6 = item:getChildByName("mailImg")
	local name = Image_6:getChildByName("name")
    local statusLab = Image_6:getChildByName("statusLab")
	local title = Image_6:getChildByName("title")
	local time = Image_6:getChildByName("time")
	local bg = Image_6:getChildByName("bg")
	local openImg = Image_6:getChildByName("openImg")
	local closeImg = Image_6:getChildByName("closeImg")
	if data.state == 0 then
		closeImg:setVisible(true)
		openImg:setVisible(false)
	else
		closeImg:setVisible(false)
		openImg:setVisible(true)
	end
    if data.extracted == 1 then
        statusLab:setVisible(true)
        statusLab:setString(TextWords:getTextWord(1231))
        statusLab:setColor(cc.c3b(0, 255, 0))
    elseif data.extracted == 0 then
        statusLab:setVisible(true)
        statusLab:setString(TextWords:getTextWord(1230))
        statusLab:setColor(cc.c3b(255, 0, 0))
    else 
        statusLab:setVisible(false)
    end
	name:setString(item.data.name)
	title:setString(item.data.title)
	local timeStr = TimeUtils:setTimestampToString(item.data.createTime)
	time:setString(timeStr)
    self:addItemEvent(item)
end

-- �ʼ�����1:ϵͳ��2�������䣻3���ʼ���4������
function MailCollectPanel:addItemEvent(item)
--	if item.addEvent == true then
--		return
--	end
--	item.addEvent = true
    local data = item.data
    if data.type == 3 then -- 3���ʼ�
        self:addTouchEventListener(item,self.onReadMailReq)
    elseif data.type == 2 then -- 2��������
        self:addTouchEventListener(item,self.onReadMailReq02)
    elseif data.type == 1 then -- 1:ϵͳ
        self:addTouchEventListener(item,self.onReadMailReq03)
	end

end
-- 3���ʼ�
function MailCollectPanel:onReadMailReq(sender)
	local listData = self.view:getAllDetailData()
	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailDetailPanel.NAME)
		--�ʼ�tab�鿴�ʼ�����Ҫ�������һ��label
		panel:show(3)
		panel:setContentText(sender.data.id)
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
    
end

-- 2��������
function MailCollectPanel:onReadMailReq02(sender)
	local listData = self.view:getAllDetailData()
	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailDetailPanel.NAME)
		panel:show()
		panel:setContentText(sender.data.id)
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
    
end
-- 1:ϵͳ
function MailCollectPanel:onReadMailReq03(sender)
	local listData = self.view:getAllDetailData()
	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailReportInfoPanel.NAME)
		panel:show()
		panel:updateListData(listData[sender.data.id])
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
    
end

---------------------------------------------------------------------------------------------
function MailCollectPanel:setReportMailItemShow(item, data)
	if item == nil then
		return
	end
	item:setVisible(true)
	item.data = data
	local Image_6 = item:getChildByName("reportImg") -- ���ġ�===========

	local name = Image_6:getChildByName("name")
	local time = Image_6:getChildByName("time")
	local bg = Image_6:getChildByName("bg")
	local openImg = Image_6:getChildByName("openImg")
	local closeImg = Image_6:getChildByName("closeImg")
    local fightStateTxt = Image_6:getChildByName("fightStateTxt") -- ս��
    local nameTxt = Image_6:getChildByName("nameTxt") -- ����
    local typeTxt = Image_6:getChildByName("typeTxt") -- ��XX
    local failImg = Image_6:getChildByName("failImg") -- ʧ��ͼ
    local victoryImg = Image_6:getChildByName("victoryImg") -- ʤ��ͼ
    local defendResNameTxt = Image_6:getChildByName("defendResNameTxt")
    failImg:setVisible(false)
    victoryImg:setVisible(false)
    -- ��ʼ��
    nameTxt:setString("")
    nameTxt:setColor(cc.c3b(255, 255, 255))
    typeTxt:setString("")
    defendResNameTxt:setString("")
    defendResNameTxt:setColor(cc.c3b(255, 255, 255))
    -- �����Ѷ�δ��
	if data.state == 0 then
		closeImg:setVisible(true)
		openImg:setVisible(false)
	else
		closeImg:setVisible(false)
		openImg:setVisible(true)
	end
    
    --------- 1 ս��������2��ս������;3�����
    local itemData = item.data   -- MailShortInfo�ṹ��
    local resultStr = ""
    -- ������ʾ
    if itemData.mailType == 1 then -- ��������ս��ʽ�� ����{�������}������/������������ƣ�/������������ƣ��ģ�������ƣ�
        -- ս����ս
        if itemData.typeState == 0 then -- ʤ��
            resultStr = TextWords:getTextWord(1215)
            victoryImg:setVisible(true)
        elseif itemData.typeState == 1 then -- ʧ��
            resultStr = TextWords:getTextWord(1216)
            failImg:setVisible(true)
        elseif itemData.typeState == 3 then -- �ɼ��ɹ�
            resultStr = TextWords:getTextWord(1249)
        end
        fightStateTxt:setString(resultStr)
        -- ���� ����{����}�����ǡ�����{��Դ����}
        if itemData.typeState ~= 3 then 
            -- �ǲɼ�
            name:setString(self:getTextWord(1235))
            if itemData.targetType == 1 then --  targetType 1��� 2���ռ�����Դ�� 3����Դ�� 4 �Ҿ�ආ�
                nameTxt:setString(itemData.name) 
                typeTxt:setString(self:getTextWord(1236))
            elseif itemData.targetType == 2 then
                nameTxt:setString(itemData.defendName )
                typeTxt:setString(self:getTextWord(1240)) -- [[��]]
                defendResNameTxt:setString(itemData.name)
                local loyaltyCount = itemData.loyaltyCount
                defendResNameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))
            elseif itemData.targetType == 3 then 
                nameTxt:setString(itemData.name)
                local loyaltyCount = itemData.loyaltyCount
                nameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))
            elseif itemData.targetType == 4 then -- ��ʽ�� ආ�Lv
                nameTxt:setString("Lv."..itemData.level .. itemData.name ) 
                --typeTxt:setString("Lv."..itemData.level) 
            end
        else
            -- �ɼ�
            name:setString(self:getTextWord(1250)) -- "��"
            nameTxt:setString(itemData.name)
            local loyaltyCount = itemData.loyaltyCount
            nameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))
            typeTxt:setString(self:getTextWord(1251)) -- "�ɼ�����"
        end
    elseif itemData.mailType == 2 then -- ����
        -- ս������
        if itemData.typeState == 0 then -- ʤ��
            victoryImg:setVisible(true)
            resultStr = TextWords:getTextWord(1213)
        else
            failImg:setVisible(true)
            resultStr = TextWords:getTextWord(1214)
        end
        fightStateTxt:setString(resultStr)
        -- ����
        name:setString(self:getTextWord(3504))
        nameTxt:setString(itemData.name)
        typeTxt:setString(self:getTextWord(1237))
    elseif itemData.mailType == 3 then -- ����ʽ���鿴{�������}{��ҵȼ�} / �鿴��������ƣ��ģ�������ƣ�/�鿴{�������}
        -- ս��
        resultStr = TextWords:getTextWord(1234)
        fightStateTxt:setString(resultStr)
        -- ����
        name:setString(self:getTextWord(1210))
        if itemData.targetType == 1 then --  targetType 1��� 2���ռ�����Դ�� 3����Դ��
            nameTxt:setString(itemData.name.. "Lv."..itemData.level) 
        elseif itemData.targetType == 2 then
            nameTxt:setString(itemData.defendName )
            typeTxt:setString(self:getTextWord(1240)) -- ��
            defendResNameTxt:setString(itemData.name)
            local loyaltyCount = itemData.loyaltyCount
            defendResNameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))
        elseif itemData.targetType == 3 then
            nameTxt:setString(itemData.name)
            local loyaltyCount = itemData.loyaltyCount
            nameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))
        end
    end

    -- �����ı�λ������
    NodeUtils:fixTwoNodePos(name, nameTxt, 2)
    NodeUtils:fixTwoNodePos(nameTxt, typeTxt, 2)
    NodeUtils:fixTwoNodePos(typeTxt, defendResNameTxt, 2)
    -- ������ɫ
    self:setColorByTypeState(itemData.typeState, fightStateTxt)
    
    local timeStr = TimeUtils:setTimestampToString(itemData.createTime)
	time:setString(timeStr)

    -- �����Ӧ�¼�
	self:addItemEventReport(item) --���ġ�===============

end


function MailCollectPanel:addItemEventReport(item)
	self:addTouchEventListener(item,self.onReadMailReqReport)
end

function MailCollectPanel:onReadMailReqReport(sender)
	local listData = self.view:getAllDetailData()
	print("============",self.view.isShow)

	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailReportInfoPanel.NAME)
		panel:show()
		panel:updateListData(listData[sender.data.id]) -- ���� MailDetalInfo �ṹ��
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
end

------
-- ս����ɫ����
-- @param  args [obj] ����
-- @return nil
function MailCollectPanel:setColorByTypeState(typeState, strTxt)
    if typeState == 0 then -- ʤ��
        strTxt:setColor(ColorUtils.wordGreenColor)
    elseif typeState == 1 then -- ʧ��
        strTxt:setColor(ColorUtils.wordRedColor)
    elseif typeState == 2 then -- ���
        strTxt:setColor(ColorUtils.wordGreenColor)
    elseif typeState == 3 then -- �ɼ��ɹ�
        strTxt:setColor(ColorUtils.wordGreenColor)
    end
end

