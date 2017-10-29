-- /**
--  * @Author:    lizhuojian
--  * @DateTime:    2017-05-09
--  * @Description: 限时活动_同盟致富_采集进度详细排行榜弹窗
--  */
LegionRichDetailPanel = class("LegionRichDetailPanel", BasicPanel)
LegionRichDetailPanel.NAME = "LegionRichDetailPanel"

function LegionRichDetailPanel:ctor(view, panelName)
    LegionRichDetailPanel.super.ctor(self, view, panelName,750)

end

function LegionRichDetailPanel:finalize()
    LegionRichDetailPanel.super.finalize(self)
end

function LegionRichDetailPanel:initPanel()
	LegionRichDetailPanel.super.initPanel(self)
	self.listview = self:getChildByName("mainPanel/listView")
	self.proxy = self:getProxy(GameProxys.Activity)
    self:setTitle(true, self:getTextWord(394002))
end

function LegionRichDetailPanel:registerEvents()
	LegionRichDetailPanel.super.registerEvents(self)
end
function LegionRichDetailPanel:onShowHandler(id)
    LegionRichDetailPanel.super.onShowHandler(self)
    self.id = id
	if self.proxy == nil then
 		self.proxy = self:getProxy(GameProxys.Activity)
	end
	local sendData = {}
	sendData.activityId = self.proxy:getCurActivityData().activityId
	sendData.id = id
    self.proxy:onTriggerNet230054Req(sendData)
    -- self:updateLegionRichDetailView(sendData)
end 
function LegionRichDetailPanel:updateLegionRichDetailView(sendData)

	local legionRichMemberInfo = self.proxy:getLegionRichMemberInfoById(self.id)

	local myRankNumLab = self:getChildByName("mainPanel/myRankNumLab")
	local curGatherNumLab = self:getChildByName("mainPanel/curGatherNumLab")
	if legionRichMemberInfo.myRank <= 0 then
		myRankNumLab:setString(self:getTextWord(394012))
	else
		myRankNumLab:setString(legionRichMemberInfo.myRank)
	end

	curGatherNumLab:setString( StringUtils:formatNumberByK3(legionRichMemberInfo.myGather) )

    self:renderListView(self.listview, legionRichMemberInfo.gatherInfos, self, self.renderItemPanel, false, true, 0)
end 
function LegionRichDetailPanel:renderItemPanel(item, itemInfo, index)
	local rankLab = item:getChildByName("rankLab")
	local nameLab = item:getChildByName("nameLab")
	local gatherLab = item:getChildByName("gatherLab")
	local itemBgImg = item:getChildByName("itemBgImg")
    local imgRank = item:getChildByName("imgRank")
    if index%2 == 0 then
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Gray.png")
    else
	    TextureManager:updateImageView(itemBgImg, "images/newGui9Scale/S9Brown.png")
    end
    
    imgRank:setVisible(false)
    local rank = itemInfo.rank
    if rank < 4 then
        local url = "images/newGui2/IconNum_1.png"
		if rank == 1 then
			url = "images/newGui2/IconNum_1.png"
		elseif rank == 2 then
			url = "images/newGui2/IconNum_2.png"
		elseif rank == 3 then
			url = "images/newGui2/IconNum_3.png"
		end
        TextureManager:updateImageView(imgRank, url)
        imgRank:setVisible(true)
    end
	rankLab:setString(itemInfo.rank)
	nameLab:setString(itemInfo.name)
	gatherLab:setString( StringUtils:formatNumberByK3(itemInfo.gather) )
    itemBgImg:setVisible(index%2 == 0)
end