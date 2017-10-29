local LegionTask = {} 
LegionTask[1] = {ID = 1, sort = 1, Icon = 10503, describe = '城主战参战6次', limit = 6, resetType = 0, type = 74, finishcond2 = 1, jumpmodule = 'LordCityModule', reaches = 'LordCityMainPanel'}
LegionTask[2] = {ID = 2, sort = 2, Icon = 10503, describe = '郡城战参战6次', limit = 6, resetType = 0, type = 75, finishcond2 = 1, jumpmodule = 'MapModule', reaches = 'MapPanel'}
LegionTask[3] = {ID = 3, sort = 3, Icon = 20012, describe = '群雄逐鹿参战1次（每周重置）', limit = 1, resetType = 1, type = 66, finishcond2 = 1, jumpmodule = 'WarlordsModule', reaches = 'WarlordsPanel'}
LegionTask[4] = {ID = 4, sort = 4, Icon = 10516, describe = '同盟建筑捐献10次', limit = 10, resetType = 0, type = 76, finishcond2 = 1, jumpmodule = 'LegionScienceTechModule', reaches = 'LegionScienceHallPanel'}
LegionTask[5] = {ID = 5, sort = 5, Icon = 10504, describe = '同盟副本战斗5次', limit = 5, resetType = 0, type = 22, finishcond2 = 1, jumpmodule = 'LegionCombatCenterModule', reaches = 'LegionCapterPanel'}
LegionTask[6] = {ID = 6, sort = 6, Icon = 20013, describe = '同盟频道发送聊天10次', limit = 10, resetType = 0, type = 71, finishcond2 = 1, jumpmodule = 'ChatModule', reaches = 'LegionChatPanel'}
LegionTask[7] = {ID = 7, sort = 7, Icon = 10516, describe = '同盟科技捐献10次', limit = 10, resetType = 0, type = 77, finishcond2 = 1, jumpmodule = 'LegionScienceTechModule', reaches = 'LegionScienceTechPanel'}
LegionTask[8] = {ID = 8, sort = 8, Icon = 10515, describe = '同盟帮助40次', limit = 40, resetType = 0, type = 35, finishcond2 = 5, jumpmodule = 'LegionHelpModule', reaches = 'LegionHelpPanel'}
LegionTask[9] = {ID = 9, sort = 9, Icon = 20014, describe = '参加1次科举', limit = 1, resetType = 0, type = 65, finishcond2 = 1, jumpmodule = 'ProvincialExamModule', reaches = 'ProvExamAnswerPanel'}
LegionTask[10] = {ID = 10, sort = 10, Icon = 20011, describe = '参加5次乱军', limit = 5, resetType = 0, type = 57, finishcond2 = 1, jumpmodule = 'MapModule', reaches = 'MapPanel'}
LegionTask[11] = {ID = 11, sort = 11, Icon = 20015, describe = '参加1次殿试（每周重置）', limit = 1, resetType = 1, type = 69, finishcond2 = 1, jumpmodule = 'PalaceExamModule', reaches = 'PalaceExamAnswerPanel'}
LegionTask[12] = {ID = 12, sort = 12, Icon = 20016, describe = '讨伐3次物资（每周重置）', limit = 3, resetType = 1, type = 70, finishcond2 = 1, jumpmodule = 'WorldBossModule', reaches = 'WorldBossPanel'}
return LegionTask