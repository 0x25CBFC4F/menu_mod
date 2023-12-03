require 'features';
require 'table_dumper';

---@type Vector4?
local teleportedFrom = nil;

local vendorEntityHash = 9010641;
local originalVendorRecord = "Vendors.std_arr_foodshop_02";
local newVendorRecord = "Vendors.godvendor";
local quantityRecord = newVendorRecord .. "_inline_quantity";
local teleportPos;
local teleportOrientation;

local lastResetTook = 0;
local lastRefillTook = 0;

local forceItemQuality = false;
local itemQualities = { 
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Epic",
    [4] = "Legendary"
};
local itemQualitiesString = "Common\0Uncommon\0Epic\0Legendary\0";
local currentItemQuality = 0;

---@enum CategoryType
CategoryType = {
    Record = 1,
    Query = 2
}

---@class Category
---@field name string Category definition
---@field type CategoryType Category type
function NewCategory(name, type)
    return {
        name = name,
        type = type
    };
end

---@type table<string, Category>
local itemCategories = {
    ["1.  Ignore this one :)"] = NewCategory("Query.Cap", CategoryType.Query),
    ["2. Clothing: Aldecaldos"] = NewCategory("Query.AldecaldosClothing", CategoryType.Query),
    ["3. Clothing: Aldecaldos (DLC)"] = NewCategory("Query.AldecaldosClothing_EP1", CategoryType.Query),
    ["4. Clothing: Animals"] = NewCategory("Query.AnimalsClothing", CategoryType.Query),
    ["5. Clothing: Animals (DLC)"] = NewCategory("Query.AnimalsClothing_EP1", CategoryType.Query),
    ["6. Clothing: Arasaka"] = NewCategory("Query.ArasakaClothing", CategoryType.Query),
    ["7. Clothing: Arasaka (DLC)"] = NewCategory("Query.ArasakaClothing_EP1", CategoryType.Query),
    ["8. Clothing: Barghest (DLC)"] = NewCategory("Query.BarghestClothing_EP1", CategoryType.Query),
    ["9. Clothing: Biker"] = NewCategory("Query.BikerClothing", CategoryType.Query),
    ["10. Clothing: Biker (DLC)"] = NewCategory("Query.BikerClothing_EP1", CategoryType.Query),
    ["11. Clothing: Biker (No faction)"] = NewCategory("Query.BikerClothingNoFaction", CategoryType.Query),
    ["12. Clothing: Casual"] = NewCategory("Query.CasualClothing", CategoryType.Query),
    ["13. Clothing: Casual (DLC)"] = NewCategory("Query.CasualClothing_EP1", CategoryType.Query),
    ["14. Clothing: Casual (No faction)"] = NewCategory("Query.CasualClothingNoFaction", CategoryType.Query),
    ["15. Clothing: Corpo"] = NewCategory("Query.CorpoClothing", CategoryType.Query),
    ["16. Clothing: Corpo (DLC)"] = NewCategory("Query.CorpoClothing_EP1", CategoryType.Query),
    ["17. Clothing: Corpo (No faction)"] = NewCategory("Query.CorpoClothingNoFaction", CategoryType.Query),
    ["18. Clothing: Corpo Formal"] = NewCategory("Query.CorpoFormalClothing", CategoryType.Query),
    ["19. Clothing: Cowboy"] = NewCategory("Query.CowboyClothing", CategoryType.Query),
    ["20. Clothing: Cowboy (DLC)"] = NewCategory("Query.CowboyClothing_EP1", CategoryType.Query),
    ["21. Clothing: Face"] = NewCategory("Query.FaceClothing", CategoryType.Query),
    ["22. Clothing: Face (DLC)"] = NewCategory("Query.FaceClothingQuery_EP1", CategoryType.Query),
    ["23. Clothing: Formal"] = NewCategory("Query.FormalClothing", CategoryType.Query),
    ["24. Clothing: Formal (DLC)"] = NewCategory("Query.FormalClothing_EP1", CategoryType.Query),
    ["25. Clothing: Formal (No faction)"] = NewCategory("Query.FormalClothingNoFaction", CategoryType.Query),
    ["26. Clothing: General"] = NewCategory("Query.GeneralClothing", CategoryType.Query),
    ["27. Clothing: Industrial"] = NewCategory("Query.IndustrialClothing", CategoryType.Query),
    ["28. Clothing: Industrial (DLC)"] = NewCategory("Query.IndustrialClothing_EP1", CategoryType.Query),
    ["29. Clothing: Industrial (No faction)"] = NewCategory("Query.IndustrialClothingNoFaction", CategoryType.Query),
    ["30. Clothing: Kang Tao"] = NewCategory("Query.KangTaoClothing", CategoryType.Query),
    ["31. Clothing: Kang Tao (DLC)"] = NewCategory("Query.KangTaoClothing_EP1", CategoryType.Query),
    ["32. Clothing: Maelstrom"] = NewCategory("Query.MaelstromClothing", CategoryType.Query),
    ["33. Clothing: Maelstrom (DLC)"] = NewCategory("Query.MaelstromClothing_EP1", CategoryType.Query),
    ["34. Clothing: Maelstrom Punk"] = NewCategory("Query.MaelstromPunkClothing", CategoryType.Query),
    ["35. Clothing: Military"] = NewCategory("Query.MilitaryClothing", CategoryType.Query),
    ["36. Clothing: Military (DLC)"] = NewCategory("Query.MilitaryClothing_EP1", CategoryType.Query),
    ["37. Clothing: Military (No faction)"] = NewCategory("Query.MilitaryClothingNoFaction", CategoryType.Query),
    ["38. Clothing: Militech"] = NewCategory("Query.MilitechClothing", CategoryType.Query),
    ["39. Clothing: Militech (DLC)"] = NewCategory("Query.MilitechClothing_EP1", CategoryType.Query),
    ["40. Clothing: Moxies"] = NewCategory("Query.MoxiesClothing", CategoryType.Query),
    ["41. Clothing: Moxies (DLC)"] = NewCategory("Query.MoxiesClothing_EP1", CategoryType.Query),
    ["42. Clothing: Moxies Face"] = NewCategory("Query.MoxiesFaceClothing", CategoryType.Query),
    ["43. Clothing: Moxies Feet"] = NewCategory("Query.MoxiesFeetClothing", CategoryType.Query),
    ["44. Clothing: Moxies Head"] = NewCategory("Query.MoxiesHeadClothing", CategoryType.Query),
    ["45. Clothing: NCPD"] = NewCategory("Query.NCPDClothing", CategoryType.Query),
    ["46. Clothing: NCPD (DLC)"] = NewCategory("Query.NCPDClothing_EP1", CategoryType.Query),
    ["47. Clothing: Poor"] = NewCategory("Query.PoorClothing", CategoryType.Query),
    ["48. Clothing: Poor (DLC)"] = NewCategory("Query.PoorClothing_EP1", CategoryType.Query),
    ["49. Clothing: Poor (No faction)"] = NewCategory("Query.PoorClothingNoFaction", CategoryType.Query),
    ["50. Clothing: Punk"] = NewCategory("Query.PunkClothing", CategoryType.Query),
    ["51. Clothing: Punk (DLC)"] = NewCategory("Query.PunkClothing_EP1", CategoryType.Query),
    ["52. Clothing: Punk (No faction)"] = NewCategory("Query.PunkClothingNoFaction", CategoryType.Query),
    ["53. Clothing: Rich"] = NewCategory("Query.RichClothing", CategoryType.Query),
    ["54. Clothing: Rich (DLC)"] = NewCategory("Query.RichClothing_EP1", CategoryType.Query),
    ["55. Clothing: Rich (No faction)"] = NewCategory("Query.RichClothingNoFaction", CategoryType.Query),
    ["56. Clothing: Rocker"] = NewCategory("Query.RockerClothing", CategoryType.Query),
    ["57. Clothing: Rocker (DLC)"] = NewCategory("Query.RockerClothing_EP1", CategoryType.Query),
    ["58. Clothing: Scavengers"] = NewCategory("Query.ScavengersClothing", CategoryType.Query),
    ["59. Clothing: Scavengers (DLC)"] = NewCategory("Query.ScavengersClothing_EP1", CategoryType.Query),
    ["60. Clothing: Simple"] = NewCategory("Query.SimpleClothing", CategoryType.Query),
    ["61. Clothing: Simple (DLC)"] = NewCategory("Query.SimpleClothing_EP1", CategoryType.Query),
    ["62. Clothing: Sixth Street"] = NewCategory("Query.SixthStreetClothing", CategoryType.Query),
    ["63. Clothing: Sixth Street (DLC)"] = NewCategory("Query.SixthStreetClothing_EP1", CategoryType.Query),
    ["64. Clothing: Sports"] = NewCategory("Query.SportsClothing", CategoryType.Query),
    ["65. Clothing: Sports (DLC)"] = NewCategory("Query.SportsClothing_EP1", CategoryType.Query),
    ["66. Clothing: Sports (No faction)"] = NewCategory("Query.SportsClothingNoFaction", CategoryType.Query),
    ["67. Clothing: Streetwear"] = NewCategory("Query.StreetwearClothing", CategoryType.Query),
    ["68. Clothing: Streetwear (DLC)"] = NewCategory("Query.StreetwearClothing_EP1", CategoryType.Query),
    ["69. Clothing: Stylish"] = NewCategory("Query.StylishClothing", CategoryType.Query),
    ["70. Clothing: Stylish (DLC)"] = NewCategory("Query.StylishClothing_EP1", CategoryType.Query),
    ["71. Clothing: Stylish (No faction)"] = NewCategory("Query.StylishClothingNoFaction", CategoryType.Query),
    ["72. Clothing: Tomboy"] = NewCategory("Query.TomboyClothing", CategoryType.Query),
    ["73. Clothing: Tomboy (DLC)"] = NewCategory("Query.TomboyClothing_EP1", CategoryType.Query),
    ["74. Clothing: Tyger Claws"] = NewCategory("Query.TygerClawsClothing", CategoryType.Query),
    ["75. Clothing: Tyger Claws (DLC)"] = NewCategory("Query.TygerClawsClothing_EP1", CategoryType.Query),
    ["76. Clothing: Tyger Claws Biker"] = NewCategory("Query.TygerClawsBikerClothing", CategoryType.Query),
    ["77. Clothing: Valentinos"] = NewCategory("Query.ValentinosClothing", CategoryType.Query),
    ["78. Clothing: Valentinos (DLC)"] = NewCategory("Query.ValentinosClothing_EP1", CategoryType.Query),
    ["79. Clothing: Voodoo Boys"] = NewCategory("Query.VoodooBoysClothing", CategoryType.Query),
    ["80. Clothing: Voodoo Boys (DLC)"] = NewCategory("Query.VoodooBoysClothing_EP1", CategoryType.Query),
    ["81. Clothing: Wraiths"] = NewCategory("Query.WraithsClothing", CategoryType.Query),
    ["82. Clothing: Wraiths (DLC)"] = NewCategory("Query.WraithsClothing_EP1", CategoryType.Query),
    ["83. Accessories: Animals Jewellery"] = NewCategory("Query.AnimalsJewellery", CategoryType.Query),
    ["84. Accessories: High Quality Jewellery"] = NewCategory("Query.HighQualityJewellery", CategoryType.Query),
    ["85. Accessories: Jewellery"] = NewCategory("Query.Jewellery", CategoryType.Query),
    ["86. Accessories: Low Quality Jewellery"] = NewCategory("Query.LowQualityJewellery", CategoryType.Query),
    ["87. Accessories: Medium Quality Jewellery"] = NewCategory("Query.MediumQualityJewellery", CategoryType.Query),
    ["88. Accessories: Tyger Claws Jewellery"] = NewCategory("Query.TygerClawsJewellery", CategoryType.Query),
    ["89. Accessories: Valentinos Jewellery"] = NewCategory("Query.ValentinosJewellery", CategoryType.Query),
    ["90. Attachments: Air Drop Attachments Tier 1 to 2"] = NewCategory("Query.AirDrop_Attachments_Tier_1_to_2", CategoryType.Query),
    ["91. Attachments: Air Drop Attachments Tier 1 to 3"] = NewCategory("Query.AirDrop_Attachments_Tier_1_to_3", CategoryType.Query),
    ["92. Attachments: Air Drop Attachments Tier 1 to 4"] = NewCategory("Query.AirDrop_Attachments_Tier_1_to_4", CategoryType.Query),
    ["93. Attachments: All Attachments Tier 1 to 2"] = NewCategory("Query.All_Attachments_Tier_1_to_2", CategoryType.Query),
    ["94. Attachments: All Attachments Tier 1 to 3"] = NewCategory("Query.All_Attachments_Tier_1_to_3", CategoryType.Query),
    ["95. Attachments: All Attachments Tier 1 to 4"] = NewCategory("Query.All_Attachments_Tier_1_to_4", CategoryType.Query),
    ["96. Attachments: All Attachments Tier 5"] = NewCategory("Query.All_Attachments_Tier_5", CategoryType.Query),
    ["97. Attachments: All Power Modules Tier 1 to 2"] = NewCategory("Query.AllPowerModules_Tier_1_to_2", CategoryType.Query),
    ["98. Attachments: All Power Modules Tier 1 to 3"] = NewCategory("Query.AllPowerModules_Tier_1_to_3", CategoryType.Query),
    ["99. Attachments: All Power Modules Tier 1 to 4"] = NewCategory("Query.AllPowerModules_Tier_1_to_4", CategoryType.Query),
    ["100. Attachments: All Scopes Tier 1 to 2"] = NewCategory("Query.AllScopes_Tier_1_to_2", CategoryType.Query),
    ["101. Attachments: All Scopes Tier 1 to 3"] = NewCategory("Query.AllScopes_Tier_1_to_3", CategoryType.Query),
    ["102. Attachments: All Scopes Tier 1 to 4"] = NewCategory("Query.AllScopes_Tier_1_to_4", CategoryType.Query),
    ["103. Attachments: Courier Attachments Tier 1 to 2"] = NewCategory("Query.Courier_Attachments_Tier_1_to_2", CategoryType.Query),
    ["104. Attachments: Courier Attachments Tier 1 to 3"] = NewCategory("Query.Courier_Attachments_Tier_1_to_3", CategoryType.Query),
    ["105. Attachments: Courier Attachments Tier 1 to 4"] = NewCategory("Query.Courier_Attachments_Tier_1_to_4", CategoryType.Query),
    ["106. Attachments: Courier Attachments Tier 5"] = NewCategory("Query.Courier_Attachments_Tier_5", CategoryType.Query),
    ["107. Attachments: Early Game Weapon Mods"] = NewCategory("Query.EarlyGameWeaponMods", CategoryType.Query),
    ["108. Attachments: Early Game Weapon Scopes"] = NewCategory("Query.EarlyGameWeaponScopes", CategoryType.Query),
    ["109. Attachments: Early Game Weapon Silencers"] = NewCategory("Query.EarlyGameWeaponSilencers", CategoryType.Query),
    ["110. Attachments: End Game Weapon Mods"] = NewCategory("Query.EndGameWeaponMods", CategoryType.Query),
    ["111. Attachments: End Game Weapon Scopes"] = NewCategory("Query.EndGameWeaponScopes", CategoryType.Query),
    ["112. Attachments: End Game Weapon Silencers"] = NewCategory("Query.EndGameWeaponSilencers", CategoryType.Query),
    ["113. Attachments: Handgun Muzzle Tier 1 to 2"] = NewCategory("Query.Handgun_Muzzle_Tier_1_to_2", CategoryType.Query),
    ["114. Attachments: Handgun Muzzle Tier 1 to 3"] = NewCategory("Query.Handgun_Muzzle_Tier_1_to_3", CategoryType.Query),
    ["115. Attachments: Handgun Muzzle Tier 1 to 4"] = NewCategory("Query.Handgun_Muzzle_Tier_1_to_4", CategoryType.Query),
    ["116. Attachments: Long Scopes Tier 1 to 2"] = NewCategory("Query.LongScopes_Tier_1_to_2", CategoryType.Query),
    ["117. Attachments: Long Scopes Tier 1 to 3"] = NewCategory("Query.LongScopes_Tier_1_to_3", CategoryType.Query),
    ["118. Attachments: Long Scopes Tier 1 to 4"] = NewCategory("Query.LongScopes_Tier_1_to_4", CategoryType.Query),
    ["119. Attachments: Mid Game Weapon Mods"] = NewCategory("Query.MidGameWeaponMods", CategoryType.Query),
    ["120. Attachments: Mid Game Weapon Scopes"] = NewCategory("Query.MidGameWeaponScopes", CategoryType.Query),
    ["121. Attachments: Mid Game Weapon Silencers"] = NewCategory("Query.MidGameWeaponSilencers", CategoryType.Query),
    ["122. Attachments: Muzzle Brake Tier 1 to 2"] = NewCategory("Query.Muzzle_Brake_Tier_1_to_2", CategoryType.Query),
    ["123. Attachments: Muzzle Brake Tier 1 to 3"] = NewCategory("Query.Muzzle_Brake_Tier_1_to_3", CategoryType.Query),
    ["124. Attachments: Muzzle Brake Tier 1 to 4"] = NewCategory("Query.Muzzle_Brake_Tier_1_to_4", CategoryType.Query),
    ["125. Attachments: Rifle SMG Muzzle Tier 1 to 2"] = NewCategory("Query.Rifle_SMG_Muzzle_Tier_1_to_2", CategoryType.Query),
    ["126. Attachments: Rifle SMG Muzzle Tier 1 to 3"] = NewCategory("Query.Rifle_SMG_Muzzle_Tier_1_to_3", CategoryType.Query),
    ["127. Attachments: Rifle SMG Muzzle Tier 1 to 4"] = NewCategory("Query.Rifle_SMG_Muzzle_Tier_1_to_4", CategoryType.Query),
    ["128. Attachments: Sales DLC Silencers"] = NewCategory("Query.SalesDLC_SilencersQuery", CategoryType.Query),
    ["129. Attachments: Short Or Long Scopes Tier 1 to 2"] = NewCategory("Query.ShortOrLongScopes_Tier_1_to_2", CategoryType.Query),
    ["130. Attachments: Short Or Long Scopes Tier 1 to 3"] = NewCategory("Query.ShortOrLongScopes_Tier_1_to_3", CategoryType.Query),
    ["131. Attachments: Short Or Long Scopes Tier 1 to 4"] = NewCategory("Query.ShortOrLongScopes_Tier_1_to_4", CategoryType.Query),
    ["132. Attachments: Short Scopes Tier 1 to 2"] = NewCategory("Query.ShortScopes_Tier_1_to_2", CategoryType.Query),
    ["133. Attachments: Short Scopes Tier 1 to 3"] = NewCategory("Query.ShortScopes_Tier_1_to_3", CategoryType.Query),
    ["134. Attachments: Short Scopes Tier 1 to 4"] = NewCategory("Query.ShortScopes_Tier_1_to_4", CategoryType.Query),
    ["135. Attachments: Silencers Tiers 1 to 2"] = NewCategory("Query.Silencers_Tiers_1_to_2", CategoryType.Query),
    ["136. Attachments: Silencers Tiers 1 to 3"] = NewCategory("Query.Silencers_Tiers_1_to_3", CategoryType.Query),
    ["137. Attachments: Silencers Tiers 1 to 4"] = NewCategory("Query.Silencers_Tiers_1_to_4", CategoryType.Query),
    ["138. Attachments: Sniper Scopes Tier 1 to 2"] = NewCategory("Query.SniperScopes_Tier_1_to_2", CategoryType.Query),
    ["139. Attachments: Sniper Scopes Tier 1 to 3"] = NewCategory("Query.SniperScopes_Tier_1_to_3", CategoryType.Query),
    ["140. Attachments: Sniper Scopes Tier 1 to 4"] = NewCategory("Query.SniperScopes_Tier_1_to_4", CategoryType.Query),
    ["141. Junk: Animals Junk"] = NewCategory("Query.AnimalsJunk", CategoryType.Query),
    ["142. Junk: Corporation Junk"] = NewCategory("Query.CorporationJunkQuery", CategoryType.Query),
    ["143. Junk: Creepy Follower Junk"] = NewCategory("Query.CreepyFollower_JunkQuery", CategoryType.Query),
    ["144. Junk: Junk"] = NewCategory("Query.JunkQuery", CategoryType.Query),
    ["145. Junk: Large Junk"] = NewCategory("Query.LargeJunkQuery", CategoryType.Query),
    ["146. Junk: Lots Of Junk"] = NewCategory("Query.LotsOfJunk", CategoryType.Query),
    ["147. Junk: Maelstrom Junk"] = NewCategory("Query.MaelstromJunk", CategoryType.Query),
    ["148. Junk: Medium Junk"] = NewCategory("Query.MediumJunkQuery", CategoryType.Query),
    ["149. Junk: Moxies Junk"] = NewCategory("Query.MoxiesJunk", CategoryType.Query),
    ["150. Junk: No Faction Junk"] = NewCategory("Query.NoFactionJunkQuery", CategoryType.Query),
    ["151. Junk: Scavengers Junk"] = NewCategory("Query.ScavengersJunk", CategoryType.Query),
    ["152. Junk: Sixth Street Junk"] = NewCategory("Query.SixthStreetJunk", CategoryType.Query),
    ["153. Junk: Small Junk"] = NewCategory("Query.SmallJunkQuery", CategoryType.Query),
    ["154. Junk: Tyger Claws Junk"] = NewCategory("Query.TygerClawsJunk", CategoryType.Query),
    ["155. Junk: Valentinos Junk"] = NewCategory("Query.ValentinosJunk", CategoryType.Query),
    ["156. Junk: Voodoo Boys Junk"] = NewCategory("Query.VoodooBoysJunk", CategoryType.Query),
    ["157. Junk: Wraiths Junk"] = NewCategory("Query.WraithsJunk", CategoryType.Query),
    ["158. Treasures:  Attachments Tier 3"] = NewCategory("Query.Treasure_Attachments_Tier_3", CategoryType.Query),
    ["159. Treasures:  Attachments Tier 4"] = NewCategory("Query.Treasure_Attachments_Tier_4", CategoryType.Query),
    ["160. Treasures:  Iconic OSCW "] = NewCategory("Query.Treasure_Iconic_OS_CW_Query", CategoryType.Query),
    ["161. Treasures:  Iconic OSCW Apogee And Berserk Owned"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Apogee_And_Berserk_Owned", CategoryType.Query),
    ["162. Treasures:  Iconic OSCW Apogee And Falcon Owned"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Apogee_And_Falcon_Owned", CategoryType.Query),
    ["163. Treasures:  Iconic OSCW Apogee And Netdriver Owned"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Apogee_And_Netdriver_Owned", CategoryType.Query),
    ["164. Treasures:  Iconic OSCW Apogee Missing"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Apogee_Missing", CategoryType.Query),
    ["165. Treasures:  Iconic OSCW Apogee Owned"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Apogee_Owned", CategoryType.Query),
    ["166. Treasures:  Iconic OSCW Berserk And Netdriver Owned"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Berserk_And_Netdriver_Owned", CategoryType.Query),
    ["167. Treasures:  Iconic OSCW Berserk Missing"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Berserk_Missing", CategoryType.Query),
    ["168. Treasures:  Iconic OSCW Berserk Owned"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Berserk_Owned", CategoryType.Query),
    ["169. Treasures:  Iconic OSCW Falcon And Berserk Owned"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Falcon_And_Berserk_Owned", CategoryType.Query),
    ["170. Treasures:  Iconic OSCW Falcon And Netdriver Owned"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Falcon_And_Netdriver_Owned", CategoryType.Query),
    ["171. Treasures:  Iconic OSCW Falcon Missing"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Falcon_Missing", CategoryType.Query),
    ["172. Treasures:  Iconic OSCW Falcon Owned"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Falcon_Owned", CategoryType.Query),
    ["173. Treasures:  Iconic OSCW Netdriver Missing"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Netdriver_Missing", CategoryType.Query),
    ["174. Treasures:  Iconic OSCW Netdriver Owned"] = NewCategory("Query.Treasure_Iconic_OS_CW_Query_Netdriver_Owned", CategoryType.Query),
    ["175. Treasures: Cyberware"] = NewCategory("Query.TreasureCyberwareQuery", CategoryType.Query),
    ["176. Treasures: Tier 1 Cyberware"] = NewCategory("Query.Tier1_TreasureCyberwareQuery", CategoryType.Query),
    ["177. Treasures: Tier 2 Cyberware"] = NewCategory("Query.Tier2_TreasureCyberwareQuery", CategoryType.Query),
    ["178. Treasures: Tier 3 Cyberware"] = NewCategory("Query.Tier3_TreasureCyberwareQuery", CategoryType.Query),
    ["179. Treasures: Tier 4 Cyberware"] = NewCategory("Query.Tier4_TreasureCyberwareQuery", CategoryType.Query),
    ["180. Treasures: Tier 5 Cyberware"] = NewCategory("Query.Tier5_TreasureCyberwareQuery", CategoryType.Query),
    ["181. Treasures: Weapons Tier 3 "] = NewCategory("Query.TreasureWeapons_Tier3_Query", CategoryType.Query),
    ["182. Ammo: Handgun Ammo"] = NewCategory("Query.HandgunAmmo", CategoryType.Query),
    ["183. Ammo: Rifle Ammo"] = NewCategory("Query.RifleAmmo", CategoryType.Query),
    ["184. Ammo: Shotgun Ammo"] = NewCategory("Query.ShotgunAmmo", CategoryType.Query),
    ["185. Ammo: Sniper Ammo"] = NewCategory("Query.SniperAmmo", CategoryType.Query),
    ["186. Recipes: Common Base Handgun"] = NewCategory("Query.CommonBaseHandgunRecipeQuery", CategoryType.Query),
    ["187. Recipes: Common Base Revolver"] = NewCategory("Query.CommonBaseRevolverRecipeQuery", CategoryType.Query),
    ["188. Recipes: Common Base Rifle"] = NewCategory("Query.CommonBaseRifleRecipeQuery", CategoryType.Query),
    ["189. Recipes: Common Base Shotgun"] = NewCategory("Query.CommonBaseShotgunRecipeQuery", CategoryType.Query),
    ["190. Recipes: Common Base SMG"] = NewCategory("Query.CommonBaseSMGRecipeQuery", CategoryType.Query),
    ["191. Recipes: Common Base Sniper"] = NewCategory("Query.CommonBaseSniperRecipeQuery", CategoryType.Query),
    ["192. Recipes: Common Melee Weapon"] = NewCategory("Query.CommonMeleeWeaponRecipeQuery", CategoryType.Query),
    ["193. Recipes: Common Ranged Weapon"] = NewCategory("Query.CommonRangedWeaponRecipeQuery", CategoryType.Query),
    ["194. Recipes: Common Weapon"] = NewCategory("Query.CommonWeaponRecipeQuery", CategoryType.Query),
    ["195. Recipes: Epic Base Handgun"] = NewCategory("Query.EpicBaseHandgunRecipeQuery", CategoryType.Query),
    ["196. Recipes: Epic Base Revolver"] = NewCategory("Query.EpicBaseRevolverRecipeQuery", CategoryType.Query),
    ["197. Recipes: Epic Base Rifle"] = NewCategory("Query.EpicBaseRifleRecipeQuery", CategoryType.Query),
    ["198. Recipes: Epic Base Shotgun"] = NewCategory("Query.EpicBaseShotgunRecipeQuery", CategoryType.Query),
    ["199. Recipes: Epic Base SMG"] = NewCategory("Query.EpicBaseSMGRecipeQuery", CategoryType.Query),
    ["200. Recipes: Epic Base SMG (PL)"] = NewCategory("Query.EpicBaseSMGRecipeQuery_EP1", CategoryType.Query),
    ["201. Recipes: Epic Base Sniper"] = NewCategory("Query.EpicBaseSniperRecipeQuery", CategoryType.Query),
    ["202. Recipes: Epic Melee Weapon"] = NewCategory("Query.EpicMeleeWeaponRecipeQuery", CategoryType.Query),
    ["203. Recipes: Epic Quickhack"] = NewCategory("Query.EpicQuickhackRecipeQuery", CategoryType.Query),
    ["204. Recipes: Epic Ranged Weapon"] = NewCategory("Query.EpicRangedWeaponRecipeQuery", CategoryType.Query),
    ["205. Recipes: Epic Weapon"] = NewCategory("Query.EpicWeaponRecipeQuery", CategoryType.Query),
    ["206. Recipes: Epic Weapon (PL)"] = NewCategory("Query.EpicWeaponRecipeQuery_EP1", CategoryType.Query),
    ["207. Recipes: Grenade"] = NewCategory("Query.RecipeGrenadeQuery", CategoryType.Query),
    ["208. Recipes: Legendary Base Handgun"] = NewCategory("Query.LegendaryBaseHandgunRecipeQuery", CategoryType.Query),
    ["209. Recipes: Legendary Base Revolver"] = NewCategory("Query.LegendaryBaseRevolverRecipeQuery", CategoryType.Query),
    ["210. Recipes: Legendary Base Rifle"] = NewCategory("Query.LegendaryBaseRifleRecipeQuery", CategoryType.Query),
    ["211. Recipes: Legendary Base Shotgun"] = NewCategory("Query.LegendaryBaseShotgunRecipeQuery", CategoryType.Query),
    ["212. Recipes: Legendary Base SMG"] = NewCategory("Query.LegendaryBaseSMGRecipeQuery", CategoryType.Query),
    ["213. Recipes: Legendary Base SMG (PL)"] = NewCategory("Query.LegendaryBaseSMGRecipeQuery_EP1", CategoryType.Query),
    ["214. Recipes: Legendary Base Sniper"] = NewCategory("Query.LegendaryBaseSniperRecipeQuery", CategoryType.Query),
    ["215. Recipes: Legendary Melee Weapon"] = NewCategory("Query.LegendaryMeleeWeaponRecipeQuery", CategoryType.Query),
    ["216. Recipes: Legendary Quickhack"] = NewCategory("Query.LegendaryQuickhackRecipeQuery", CategoryType.Query),
    ["217. Recipes: Legendary Ranged Weapon"] = NewCategory("Query.LegendaryRangedWeaponRecipeQuery", CategoryType.Query),
    ["218. Recipes: Legendary Weapon"] = NewCategory("Query.LegendaryWeaponRecipeQuery", CategoryType.Query),
    ["219. Recipes: Legendary Weapon (PL)"] = NewCategory("Query.LegendaryWeaponRecipeQuery_EP1", CategoryType.Query),
    ["220. Recipes: Rare Base Handgun"] = NewCategory("Query.RareBaseHandgunRecipeQuery", CategoryType.Query),
    ["221. Recipes: Rare Base Revolver"] = NewCategory("Query.RareBaseRevolverRecipeQuery", CategoryType.Query),
    ["222. Recipes: Rare Base Rifle"] = NewCategory("Query.RareBaseRifleRecipeQuery", CategoryType.Query),
    ["223. Recipes: Rare Base Shotgun"] = NewCategory("Query.RareBaseShotgunRecipeQuery", CategoryType.Query),
    ["224. Recipes: Rare Base SMG"] = NewCategory("Query.RareBaseSMGRecipeQuery", CategoryType.Query),
    ["225. Recipes: Rare Base SMG (PL)"] = NewCategory("Query.RareBaseSMGRecipeQuery_EP1", CategoryType.Query),
    ["226. Recipes: Rare Base Sniper"] = NewCategory("Query.RareBaseSniperRecipeQuery", CategoryType.Query),
    ["227. Recipes: Rare Melee Weapon"] = NewCategory("Query.RareMeleeWeaponRecipeQuery", CategoryType.Query),
    ["228. Recipes: Rare Quickhack"] = NewCategory("Query.RareQuickhackRecipeQuery", CategoryType.Query),
    ["229. Recipes: Rare Ranged Weapon"] = NewCategory("Query.RareRangedWeaponRecipeQuery", CategoryType.Query),
    ["230. Recipes: Rare Weapon"] = NewCategory("Query.RareWeaponRecipeQuery", CategoryType.Query),
    ["231. Recipes: Rare Weapon (PL)"] = NewCategory("Query.RareWeaponRecipeQuery_EP1", CategoryType.Query),
    ["232. Recipes: Uncommon Base Handgun"] = NewCategory("Query.UncommonBaseHandgunRecipeQuery", CategoryType.Query),
    ["233. Recipes: Uncommon Base Revolver"] = NewCategory("Query.UncommonBaseRevolverRecipeQuery", CategoryType.Query),
    ["234. Recipes: Uncommon Base Rifle"] = NewCategory("Query.UncommonBaseRifleRecipeQuery", CategoryType.Query),
    ["235. Recipes: Uncommon Base Shotgun"] = NewCategory("Query.UncommonBaseShotgunRecipeQuery", CategoryType.Query),
    ["236. Recipes: Uncommon Base SMG"] = NewCategory("Query.UncommonBaseSMGRecipeQuery", CategoryType.Query),
    ["237. Recipes: Uncommon Base Sniper"] = NewCategory("Query.UncommonBaseSniperRecipeQuery", CategoryType.Query),
    ["238. Recipes: Uncommon Melee Weapon"] = NewCategory("Query.UncommonMeleeWeaponRecipeQuery", CategoryType.Query),
    ["239. Recipes: Uncommon Quickhack"] = NewCategory("Query.UncommonQuickhackRecipeQuery", CategoryType.Query),
    ["240. Recipes: Uncommon Ranged Weapon"] = NewCategory("Query.UncommonRangedWeaponRecipeQuery", CategoryType.Query),
    ["241. Recipes: Uncommon Weapon"] = NewCategory("Query.UncommonWeaponRecipeQuery", CategoryType.Query),
    ["242. Software shards: Tier 0"] = NewCategory("Query.Tier0SoftwareShard", CategoryType.Query),
    ["243. Software shards: Tier 1"] = NewCategory("Query.Tier1SoftwareShard", CategoryType.Query),
    ["244. Software shards: Tier 2"] = NewCategory("Query.Tier2SoftwareShard", CategoryType.Query),
    ["245. Software shards: Tier 3"] = NewCategory("Query.Tier3SoftwareShard", CategoryType.Query),
    ["246. Software shards: Tier 4"] = NewCategory("Query.Tier4SoftwareShard", CategoryType.Query),
    ["247. Materials: Common"] = NewCategory("Query.CommonMaterialQuery", CategoryType.Query),
    ["248. Materials: Epic"] = NewCategory("Query.EpicMaterialQuery", CategoryType.Query),
    ["249. Materials: Legendary"] = NewCategory("Query.LegendaryMaterialQuery", CategoryType.Query),
    ["250. Materials: Quick Hack"] = NewCategory("Query.QuickHackMaterial", CategoryType.Query),
    ["251. Materials: Quick Hack Epic"] = NewCategory("Query.QuickHackEpicMaterial", CategoryType.Query),
    ["252. Materials: Quick Hack Legendary"] = NewCategory("Query.QuickHackLegendaryMaterial", CategoryType.Query),
    ["253. Materials: Quick Hack Rare"] = NewCategory("Query.QuickHackRareMaterial", CategoryType.Query),
    ["254. Materials: Quick Hack Uncommon"] = NewCategory("Query.QuickHackUncommonMaterial", CategoryType.Query),
    ["255. Materials: Rare"] = NewCategory("Query.RareMaterialQuery", CategoryType.Query),
    ["256. Materials: Uncommon"] = NewCategory("Query.UnommonMaterialQuery", CategoryType.Query),
    ["257. Mods: Blade"] = NewCategory("Query.BladeModsQuery", CategoryType.Query),
    ["258. Mods: Blunt"] = NewCategory("Query.BluntModsQuery", CategoryType.Query),
    ["259. Mods: Common Melee Weapon"] = NewCategory("Query.CommonMeleeWeaponModsQuery", CategoryType.Query),
    ["260. Mods: Common Ranged Weapon"] = NewCategory("Query.CommonRangedWeaponModsQuery", CategoryType.Query),
    ["261. Mods: Common Smart Weapon"] = NewCategory("Query.CommonSmartWeaponModsQuery", CategoryType.Query),
    ["262. Mods: Common Weapon"] = NewCategory("Query.CommonWeaponModsQuery", CategoryType.Query),
    ["263. Mods: Early Game Weapon"] = NewCategory("Query.EarlyGameWeaponMods", CategoryType.Query),
    ["264. Mods: End Game Weapon"] = NewCategory("Query.EndGameWeaponMods", CategoryType.Query),
    ["265. Mods: Generic"] = NewCategory("Query.GenericModsQuery", CategoryType.Query),
    ["266. Mods: Generic Melee"] = NewCategory("Query.GenericMeleeModsQuery", CategoryType.Query),
    ["267. Mods: Generic Ranged"] = NewCategory("Query.GenericRangedModsQuery", CategoryType.Query),
    ["268. Mods: Handgun"] = NewCategory("Query.HandgunModsQuery", CategoryType.Query),
    ["269. Mods: Mid Game Weapon"] = NewCategory("Query.MidGameWeaponMods", CategoryType.Query),
    ["270. Mods: Power"] = NewCategory("Query.PowerModsQuery", CategoryType.Query),
    ["271. Mods: Precision Sniper Rifle"] = NewCategory("Query.PrecisionSniperRifleModsQuery", CategoryType.Query),
    ["272. Mods: Rare Generic Ranged Weapon"] = NewCategory("Query.RareGenericRangedWeaponModsQuery", CategoryType.Query),
    ["273. Mods: Rare Melee Weapon"] = NewCategory("Query.RareMeleeWeaponModsQuery", CategoryType.Query),
    ["274. Mods: Rare Ranged Weapon"] = NewCategory("Query.RareRangedWeaponModsQuery", CategoryType.Query),
    ["275. Mods: Rare Shotgun"] = NewCategory("Query.RareShotgunModsQuery", CategoryType.Query),
    ["276. Mods: Rare Smart Weapon"] = NewCategory("Query.RareSmartWeaponModsQuery", CategoryType.Query),
    ["277. Mods: Rare Weapon"] = NewCategory("Query.RareWeaponModsQuery", CategoryType.Query),
    ["278. Mods: Rifle"] = NewCategory("Query.RifleModsQuery", CategoryType.Query),
    ["279. Mods: Shotgun"] = NewCategory("Query.ShotgunModsQuery", CategoryType.Query),
    ["280. Mods: Smart"] = NewCategory("Query.SmartModsQuery", CategoryType.Query),
    ["281. Mods: Tech"] = NewCategory("Query.TechModsQuery", CategoryType.Query),
    ["282. Mods: Throwable"] = NewCategory("Query.ThrowableModsQuery", CategoryType.Query),
    ["283. Mods: Uncommon Melee Weapon"] = NewCategory("Query.UncommonMeleeWeaponModsQuery", CategoryType.Query),
    ["284. Mods: Uncommon Ranged Weapon"] = NewCategory("Query.UncommonRangedWeaponModsQuery", CategoryType.Query),
    ["285. Mods: Uncommon Smart Weapon"] = NewCategory("Query.UncommonSmartWeaponModsQuery", CategoryType.Query),
    ["286. Mods: Uncommon Weapon"] = NewCategory("Query.UncommonWeaponModsQuery", CategoryType.Query),
    ["287. Mods: Weapon"] = NewCategory("Query.WeaponModsQuery", CategoryType.Query),
    ["288. Weapons: Handgun"] = NewCategory("Query.HandgunQuery", CategoryType.Query),
    ["289. Weapons: Katana"] = NewCategory("Query.KatanaQuery", CategoryType.Query),
    ["290. Weapons: Lightmachinegun"] = NewCategory("Query.LightmachinegunQuery", CategoryType.Query),
    ["291. Weapons: Precision Rifle"] = NewCategory("Query.PrecisionRifleQuery", CategoryType.Query),
    ["292. Weapons: Revolver"] = NewCategory("Query.RevolverQuery", CategoryType.Query),
    ["293. Weapons: Shotgun"] = NewCategory("Query.ShotgunQuery", CategoryType.Query),
    ["294. Weapons: Shotgun Dual"] = NewCategory("Query.ShotgunDualQuery", CategoryType.Query),
    ["295. Weapons: Submachinegun"] = NewCategory("Query.SubmachinegunQuery", CategoryType.Query),
    ["296. Cyberware: Cyberware Next Tier"] = NewCategory("Query.CyberwareNextTierArrayQuery", CategoryType.Query),
    ["297. Cyberware: Cyberware Plus"] = NewCategory("Query.CyberwarePlusArrayQuery", CategoryType.Query),
    ["298. Quickhacks: Common Quickhack"] = NewCategory("Query.CommonQuickhackQuery", CategoryType.Query),
    ["299. Quickhacks: Epic Quickhack"] = NewCategory("Query.EpicQuickhackQuery", CategoryType.Query),
    ["300. Quickhacks: Legendary Quickhack"] = NewCategory("Query.LegendaryQuickhackQuery", CategoryType.Query),
    ["301. Quickhacks: Rare Quickhack"] = NewCategory("Query.RareQuickhackQuery", CategoryType.Query),
    ["302. Quickhacks: Uncommon Quickhack"] = NewCategory("Query.UncommonQuickhackQuery", CategoryType.Query),
    ["303. Scavengers: Clothing"] = NewCategory("Query.ScavengersClothing", CategoryType.Query),
    ["304. Scavengers: Clothing (PL)"] = NewCategory("Query.ScavengersClothing_EP1", CategoryType.Query),
    ["305. Scavengers: Face"] = NewCategory("Query.ScavengersFace", CategoryType.Query),
    ["306. Scavengers: Feet"] = NewCategory("Query.ScavengersFeet", CategoryType.Query),
    ["307. Scavengers: Head"] = NewCategory("Query.ScavengersHead", CategoryType.Query),
    ["308. Scavengers: Jacket"] = NewCategory("Query.ScavengersJacket", CategoryType.Query),
    ["309. Scavengers: Junk"] = NewCategory("Query.ScavengersJunk", CategoryType.Query),
    ["310. Animals: Clothing"] = NewCategory("Query.AnimalsClothing", CategoryType.Query),
    ["311. Animals: Clothing (PL)"] = NewCategory("Query.AnimalsClothing_EP1", CategoryType.Query),
    ["312. Animals: Face"] = NewCategory("Query.AnimalsFace", CategoryType.Query),
    ["313. Animals: Feet"] = NewCategory("Query.AnimalsFeet", CategoryType.Query),
    ["314. Animals: Head"] = NewCategory("Query.AnimalsHead", CategoryType.Query),
    ["315. Animals: Jewellery"] = NewCategory("Query.AnimalsJewellery", CategoryType.Query),
    ["316. Animals: Junk"] = NewCategory("Query.AnimalsJunk", CategoryType.Query),
    ["317. Animals: T Shirt"] = NewCategory("Query.AnimalsTShirt", CategoryType.Query),
    ["318. Animals: Tank Top"] = NewCategory("Query.AnimalsTankTop", CategoryType.Query),
    ["319. Animals: Vest"] = NewCategory("Query.AnimalsVest", CategoryType.Query),
    ["320. Valentinos: Clothing"] = NewCategory("Query.ValentinosClothing", CategoryType.Query),
    ["321. Valentinos: Clothing (PL)"] = NewCategory("Query.ValentinosClothing_EP1", CategoryType.Query),
    ["322. Valentinos: Face"] = NewCategory("Query.ValentinosFace", CategoryType.Query),
    ["323. Valentinos: Feet"] = NewCategory("Query.ValentinosFeet", CategoryType.Query),
    ["324. Valentinos: Head"] = NewCategory("Query.ValentinosHead", CategoryType.Query),
    ["325. Valentinos: Jewellery"] = NewCategory("Query.ValentinosJewellery", CategoryType.Query),
    ["326. Valentinos: Junk"] = NewCategory("Query.ValentinosJunk", CategoryType.Query),
    ["327. Sixthstreet: Face"] = NewCategory("Query.SixthstreetFace", CategoryType.Query),
    ["328. Sixthstreet: Feet"] = NewCategory("Query.SixthstreetFeet", CategoryType.Query),
    ["329. Sixthstreet: Head"] = NewCategory("Query.SixthstreetHead", CategoryType.Query),
    ["330. Maelstrom:  Weapon"] = NewCategory("Query.Maelstrom_WeaponQuery", CategoryType.Query),
    ["331. Maelstrom: Clothing"] = NewCategory("Query.MaelstromClothing", CategoryType.Query),
    ["332. Maelstrom: Clothing (PL)"] = NewCategory("Query.MaelstromClothing_EP1", CategoryType.Query),
    ["333. Maelstrom: Face"] = NewCategory("Query.MaelstromFace", CategoryType.Query),
    ["334. Maelstrom: Feet"] = NewCategory("Query.MaelstromFeet", CategoryType.Query),
    ["335. Maelstrom: Head"] = NewCategory("Query.MaelstromHead", CategoryType.Query),
    ["336. Maelstrom: Junk"] = NewCategory("Query.MaelstromJunk", CategoryType.Query),
    ["337. Maelstrom: Punk Clothing"] = NewCategory("Query.MaelstromPunkClothing", CategoryType.Query),
    ["338. Others: Alcohol"] = NewCategory("Query.AlcoholQuery", CategoryType.Query),
    ["339. Others: Assault Rifle"] = NewCategory("Query.AssaultRifleQuery", CategoryType.Query),
    ["340. Others: Balaclava"] = NewCategory("Query.Balaclava", CategoryType.Query),
    ["341. Others: Balaclava No Faction"] = NewCategory("Query.BalaclavaNoFaction", CategoryType.Query),
    ["342. Others: Baton"] = NewCategory("Query.BatonQuery", CategoryType.Query),
    ["343. Others: Biker Helmet No Faction"] = NewCategory("Query.BikerHelmetNoFaction", CategoryType.Query),
    ["344. Others: Boots"] = NewCategory("Query.Boots", CategoryType.Query),
    ["345. Others: Cap No Faction"] = NewCategory("Query.CapNoFaction", CategoryType.Query),
    ["346. Others: Car Combat Weapon"] = NewCategory("Query.CarCombat_WeaponQuery", CategoryType.Query),
    ["347. Others: Casual Shoes"] = NewCategory("Query.CasualShoes", CategoryType.Query),
    ["348. Others: Coat"] = NewCategory("Query.Coat", CategoryType.Query),
    ["349. Others: Coat No Faction"] = NewCategory("Query.CoatNoFaction", CategoryType.Query),
    ["350. Others: Consumable"] = NewCategory("Query.ConsumableQuery", CategoryType.Query),
    ["351. Others: Courier Rare Find Weapon"] = NewCategory("Query.Courier_RareFind_WeaponQuery", CategoryType.Query),
    ["352. Others: Cowboy Hat No Faction"] = NewCategory("Query.CowboyHatNoFaction", CategoryType.Query),
    ["353. Others: Cyberdeck Program"] = NewCategory("Query.CyberdeckProgram", CategoryType.Query),
    ["354. Others: Dress"] = NewCategory("Query.Dress", CategoryType.Query),
    ["355. Others: Drink"] = NewCategory("Query.DrinkQuery", CategoryType.Query),
    ["356. Others: Feet"] = NewCategory("Query.FeetQuery", CategoryType.Query),
    ["357. Others: Feet (PL)"] = NewCategory("Query.FeetQuery_EP1", CategoryType.Query),
    ["358. Others: Food"] = NewCategory("Query.FoodQuery", CategoryType.Query),
    ["359. Others: Formal Jacket"] = NewCategory("Query.FormalJacket", CategoryType.Query),
    ["360. Others: Formal Pants"] = NewCategory("Query.FormalPants", CategoryType.Query),
    ["361. Others: Formal Shirt"] = NewCategory("Query.FormalShirt", CategoryType.Query),
    ["362. Others: Formal Shoes"] = NewCategory("Query.FormalShoes", CategoryType.Query),
    ["363. Others: Glasses"] = NewCategory("Query.Glasses", CategoryType.Query),
    ["364. Others: Good Quality Alcohol"] = NewCategory("Query.GoodQualityAlcohol", CategoryType.Query),
    ["365. Others: Good Quality Drink"] = NewCategory("Query.GoodQualityDrink", CategoryType.Query),
    ["366. Others: Good Quality Food"] = NewCategory("Query.GoodQualityFood", CategoryType.Query),
    ["367. Others: Hat"] = NewCategory("Query.Hat", CategoryType.Query),
    ["368. Others: Headgear"] = NewCategory("Query.HeadgearQuery", CategoryType.Query),
    ["369. Others: Headgear (PL)"] = NewCategory("Query.HeadgearQuery_EP1", CategoryType.Query),
    ["370. Others: Helmet"] = NewCategory("Query.Helmet", CategoryType.Query),
    ["371. Others: Industrial Face No Faction"] = NewCategory("Query.IndustrialFaceNoFaction", CategoryType.Query),
    ["372. Others: Industrial Feet No Faction"] = NewCategory("Query.IndustrialFeetNoFaction", CategoryType.Query),
    ["373. Others: Industrial Head No Faction"] = NewCategory("Query.IndustrialHeadNoFaction", CategoryType.Query),
    ["374. Others: Inject Weapons Base "] = NewCategory("Query.InjectWeapons_Base_Query", CategoryType.Query),
    ["375. Others: Inject Weapons Tier 1 "] = NewCategory("Query.InjectWeapons_Tier1_Query", CategoryType.Query),
    ["376. Others: Inject Weapons Tier 2 "] = NewCategory("Query.InjectWeapons_Tier2_Query", CategoryType.Query),
    ["377. Others: Inject Weapons Tier 3 "] = NewCategory("Query.InjectWeapons_Tier3_Query", CategoryType.Query),
    ["378. Others: Inner Chest"] = NewCategory("Query.InnerChestQuery", CategoryType.Query),
    ["379. Others: Inner Chest (PL)"] = NewCategory("Query.InnerChestQuery_EP1", CategoryType.Query),
    ["380. Others: Jacket"] = NewCategory("Query.Jacket", CategoryType.Query),
    ["381. Others: Jumpsuit"] = NewCategory("Query.Jumpsuit", CategoryType.Query),
    ["382. Others: Junk Token"] = NewCategory("Query.JunkTokenQuery", CategoryType.Query),
    ["383. Others: Knife"] = NewCategory("Query.KnifeQuery", CategoryType.Query),
    ["384. Others: Krausser Weapon"] = NewCategory("Query.Krausser_WeaponQuery", CategoryType.Query),
    ["385. Others: Krausser Weapon Array (PL)"] = NewCategory("Query.KrausserWeaponArrayQuery_EP1", CategoryType.Query),
    ["386. Others: Large Food"] = NewCategory("Query.LargeFoodQuery", CategoryType.Query),
    ["387. Others: Large Junk Token"] = NewCategory("Query.LargeJunkTokenQuery", CategoryType.Query),
    ["388. Others: Legs"] = NewCategory("Query.LegsQuery", CategoryType.Query),
    ["389. Others: Legs (PL)"] = NewCategory("Query.LegsQuery_EP1", CategoryType.Query),
    ["390. Others: Long Lasting"] = NewCategory("Query.LongLastingQuery", CategoryType.Query),
    ["391. Others: Loose Shirt"] = NewCategory("Query.LooseShirt", CategoryType.Query),
    ["392. Others: Low Quality Alcohol"] = NewCategory("Query.LowQualityAlcohol", CategoryType.Query),
    ["393. Others: Low Quality Drink"] = NewCategory("Query.LowQualityDrink", CategoryType.Query),
    ["394. Others: Low Quality Food"] = NewCategory("Query.LowQualityFood", CategoryType.Query),
    ["395. Others: Low Quality Shard"] = NewCategory("Query.LowQualityShard", CategoryType.Query),
    ["396. Others: Mask"] = NewCategory("Query.Mask", CategoryType.Query),
    ["397. Others: Medium Food"] = NewCategory("Query.MediumFoodQuery", CategoryType.Query),
    ["398. Others: Medium Junk Token"] = NewCategory("Query.MediumJunkTokenQuery", CategoryType.Query),
    ["399. Others: Medium Quality Alcohol"] = NewCategory("Query.MediumQualityAlcohol", CategoryType.Query),
    ["400. Others: Medium Quality Drink"] = NewCategory("Query.MediumQualityDrink", CategoryType.Query),
    ["401. Others: Medium Quality Food"] = NewCategory("Query.MediumQualityFood", CategoryType.Query),
    ["402. Others: Melee Weapon"] = NewCategory("Query.MeleeWeaponQuery", CategoryType.Query),
    ["403. Others: Military Weapon"] = NewCategory("Query.Military_WeaponQuery", CategoryType.Query),
    ["404. Others: Neon Weapon"] = NewCategory("Query.Neon_WeaponQuery", CategoryType.Query),
    ["405. Others: One Hand Blade"] = NewCategory("Query.OneHandBladeQuery", CategoryType.Query),
    ["406. Others: One Hand Blunt"] = NewCategory("Query.OneHandBluntQuery", CategoryType.Query),
    ["407. Others: Outer Chest"] = NewCategory("Query.OuterChestQuery", CategoryType.Query),
    ["408. Others: Outer Chest (PL)"] = NewCategory("Query.OuterChestQuery_EP1", CategoryType.Query),
    ["409. Others: Pants"] = NewCategory("Query.Pants", CategoryType.Query),
    ["410. Others: Pants No Faction"] = NewCategory("Query.PantsNoFaction", CategoryType.Query),
    ["411. Others: Power Weapon"] = NewCategory("Query.Power_WeaponQuery", CategoryType.Query),
    ["412. Others: Ranged Weapon"] = NewCategory("Query.RangedWeaponQuery", CategoryType.Query),
    ["413. Others: Recon Grenade"] = NewCategory("Query.ReconGrenadeQuery", CategoryType.Query),
    ["414. Others: Sales DLC All Scopes"] = NewCategory("Query.SalesDLC_AllScopesQuery", CategoryType.Query),
    ["415. Others: Sales DLC Long Scopes"] = NewCategory("Query.SalesDLC_LongScopesQuery", CategoryType.Query),
    ["416. Others: Sales DLC Short Scopes"] = NewCategory("Query.SalesDLC_ShortScopesQuery", CategoryType.Query),
    ["417. Others: Sales DLC Sniper Scopes"] = NewCategory("Query.SalesDLC_SniperScopesQuery", CategoryType.Query),
    ["418. Others: Scarf"] = NewCategory("Query.Scarf", CategoryType.Query),
    ["419. Others: Shirt"] = NewCategory("Query.Shirt", CategoryType.Query),
    ["420. Others: Shorts"] = NewCategory("Query.Shorts", CategoryType.Query),
    ["421. Others: Skillbook"] = NewCategory("Query.SkillbookQuery", CategoryType.Query),
    ["422. Others: Skirt"] = NewCategory("Query.Skirt", CategoryType.Query),
    ["423. Others: Small Food"] = NewCategory("Query.SmallFoodQuery", CategoryType.Query),
    ["424. Others: Small Junk Token"] = NewCategory("Query.SmallJunkTokenQuery", CategoryType.Query),
    ["425. Others: Smart Weapon"] = NewCategory("Query.Smart_WeaponQuery", CategoryType.Query),
    ["426. Others: Sniper Rifle"] = NewCategory("Query.SniperRifleQuery", CategoryType.Query),
    ["427. Others: Sports Feet No Faction"] = NewCategory("Query.SportsFeetNoFaction", CategoryType.Query),
    ["428. Others: Sports Legs No Faction"] = NewCategory("Query.SportsLegsNoFaction", CategoryType.Query),
    ["429. Others: T Shirt"] = NewCategory("Query.TShirt", CategoryType.Query),
    ["430. Others: Tank Top"] = NewCategory("Query.TankTop", CategoryType.Query),
    ["431. Others: Tank Top No Faction"] = NewCategory("Query.TankTopNoFaction", CategoryType.Query),
    ["432. Others: Tech"] = NewCategory("Query.Tech", CategoryType.Query),
    ["433. Others: Tech Intrinsic"] = NewCategory("Query.Tech_Intrinsic", CategoryType.Query),
    ["434. Others: Tech Weapon"] = NewCategory("Query.Tech_WeaponQuery", CategoryType.Query),
    ["435. Others: Techtronika Military Weapon"] = NewCategory("Query.TechtronikaMilitary_WeaponQuery", CategoryType.Query),
    ["436. Others: Tight Jumpsuit"] = NewCategory("Query.TightJumpsuit", CategoryType.Query),
    ["437. Others: Tool Weapon"] = NewCategory("Query.ToolWeaponQuery", CategoryType.Query),
    ["438. Others: Top Quality Alcohol"] = NewCategory("Query.TopQualityAlcohol", CategoryType.Query),
    ["439. Others: Two Hand Blunt"] = NewCategory("Query.TwoHandBluntQuery", CategoryType.Query),
    ["440. Others: Two Hand Hammer"] = NewCategory("Query.TwoHandHammerQuery", CategoryType.Query),
    ["441. Others: Tyger Claws Biker Helmet"] = NewCategory("Query.TygerClawsBikerHelmet", CategoryType.Query),
    ["442. Others: Tyger Claws Feet"] = NewCategory("Query.TygerClawsFeet", CategoryType.Query),
    ["443. Others: Tyger Claws Mask"] = NewCategory("Query.TygerClawsMask", CategoryType.Query),
    ["444. Others: Undershirt"] = NewCategory("Query.Undershirt", CategoryType.Query),
    ["445. Others: Vest"] = NewCategory("Query.Vest", CategoryType.Query),
    ["446. Others: Visor"] = NewCategory("Query.Visor", CategoryType.Query),
    ["447. Others: Visor Intrinsic"] = NewCategory("Query.Visor_Intrinsic", CategoryType.Query),
    ["448. Others: Weapon Array"] = NewCategory("Query.WeaponArrayQuery", CategoryType.Query),
    ["449. Others: Weapon Array (PL)"] = NewCategory("Query.WeaponArrayQuery_EP1", CategoryType.Query),
    ["450. Others: Wraiths Boots"] = NewCategory("Query.WraithsBoots", CategoryType.Query),
    ["451. Others: Wraiths Glasses"] = NewCategory("Query.WraithsGlasses", CategoryType.Query),
    ["452. Others: Wraiths Helmet"] = NewCategory("Query.WraithsHelmet", CategoryType.Query),
    ["453. Others: Wraiths Mask"] = NewCategory("Query.WraithsMask", CategoryType.Query),
    
    ["996. All clothes"] = NewCategory("gamedataClothing_Record", CategoryType.Record),
    ["997. All weapons"] = NewCategory("gamedataWeaponItem_Record", CategoryType.Record),
    ["998. All grenades"] = NewCategory("gamedataGrenade_Record", CategoryType.Record),
    ["999. All items"] = NewCategory("gamedataItem_Record", CategoryType.Record)
};

---@type table<number, string>
local tkeys = {};
for k in pairs(itemCategories) do table.insert(tkeys, k) end;
table.sort(tkeys, function (a, b)
    local _, _, dA = string.find(a, "(%d*)");
    local _, _, dB = string.find(b, "(%d*)");

    local aNums = tonumber(dA, 10);
    local bNums = tonumber(dB, 10);

    return aNums < bNums;
end);

local defaultCategoryKey = tkeys[1];

local currentlySelectedCategory = nil;
local currentItemAmount = 0;

local feature = NewFeature("godvendor", "God vendor");

feature.description = {
    "Well, at least now he's got a reason to live.\n\n",
    "Tip: Not all items may show up. I have no idea why.",
    "Tip: Switching categories can and will hang your game for a bit. Just be patient.",
    "Also your mouse cursor might dissapear. It's normal too. Just close-open CET's menu.",
    "Tip: Most of these categories were auto-generated from CDPR's internal queries.",
    "Sometimes they can make little sense."
};

feature.needsEnabling = false;

---Checks if vendor is our "free" vendor.
---@param vendor Vendor
---@return boolean
function IsGodVendor(vendor)
    local vendorObject = vendor:GetVendorObject();

    if vendorObject == nil then
        return false;
    end

    if vendorObject:GetPersistentID().entityHash ~= vendorEntityHash then
        return false;
    end

    return true;
end

function CleanupRecord(record)
    if TweakDB:GetRecord(record) ~= nil then
        TweakDB:DeleteRecord(record);
    end
end

function CleanupRecords(template)
    local records = TweakDB:GetRecords("gamedataVendorItem_Record");
    local templateLength = string.len(template);
    local start = os.clock();

    for _, record in pairs(records) do
        local recordName = record:GetRecordID().value;
        local sub = string.sub(recordName, 1, templateLength);

        if sub ~= template then
            goto continue;
        end

        TweakDB:DeleteRecord(recordName);

        ::continue::
    end

    lastResetTook = os.clock() - start;
end

---@param category Category
---@return table<number, TweakDBID>
function GetItems(category)
    if category.type == CategoryType.Query then
        return TweakDB:Query(category.name);
    end

    ---@type table<number, gamedataItem_Record>
    local records = TweakDB:GetRecords(category.name);
    ---@type table<number, TweakDBID>
    local itemIds = {};

    for i, item in pairs(records) do
        itemIds[i] = item:GetID();
    end

    return itemIds;
end

---@param category Category
function RecreateFakeVendorRecord(category)
    CleanupRecord(newVendorRecord);
    CleanupRecord(quantityRecord);
    CleanupRecords(newVendorRecord .. "_inline_item_");

    local start = os.clock();

    -- Cloning original vendor record
    TweakDB:CloneRecord(newVendorRecord, originalVendorRecord);

    -- Cloning "quantity" record
    TweakDB:CloneRecord(quantityRecord, "Vendors.Foodshop_inline1");
    TweakDB:SetFlat(quantityRecord .. ".value", 1);

    -- Clearing filters
    TweakDB:SetFlat(newVendorRecord .. ".customerFilterTags", { [1] = CName.new("Currency") });
    TweakDB:SetFlat(newVendorRecord .. ".vendorFilterTags", { [1] = CName.new("Currency") });

    local quantityRecordId = TweakDBID.new(quantityRecord);

    ---@type table<integer, TweakDBID>
    local itemStock = {};
    local itemsToAdd = GetItems(category);

    -- For each item generating an inline record that points to cloned quantityRecord with desired item ID
    for i, itemId in pairs(itemsToAdd) do
        local itemRecord = newVendorRecord .. "_inline_item_" .. i;

        TweakDB:CloneRecord(itemRecord, "Vendors.Foodshop_inline0");
        TweakDB:SetFlat(itemRecord .. ".item", itemId);
        TweakDB:SetFlat(itemRecord .. ".quantity", { [1] = quantityRecordId });

        if forceItemQuality then
            TweakDB:SetFlat(itemRecord .. ".forceQuality", CName.new(itemQualities[currentItemQuality + 1]));
        end

        itemStock[i] = TweakDBID.new(itemRecord);
    end

    TweakDB:SetFlat(newVendorRecord .. ".itemStock", itemStock);
    lastRefillTook = os.clock() - start;

    ShowNotification(
        CreateNotification(
            "God Vendor",
            string.format("Inventory update is complete.\nReset took %.2f seconds. Refill took %.2f seconds.", lastResetTook, lastRefillTook)));
end

---@param key string
---@param category Category
function ChangeCategory(key, category)
    currentlySelectedCategory = key;
    currentItemAmount = #GetItems(category);

    RecreateFakeVendorRecord(category);
end

feature.onInit = function ()
    ChangeCategory(defaultCategoryKey, itemCategories[defaultCategoryKey]);

    teleportPos = ToVector4({ x = -986.74524, y = -1158.5941, z = 11.767738, w = 1 });
    teleportOrientation = ToEulerAngles({ roll = 0, pitch = 0, yaw = -36.37275 });

    Override("Vendor", "GetItemsForSale",
    ---@param this Vendor
    ---@param checkPlayerCanBuy boolean
    function (this, checkPlayerCanBuy, wrapped)
        if not IsGodVendor(this) then
            return wrapped(checkPlayerCanBuy);
        end;

        -- Replacing vendor ID
        this.vendorRecord = TweakDBInterface.GetVendorRecord(newVendorRecord);

        -- Forcing everything to recache from the fake vendor record (LazyInitStock especially)
        this.inventoryInit = false;
        this.stockInit = false;
        this.stock = {};

        return wrapped(false);
    end);

    Override("Vendor", "ShouldRegenerateItem",
    ---@param this Vendor
    ---@param itemId ItemID
    ---@param wrapped fun(itemId: ItemID): boolean
    ---@return boolean
    function (this, itemId, wrapped)
        if IsGodVendor(this) then
            return true;
        end

        return wrapped(itemId);
    end);

    Override("Vendor", "AlwaysInStock",
    ---@param this Vendor
    ---@param itemId ItemID
    ---@param wrapped fun(itemId: ItemID): boolean
    ---@return boolean
    function (this, itemId, wrapped)
        if IsGodVendor(this) then
            return true;
        end

        return wrapped(itemId);
    end);

    Override("Vendor", "CreateDynamicStockFromPlayerProgression;array<SItemStack>GameObject",
    function (this, outputStacks, player, wrapped)
        if IsGodVendor(this) then
            return true;
        end

        return wrapped(outputStacks, player);
    end)

    Override("Vendor", "ShouldRegenerateStock",
    ---@param this Vendor
    ---@param wrapped fun(): boolean
    function (this, wrapped)
        if not IsGodVendor(this) then
            return wrapped();
        end

        return true;
    end);

    Override("Vendor", "CalculateQuantityForStack",
    ---@param this Vendor
    ---@param vendorWare VendorWare_Record
    ---@param player PlayerPuppet
    ---@param wrapped fun(vendorWare: VendorWare_Record, player: PlayerPuppet): integer
    ---@returns integer
    function (this, vendorWare, player, wrapped)
        if IsGodVendor(this) then
            return 1;
        end

        return wrapped(vendorWare, player);
    end);

    Override("Vendor", "GetMoney",
    ---@param this Vendor
    ---@param wrapped fun(): number
    ---@return number
    function(this, wrapped)
        if not IsGodVendor(this) then
            return wrapped();
        end;

        return 0;
    end);
end

feature.setupHotkeys = function ()
    registerHotkey("freevendor_teleportto", "Teleport to free vendor", function()
        TeleportToVendor();
    end);

    registerHotkey("freevendor_teleportfrom", "Teleport back from the free vendor", function()
        TeleportBack();
    end);
end

function TeleportToVendor()
    local player = Game.GetPlayer();
    teleportedFrom = player:GetWorldPosition();
    local tp = Game.GetTeleportationFacility();
    tp:Teleport(player, teleportPos, teleportOrientation);
end

function TeleportBack()
    if teleportedFrom == nil then return end;

    local player = Game.GetPlayer();
    local tp = Game.GetTeleportationFacility();
    tp:Teleport(player, teleportedFrom, player:GetWorldOrientation():ToEulerAngles());
end

feature.onDraw = function()
    ImGui.Text("Select item category:");

    ImGui.PushItemWidth(450);

    if ImGui.BeginListBox("##categories") then
        for _, k in ipairs(tkeys) do
            local name = k;
            local category = itemCategories[k];

            if ImGui.Selectable(name) then
                ChangeCategory(name, category);
            end
        end
    
        ImGui.EndListBox();
    end

    ImGui.Text("Current category: ");
    ImGui.Text(currentlySelectedCategory);
    ImGui.Text("Total items: " .. tostring(currentItemAmount));

    ImGui.Separator();

    local value, pressed = ImGui.Checkbox("Force item quality", forceItemQuality);

    if pressed then
        forceItemQuality = value;
        RecreateFakeVendorRecord(itemCategories[currentlySelectedCategory]);
    end

    local value, changed = ImGui.Combo("Item quality", currentItemQuality, itemQualitiesString);

    if changed then
        currentItemQuality = value;
        if forceItemQuality then
            RecreateFakeVendorRecord(itemCategories[currentlySelectedCategory]);
        end
    end

    ImGui.Separator();

    if ImGui.Button("Teleport to vendor") then
        TeleportToVendor();
    end

    if teleportedFrom ~= nil then
        ImGui.SameLine();

        if ImGui.Button("Teleport back") then
            TeleportBack();
        end
    end

    ImGui.PopItemWidth();
end

RegisterFeature("Economy", feature);
