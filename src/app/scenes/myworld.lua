world = {
	food = 0,			--食物
	maxFood = 200,		--最大食物
	wood = 0,			--木头
	maxWood = 200,		--最大木头
	stone = 0,			--石头
	maxStone = 200,		--最大石头
	gold = 0,			--金子
	people = 0,			--人口
	unemploymentPeople = 0,			--失业人口
	maxPeople = 0,		--最大人口
	doctor = 0,			--医生人数
	minister = 0,		--牧师人数
	infantry = 0,		--步兵人数
	maxInfantry = 0,	--最大步兵人数
	cavalry = 0,		--骑兵人数
	maxCavalry = 0,		--最大骑兵人数
	land = 1000,		--已经使用的土地
	maxLand = 0,		--最大土地
	fur = 0,			--毛皮
	herb = 0,			--药材
	ore = 0,			--矿石
	leather = 0,		--皮革
	metal = 0,			--金属
	happy = 0,			--欢乐度
	faith = 0,			--信仰
	tent = 0,			--帐篷
	cabin = 0,			--帐篷
	edifice = 0,		--大厦
	foodRep = 0,		--粮仓
	woodRep	= 0,		--木仓
	stoneRep = 0,		--石仓
	cemetery = 0,		--墓地
	maxCemetery = 0,	--墓地可以埋葬的尸体上限
	farmer = 0,			--农民
	woodWorker = 0,		--木工
	stoneWorker = 0,	--石工
	leatherWorker = 0,	--制皮匠
	maxLeatherWorker = 0,--最大制皮匠
	blacksmith = 0,		--铁匠
	maxBlacksmith = 0,	--最大铁匠
	dead = 0,			--尸体
	leatherWorkerRep = 0,	--制皮厂
	blacksmithRep = 0,		--铁匠铺
	barrack = 0,			--兵营
	racecourse = 0,			--马场
	foodSpeed = 0,			--食物采集速度
	woodSpeed = 0,			--木头采集速度
	stoneSpeed = 0,			--石头采集速度
	leatherSpeed = 0,		--皮革生产速度
	metalSpeed = 0,			--金属生产速度
	faithSpeed = 0,			--信仰生产速度
	is_init = false,		--是否第一次玩
	is_food_unlock = false,	--收集食物解锁按钮
	is_wood_unlock = false,	--收集木头解锁按钮
	is_stone_unlock = false,--收集石头解锁按钮
	is_fur_unlock = false,	--兽皮资源解锁标志位
	is_herb_unlock = false,	--草药资源解锁标志位
	is_ore_unlock = false,	--矿石资源解锁标志位
	is_leather_unlock = false,	--皮革资源解锁标志位
	is_faith_unlock = false,	--信仰资源解锁标志位
	is_metal_unlock = false,	--金属资源解锁标志位
	is_speed_unlock = false,	--采集速度解锁
	is_build_unlock = false,--建筑解锁标志位
	is_tech_unlock = false, --科技解锁标志位
	is_people_unlock = false, --人口解锁标志位
	is_deal_unlock = false, --交易解锁标志位

	food_fur_cyc = 0,	--用于生成兽皮的循环计数,如每收集4个食物,生成一个兽皮
	wood_herb_cyc = 0,	--用于生成药材的循环计数,如每收集4个木头,生成一个药材
	stone_ore_cyc = 0,	--用于生成矿石的循环计数,如每收集4个石头,生成一个矿石

	--游戏配置
	config = {
		--帐篷配置
		tent = {
		    opt = {1,10,100,1000},
			need = {
				fur = 2,
				wood = 1,
				},
			effect = {
				maxPeppleAdd = 1;
			}
		},
		--木屋配置
		cabin = {
		    opt = {1,10,100,1000},
			need = {
				fur = 1,
				wood = 20,
				},
			effect = {
				maxPeppleAdd = 3;
			}
		},
		--大厦配置
		edifice = {
		    opt = {1,10,100,1000},
			need = {
				wood = 20,
				stone = 20
				},
			effect = {
				maxPeppleAdd = 10;
			}
		},

		--粮仓配置
		foodRep = {
		    opt = {1,10,100,1000},
			need = {
				wood = 200
				},
			effect = {
				maxFoodAdd = 200;
			}
		},
		--木仓配置
		woodRep = {
		    opt = {1,10,100,1000},
			need = {
				wood = 200
				},
			effect = {
				maxWoodAdd = 200;
			}
		},
		--石仓配置
		stoneRep = {
		    opt = {1,10,100,1000},
			need = {
				wood = 200
				},
			effect = {
				maxStoneAdd = 200;
			}
		},
		--墓地配置
		cemetery = {
		    opt = {1,10,100,1000},
			need = {
				stone = 100
				},
			effect = {
				maxCemeteryAdd = 100;
			}
		},
		--制皮厂配置
		leatherWorkerRep = {
		    opt = {1,10,100,1000},
			need = {
				wood = 100,
				stone = 100
				},
			effect = {
				maxLeatherWorkerAdd = 100;
			}
		},
		--铁匠铺配置
		blacksmithRep = {
		    opt = {1,10,100,1000},
			need = {
				wood = 100,
				stone = 100
				},
			effect = {
				maxBlacksmithAdd = 100;
			}
		},
		--兵营配置
		barrack = {
		    opt = {1,10,100,1000},
			need = {
				wood = 100,
				stone = 100
				},
			effect = {
				maxInfantryAdd = 100;
			}
		},
		--马场配置
		racecourse = {
		    opt = {1,10,100,1000},
			need = {
				wood = 100,
				stone = 100
				},
			effect = {
				maxCavalryAdd = 100;
			}
		},
		--增加人口
		unemploymentPeople = {
			opt = {1,10,100,1000},
			need = {
				food = 10
			}
		},
		farmer = {
			opt = {1,10,100,1000},
			need = {
				unemploymentPeople = 1
			},
			effect = {
				farmer = 1
			}
		},
		woodWorker = {
			opt = {1,10,100,1000},
			need = {
				unemploymentPeople = 1
			},
			effect = {
				woodWorker = 1
			}
		},
		stoneWorker = {
			opt = {1,10,100,1000},
			need = {
				unemploymentPeople = 1
			},
			effect = {
				stoneWorker = 1
			}
		},
		leatherWorker = {
			opt = {1,10,100,1000},
			need = {
				unemploymentPeople = 1
			},
			effect = {
				leatherWorker = 1
			}
		},
		blacksmith = {
			opt = {1,10,100,1000},
			need = {
				unemploymentPeople = 1
			},
			effect = {
				blacksmith = 1
			}
		},
		doctor = {
			opt = {1,10,100,1000},
			need = {
				unemploymentPeople = 1
			},
			effect = {
				doctor = 1
			}
		},
		minister = {
			opt = {1,10,100,1000},
			need = {
				unemploymentPeople = 1
			},
			effect = {
				minister = 1
			}
		},
		infantry = {
			opt = {1,10,100,1000},
			need = {
				unemploymentPeople = 1
			},
			effect = {
				infantry = 1
			}
		},
		cavalry = {
			opt = {1,10,100,1000},
			need = {
				unemploymentPeople = 1
			},
			effect = {
				cavalry = 1
			}
		},
	},
	economy = {
			people = {
				consume={
					food = 1
				},
				produce={
					faith = 0.0001
				}
			},
			farmer = {
				produce={
					food = 1.2
				}
			},
			woodWorker = {
				produce={
					wood = 1
				}
			},
			stoneWorker = {
				produce={
					stone = 1
				}
			},
			leatherWorker = {
				produce={
					leather = 1
				},
				consume={
					fur = 1
				}
			},
			blacksmith = {
				produce={
					metal = 1
				},
				consume={
					ore = 1
				}
			}
		},

	food_unlock_config = {
		food = 0
	},
	wood_unlock_config = {
		food = 3
	},
	stone_unlock_config = {
		food = 5
	},
	fur_unlock_config = {
		food = 4
	},
	herb_unlock_config = {
		wood = 4
	},
	ore_unlock_config = {
		stone = 4
	},
	--建筑解锁
	build_unlock_config = {
		wood = 1,
		fur = 1
	},
	--科技解锁
	tech_unlock_config = {
		people = 5
	},
	--人口解锁
	people_unlock_config = {
		maxPeople = 1
	},
	--皮革解锁
	leather_unlock_config = {
		leatherWorkerRep = 1
	},
	--金属解锁
	metal_unlock_config = {
		blacksmithRep = 1
	},
	--信仰解锁
	faith_unlock_config = {
		minister = 1
	},
	--贸易解锁
	deal_unlock_config = {
		gold = 1
	},

	food_extend = {
		per_food_add_fur = 4	--每收集到多少食物生成一个兽皮
	},

	wood_extend = {
		per_wood_add_herb = 4	--每收集到多少木头生成一个草药
	},

	stone_extend = {
		per_stone_add_ore = 4	--每收集到多少石头生成一个矿石
	}
}


