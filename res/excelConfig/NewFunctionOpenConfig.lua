local NewFunctionOpen = {} 
NewFunctionOpen[1] = {ID = 1, name = '战役副本', icon = 1, wordicon = 1, info = '挑战剧情战役需消耗军令\n 胜利可获得大量奖励哦', type = 1, need = 3, nextid = {0}, opentips = '主公3级开放', windowShow = 1}
NewFunctionOpen[2] = {ID = 2, name = '统率', icon = 2, wordicon = 2, info = '解锁增加带兵数培养功能\n提升统率等级可增加带兵数', type = 1, need = 4, nextid = {0}, opentips = '主公4级开放', windowShow = 1}
NewFunctionOpen[3] = {ID = 3, name = '战法', icon = 3, wordicon = 3, info = '解锁主公战法技能功能\n提升战法等级可增加兵种能力', type = 1, need = 6, nextid = {0}, opentips = '主公6级开放', windowShow = 0}
NewFunctionOpen[4] = {ID = 4, name = '每日礼包', icon = 4, wordicon = 4, info = '玩家每日首次登陆刻领取奖励\n明天有关羽可领取哦！！', type = 1, need = 1, nextid = {0}, moduleName = 'OpenServerGiftModule', opentips = '主公1级开放', windowShow = 0}
NewFunctionOpen[5] = {ID = 5, name = '酒馆', icon = 5, wordicon = 5, info = '解锁小宴，有机会获得各类兵种\n每日都有一次免费抽取机会', type = 1, need = 1, nextid = {0}, moduleName = 'PubModule', opentips = '主公1级开放', windowShow = 1}
NewFunctionOpen[6] = {ID = 6, name = '匈奴远征', icon = 12, wordicon = 6, info = '开启新战役副本功能\n每天挑战可获得丰富的武将材料', type = 1, need = 11, nextid = {0}, opentips = '主公11级开放', windowShow = 1}
NewFunctionOpen[7] = {ID = 7, name = '同盟玩法', icon = 6, wordicon = 7, info = '可邀请盟员帮助主公加快建造速度\n每天挑战同盟副本可获丰富的材料', type = 1, need = 8, nextid = {0}, opentips = '主公8级开放', windowShow = 1}
NewFunctionOpen[8] = {ID = 8, name = '演武场', icon = 7, wordicon = 8, info = '战胜其他主公提高自身的三国排名\n可获得大量稀有材料哦', type = 1, need = 12, nextid = {0}, opentips = '主公12级开放', windowShow = 1}
NewFunctionOpen[9] = {ID = 9, name = '盛宴', icon = 5, wordicon = 5, info = '解锁盛宴，有机会获得高级兵种', type = 1, need = 8, nextid = {0}, moduleName = 'PubModule', modulePanel = 'PubSpePanel', opentips = '主公8级开放', windowShow = 1}
NewFunctionOpen[10] = {ID = 10, name = '战功任务', icon = 8, wordicon = 10, info = '每天完成战功任务可领取宝箱\n宝箱可获得大量经验、声望、材料', type = 1, need = 14, nextid = {0}, opentips = '主公14级开放', windowShow = 1}
NewFunctionOpen[11] = {ID = 11, name = '战将探宝', icon = 5, wordicon = 5, info = '探寻宝藏，有机会获得紫将\n每日都有一次免费抽取机会', type = 1, need = 20, nextid = {0}, moduleName = 'TreasureModule', modulePanel = 'TreasureHeroPanel', opentips = '主公20级开放', windowShow = 0}
NewFunctionOpen[12] = {ID = 12, name = '军械所', icon = 9, wordicon = 11, info = '解锁兵种穿戴军械功能\n强化军械可快速提升兵种的作战能力', type = 1, need = 25, nextid = {0}, moduleName = 'PartsModule', opentips = '主公25级开放', windowShow = 1}
NewFunctionOpen[13] = {ID = 13, name = '鲜卑远征', icon = 12, wordicon = 23, info = '开启新战役副本功能\n每天挑战可获得丰富的军械锻造材料', type = 1, need = 25, nextid = {0}, opentips = '主公25级开放', windowShow = 0}
NewFunctionOpen[14] = {ID = 14, name = '西域远征', icon = 12, wordicon = 22, info = '开启新战役副本功能\n每天挑战可获得丰富的稀有材料', type = 1, need = 16, nextid = {0}, opentips = '主公16级开放', windowShow = 1}
NewFunctionOpen[15] = {ID = 15, name = '仓库一', icon = 10, wordicon = 12, info = '解锁主城新建筑功能\n增加资源存储量和上限', type = 2, need = 4, nextid = {0}, opentips = '官邸4级开放', windowShow = 0}
NewFunctionOpen[16] = {ID = 16, name = '工匠坊', icon = 10, wordicon = 13, info = '解锁主城新建筑功能\n使用战法秘籍生产稀有道具', type = 2, need = 7, nextid = {0}, opentips = '官邸7级开放', windowShow = 0}
NewFunctionOpen[17] = {ID = 17, name = '民心功能', icon = 11, wordicon = 21, info = '消耗民心获得丰富材料\n每天民心值会重置哦！', type = 2, need = 6, nextid = {0}, opentips = '官邸6级开放', windowShow = 1}
NewFunctionOpen[18] = {ID = 18, name = '校场', icon = 10, wordicon = 14, info = '解锁主城新建筑功能\n将低阶兵种训练成高阶兵种', type = 2, need = 13, nextid = {0}, opentips = '官邸13级开放', windowShow = 0}
NewFunctionOpen[19] = {ID = 19, name = '仓库二', icon = 10, wordicon = 12, info = '解锁主城新建筑功能\n增加资源存储量和上限', type = 2, need = 15, nextid = {0}, opentips = '官邸15级开放', windowShow = 0}
NewFunctionOpen[20] = {ID = 20, name = '兵营二', icon = 10, wordicon = 15, info = '解锁主城新建筑功能\n让主公征召的队列多一些', type = 2, need = 22, nextid = {0}, opentips = '官邸22级开放', windowShow = 0}
NewFunctionOpen[21] = {ID = 21, name = '解锁骑兵', icon = 13, wordicon = 16, info = '恭喜解锁新兵种\n兵营获得征召骑兵的权限', type = 3, need = 3, nextid = {0}, opentips = '兵营3级开放', windowShow = 0}
NewFunctionOpen[22] = {ID = 22, name = '出战槽位', icon = 14, wordicon = 17, info = '恭喜解锁3号出战位\n部队上阵数+1、武将上阵数+1', type = 3, need = 4, nextid = {0}, opentips = '兵营4级开放', windowShow = 0}
NewFunctionOpen[23] = {ID = 23, name = '出战槽位', icon = 14, wordicon = 17, info = '恭喜解锁4号出战位\n部队上阵数+1、武将上阵数+1', type = 3, need = 7, nextid = {0}, opentips = '兵营7级开放', windowShow = 0}
NewFunctionOpen[24] = {ID = 24, name = '解锁枪兵', icon = 13, wordicon = 18, info = '恭喜解锁新兵种\n兵营获得征召枪兵的权限', type = 3, need = 7, nextid = {0}, opentips = '兵营7级开放', windowShow = 0}
NewFunctionOpen[25] = {ID = 25, name = '出战槽位', icon = 14, wordicon = 17, info = '恭喜解锁5号出战位\n部队上阵数+1、武将上阵数+1', type = 3, need = 10, nextid = {0}, opentips = '兵营10级开放', windowShow = 0}
NewFunctionOpen[26] = {ID = 26, name = '解锁弓兵', icon = 13, wordicon = 19, info = '恭喜解锁新兵种\n兵营获得征召弓兵的权限', type = 3, need = 10, nextid = {0}, opentips = '兵营10级开放', windowShow = 0}
NewFunctionOpen[27] = {ID = 27, name = '解锁朴刀兵', icon = 13, wordicon = 20, info = '恭喜解锁新兵种\n兵营获得征召朴刀兵的权限', type = 3, need = 13, nextid = {0}, opentips = '兵营13级开放', windowShow = 0}
NewFunctionOpen[28] = {ID = 28, name = '出战槽位', icon = 14, wordicon = 17, info = '恭喜解锁6号出战位\n部队上阵数+1、武将上阵数+1', type = 3, need = 15, nextid = {0}, opentips = '兵营15级开放', windowShow = 0}
NewFunctionOpen[29] = {ID = 29, name = '解锁游骑兵', icon = 13, wordicon = 16, info = '恭喜解锁新兵种\n兵营获得征召游骑兵的权限', type = 3, need = 16, nextid = {0}, opentips = '兵营16级开放', windowShow = 0}
NewFunctionOpen[30] = {ID = 30, name = '解锁陷阵兵', icon = 13, wordicon = 18, info = '恭喜解锁新兵种\n兵营获得征召陷阵兵的权限', type = 3, need = 19, nextid = {0}, opentips = '兵营19级开放', windowShow = 0}
NewFunctionOpen[31] = {ID = 31, name = '解锁长弓兵', icon = 13, wordicon = 19, info = '恭喜解锁新兵种\n兵营获得征召长弓兵的权限', type = 3, need = 22, nextid = {0}, opentips = '兵营22级开放', windowShow = 0}
NewFunctionOpen[32] = {ID = 32, name = '解锁重刀兵', icon = 13, wordicon = 20, info = '恭喜解锁新兵种\n兵营获得征召重刀兵的权限', type = 3, need = 25, nextid = {0}, opentips = '兵营25级开放', windowShow = 0}
NewFunctionOpen[33] = {ID = 33, name = '解锁重骑兵', icon = 13, wordicon = 16, info = '恭喜解锁新兵种\n兵营获得征召重骑兵的权限', type = 3, need = 28, nextid = {0}, opentips = '兵营28级开放', windowShow = 0}
NewFunctionOpen[34] = {ID = 34, name = '解锁重枪兵', icon = 13, wordicon = 18, info = '恭喜解锁新兵种\n兵营获得征召重枪兵的权限', type = 3, need = 31, nextid = {0}, opentips = '兵营31级开放', windowShow = 0}
NewFunctionOpen[35] = {ID = 35, name = '解锁重弓兵', icon = 13, wordicon = 19, info = '恭喜解锁新兵种\n兵营获得征召重弓兵的权限', type = 3, need = 34, nextid = {0}, opentips = '兵营34级开放', windowShow = 0}
NewFunctionOpen[36] = {ID = 36, name = '解锁巨刀兵', icon = 13, wordicon = 20, info = '恭喜解锁新兵种\n兵营获得征召巨刀兵的权限', type = 3, need = 37, nextid = {0}, opentips = '兵营37级开放', windowShow = 0}
NewFunctionOpen[37] = {ID = 37, name = '解锁骠刀骑', icon = 13, wordicon = 20, info = '恭喜解锁新兵种\n兵营获得征召骠刀骑的权限', type = 3, need = 40, nextid = {0}, opentips = '兵营40级开放', windowShow = 0}
NewFunctionOpen[38] = {ID = 38, name = '解锁铁甲兵', icon = 13, wordicon = 20, info = '恭喜解锁新兵种\n兵营获得征召铁甲兵的权限', type = 3, need = 43, nextid = {0}, opentips = '兵营43级开放', windowShow = 0}
NewFunctionOpen[39] = {ID = 39, name = '解锁劲弩兵', icon = 13, wordicon = 20, info = '恭喜解锁新兵种\n兵营获得征召劲弩兵的权限', type = 3, need = 46, nextid = {0}, opentips = '兵营46级开放', windowShow = 0}
NewFunctionOpen[40] = {ID = 40, name = '解锁神刀兵', icon = 13, wordicon = 20, info = '恭喜解锁新兵种\n兵营获得征召神刀兵的权限', type = 3, need = 49, nextid = {0}, opentips = '兵营49级开放', windowShow = 0}
NewFunctionOpen[41] = {ID = 41, name = '解锁冲锋骑', icon = 13, wordicon = 20, info = '恭喜解锁新兵种\n兵营获得征召冲锋骑的权限', type = 3, need = 52, nextid = {0}, opentips = '兵营52级开放', windowShow = 0}
NewFunctionOpen[42] = {ID = 42, name = '解锁锦帆军', icon = 13, wordicon = 20, info = '恭喜解锁新兵种\n兵营获得征召锦帆军的权限', type = 3, need = 55, nextid = {0}, opentips = '兵营55级开放', windowShow = 0}
NewFunctionOpen[43] = {ID = 43, name = '解锁神机营', icon = 13, wordicon = 20, info = '恭喜解锁新兵种\n兵营获得征召神机营的权限', type = 3, need = 58, nextid = {0}, opentips = '兵营58级开放', windowShow = 0}
NewFunctionOpen[44] = {ID = 44, name = '解锁讨伐物资', icon = 1, wordicon = 1, info = '恭喜解锁讨伐物资活动资格', type = 1, need = 22, nextid = {0}, opentips = '主公22级开放', windowShow = 0}
NewFunctionOpen[45] = {ID = 45, name = '解锁军师', icon = 15, wordicon = 24, info = '恭喜解锁军师功能\n军师具备内政和战斗能力', type = 1, need = 28, nextid = {0}, opentips = '主公28级开放', windowShow = 1}
NewFunctionOpen[46] = {ID = 46, name = '解锁宝具', icon = 16, wordicon = 25, info = '恭喜解锁宝具功能\n武将穿戴宝具可大幅度提升能力', type = 1, need = 100, nextid = {0}, opentips = '该功能即将开放', windowShow = 0}
NewFunctionOpen[47] = {ID = 47, name = '解锁国策', icon = 17, wordicon = 9, info = '恭喜解锁国策功能', type = 1, need = 30, nextid = {0}, opentips = '主公30级开放', windowShow = 1}
NewFunctionOpen[48] = {ID = 48, name = '排行榜', icon = 12, wordicon = 21, info = '恭喜解锁排行榜功能', type = 1, need = 16, nextid = {0}, opentips = '主公16级开放', windowShow = 0}
NewFunctionOpen[49] = {ID = 49, name = '常规活动', icon = 1, wordicon = 1, info = '恭喜解锁常规活动', type = 1, need = 5, nextid = {0}, moduleName = 'ActivityModule', modulePanel = 'ActivityPanel', opentips = '主公5级开放', windowShow = 0}
NewFunctionOpen[50] = {ID = 50, name = '科举', icon = 1, wordicon = 1, info = '恭喜解锁科举功能', type = 1, need = 10, nextid = {0}, opentips = '主公10级开放', windowShow = 0}
NewFunctionOpen[51] = {ID = 51, name = '乱军来袭', icon = 1, wordicon = 1, info = '恭喜解锁乱军来袭活动', type = 1, need = 16, nextid = {0}, opentips = '主公16级开放', windowShow = 0}
NewFunctionOpen[52] = {ID = 52, name = '四季系统', icon = 31, wordicon = 31, info = '恭喜解锁四季功能\n四季轮换提供各式加成', type = 1, need = 9, nextid = {0}, opentips = '主公9级开放', windowShow = 0}
NewFunctionOpen[53] = {ID = 53, name = '世界等级', icon = 1, wordicon = 1, info = '恭喜解锁世界等级功能', type = 1, need = 9, nextid = {0}, opentips = '主公9级开放', windowShow = 0}
NewFunctionOpen[54] = {ID = 54, name = '周卡', icon = 1, wordicon = 1, info = '恭喜解锁周卡功能', type = 1, need = 10, nextid = {0}, opentips = '主公10级开放', windowShow = 0}
NewFunctionOpen[55] = {ID = 55, name = '军机处', icon = 10, wordicon = 27, info = '恭喜解锁军机处功能', type = 1, need = 20, nextid = {0}, opentips = '主公20级开放', windowShow = 1}
NewFunctionOpen[56] = {ID = 56, name = '手动升级', icon = 1, wordicon = 1, info = '恭喜解锁手动升级功能', type = 1, need = 20, nextid = {0}, opentips = '主公20级开放', windowShow = 0}
NewFunctionOpen[57] = {ID = 57, name = '城主战开启', icon = 1, wordicon = 1, info = '恭喜解锁城主争夺战', type = 1, need = 20, nextid = {0}, opentips = '20级后开放城主争夺战', windowShow = 0}
NewFunctionOpen[58] = {ID = 58, name = '南越远征', icon = 18, wordicon = 28, info = '开启新战役副本功能\n每天挑战可获得大量兵晶与军机秘术', type = 1, need = 20, nextid = {0}, opentips = '主公20级开放', windowShow = 1}
NewFunctionOpen[59] = {ID = 59, name = '鲜卑远征(精英)', icon = 19, wordicon = 29, info = '开启新战役副本功能\n每天挑战可获得高级军械与改造材料', type = 1, need = 50, nextid = {0}, opentips = '主公50级开放', windowShow = 1}
NewFunctionOpen[60] = {ID = 60, name = '军功', icon = 32, wordicon = 32, info = '恭喜解锁军功功能', type = 1, need = 23, nextid = {0}, opentips = '主公23级开放', windowShow = 1}
NewFunctionOpen[61] = {ID = 61, name = '中原目标', icon = 32, wordicon = 33, info = '恭喜解锁中原目标功能', type = 1, need = 10, nextid = {0}, opentips = '主公10级开放', windowShow = 1}
NewFunctionOpen[62] = {ID = 62, name = '国家功能', icon = 32, wordicon = 33, info = '解锁国家系统', type = 1, need = 100, nextid = {0}, opentips = '该功能即将开放', windowShow = 0}
return NewFunctionOpen