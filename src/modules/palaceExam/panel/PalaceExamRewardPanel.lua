-- 奖励预览弹窗
PalaceExamRewardPanel = class("PalaceExamRewardPanel", BasicPanel)
PalaceExamRewardPanel.NAME = "PalaceExamRewardPanel"

function PalaceExamRewardPanel:ctor(view, panelName)
    PalaceExamRewardPanel.super.ctor(self, view, panelName, 700)

end

function PalaceExamRewardPanel:finalize()
    PalaceExamRewardPanel.super.finalize(self)
end

function PalaceExamRewardPanel:initPanel()
	PalaceExamRewardPanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(1325))
	self.proxy = self:getProxy(GameProxys.ExamActivity)
end

function PalaceExamRewardPanel:doLayout()
end

function PalaceExamRewardPanel:onShowHandler()
    local rewardPanel = self:getChildByName("rewardPanel")
    local rewardList = rewardPanel:getChildByName("listview")
    local palaceEaxmAllRewardArray = self.proxy:getPalaceEaxmAllRewardArray()
    self:renderListView(rewardList, palaceEaxmAllRewardArray, self, self.renderRewardItem)
end

function PalaceExamRewardPanel:renderRewardItem(itemPanel, info, index)

    local nameLab = itemPanel:getChildByName("index_label")
    local itemArr  = {}
    local itemImg1 = itemPanel:getChildByName("itemImg1")
    table.insert(itemArr,itemImg1)
    local itemImg2 = itemPanel:getChildByName("itemImg2")
    table.insert(itemArr,itemImg2)
    local itemImg3 = itemPanel:getChildByName("itemImg3")
    table.insert(itemArr,itemImg3)
    if info.ranking == info.rankingii then
        nameLab:setString(string.format("%s%d%s",self:getTextWord(360015),info.ranking,self:getTextWord(360016)))
    else
        nameLab:setString(string.format("%s%d%s%d%s",self:getTextWord(360015),info.ranking,self:getTextWord(360017),info.rankingii,self:getTextWord(360016)))
    end


    local rewardArr = StringUtils:jsonDecode(info.reward)
    for i,v in ipairs(itemArr) do
        v:setVisible(false)
    end
    local materialDataTable = rewardArr
    local roleProxy = self:getProxy(GameProxys.Role)
    for i=1,#rewardArr do
        local haveNum =  roleProxy:getRolePowerValue(materialDataTable[i][1], materialDataTable[i][2])
        --self:renderChild(itemArr[i], haveNum, materialDataTable[i][3])
        local iconData = {}
        iconData.typeid = materialDataTable[i][2]
        iconData.num = materialDataTable[i][3]
        iconData.power = materialDataTable[i][1]
        if itemArr[i].uiIcon == nil then
            itemArr[i].uiIcon = UIIcon.new(itemArr[i], iconData, true, self, nil, true)
        else
            itemArr[i].uiIcon:updateData(iconData)
        end
        itemArr[i]:setVisible(true)
    end

end