function getNeedLabel(data,i,isReduce)
    local add = data.opt[i]
    local firstSign
    local secondSign
    if not isReduce then 
    	firstSign ="+"
    	secondSign = "-"
    else
    	firstSign ="-"
    	secondSign = "+"
    end
    local needLabel =  firstSign..add.." ("
    if data.need.food then
    	needLabel  = needLabel .. secondSign .. data.need.food * add .. "粮食 "
    	
    end

    if data.need.wood then
       	needLabel  = needLabel .. secondSign .. data.need.wood * add .. "木材 "
    end

    if data.need.stone then
       	needLabel  = needLabel .. secondSign .. data.need.stone * add .. "石头 "
    end

    if data.need.fur then
       	needLabel  = needLabel .. secondSign .. data.need.fur * add .. "毛皮 "
    end

    if data.need.herb then
       	needLabel  = needLabel .. secondSign .. data.need.herb * add .. "草药 "
    end

    if data.need.ore then
       	needLabel  = needLabel .. secondSign .. data.need.ore * add .. "矿石 "
    end

    if data.need.unemploymentPeople then
       	needLabel  = needLabel .. secondSign .. data.need.unemploymentPeople * add .. "失业人口 "
    end

    needLabel  = needLabel .. ")"
	return needLabel
end

