module("server", package.seeall)

PlayerReward = class("PlayerReward")

function PlayerReward:ctor()
    self.addItemMap = {}
    self.addPowerMap = {}
    self.soldierMap = {}
    self.counsellorMap = {}
    self.generalMap = {}
    self.ordanceMap = {}
    self.ordanceFragmentMap = {}
    self.generalList = {}
    self.ordanceList = {}
end