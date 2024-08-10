-- PVOX TFA-VOX Compatibility Layer
--
-- This module proxies TFA-VOX related functions
-- and allows you to use them in PVOX :)

print("[TFA-VOX+PVOX] converting modules")

local MDLPRIgnore = {
	["solo"] = true,
	["coop"] = true,
}

local Skips = {
	["snd1"] = true,
	["snd2"] = true,
	["snd3"] = true,
	["snd4"] = true,
	["snd5"] = true,
	["snd6"] = true,
	["snd7"] = true,
	["snd8"] = true,
	["snd9"] = true,
	["snd10"] = true,
}

local MDLAliases = {
	["spawn"] = "pickup_weapon",
	["pickup"] = "pickup_weapon",
	["death"] = "death",
	["noammo"] = "no_ammo",
	["reload"] = "reload",

	["spot"] = "enemy_spotted",

	["HITGROUP"] = "take_damage",

	["ACT_GMOD_TAUNT"] = "inspect",

	["crithit"] = "take_damage",

	["murd"] = "enemy_killed",
}

local ttb = {}

function GetAliasFor(sound_script_id)
	for k, v in pairs(MDLAliases) do
		if sound_script_id == k or string.StartsWith(sound_script_id, k) then return v end
	end
end

function TFAVOX_GenerateSound(mdlprefix, sound_script_id, sndtable)
	-- we mask TFAVOX_GenerateSound to, instead
	-- of do TFA things, put that into yk, stuff

	PVox.Modules[mdlprefix] = {}

	ttb.MDLPrefix = mdlprefix

	local action_name = GetAliasFor(sound_script_id)

	if ! action_name then return end

	ttb["actions"] = ttb["actions"] or {}

	if ! ttb["actions"][action_name] then ttb["actions"][action_name] = {} end

	local soundtable = ttb["actions"][action_name]

	for _, v in pairs(sndtable) do
		if Skips[v] then return end
		table.insert(soundtable, v)
	end
end

function TFAVOX_RegisterPack(mdl, pack)
	if (! isstring(pack)) then return end
	return PVox:RegisterPlayerModel(mdl, pack)
end

for _, f in pairs(file.Find("lua/tfa_vox/packs/*.lua", "GAME")) do
	print("[TPVOX] found a module file " .. f)
	include ("tfa_vox/packs/" .. f)

	if MDLPRIgnore[ttb.MDLPrefix] then
		ttb = {}
		continue
	end

	if ttb.MDLPrefix == nil then return end

	print("adding ", ttb.MDLPrefix)

	PVox:ImplementModule(ttb.MDLPrefix, function () return ttb end)

	ttb = {}
end