function isResourceEnough(data,i,isReduce)
    local add = data.opt[i]
    if not isReduce then
	    if data.need.food and world.food < data.need.food * add then
	       	return false
	    end

	    if data.need.wood and world.wood < data.need.wood * add then
	       	return false
	    end

	    if data.need.stone and world.stone < data.need.stone * add then
	       	return false
	    end

	    if data.need.fur and world.fur < data.need.fur * add then
	       	return false
	    end

	    if data.need.herb and world.herb < data.need.herb * add then
	       	return false
	    end

	    if data.need.ore and world.ore < data.need.ore * add then
	       	return false
	    end
	    if data.need.unemploymentPeople and world.unemploymentPeople < data.need.unemploymentPeople * add then
	       	return false
	    end
	else
		if data.effect.farmer and world.farmer < data.effect.farmer * add then
	       	return false
	    end
	    if data.effect.woodWorker and world.woodWorker < data.effect.woodWorker * add then
	       	return false
	    end
	    if data.effect.stoneWorker and world.stoneWorker < data.effect.stoneWorker * add then
	       	return false
	    end
	    if data.effect.leatherWorker and world.leatherWorker < data.effect.leatherWorker * add then
	       	return false
	    end
	    if data.effect.blacksmith and world.blacksmith < data.effect.blacksmith * add then
	       	return false
	    end
	    if data.effect.doctor and world.doctor < data.effect.doctor * add then
	       	return false
	    end
	    if data.effect.minister and world.minister < data.effect.minister * add then
	       	return false
	    end
	    if data.effect.cavalry and world.cavalry < data.effect.cavalry * add then
	       	return false
	    end
	    if data.effect.infantry and world.infantry < data.effect.infantry * add then
	       	return false
	    end
	end
	return true
end












