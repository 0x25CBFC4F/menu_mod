require 'feature';

---@type table<string, table<integer, Feature>>
Sections = {};

SectionKeysSorted = {};

---@type table<integer, Feature>
Features = {};

---Registers feature
---@param section string Section name
---@param feature Feature
function RegisterFeature(section, feature)
    section = string.upper(section);

    if Sections[section] == nil then
        Sections[section] = {};
    end

    table.insert(Features, feature);
    table.insert(Sections[section], feature);
end

function SortSections()
    for k, _ in pairs(Sections) do
        table.insert(SectionKeysSorted, k);
    end

    table.sort(SectionKeysSorted);
end