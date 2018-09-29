local tod = ARWIC_TOD
tod.data = {}

-- TODO: rename file to Data.lua

tod.data.phaseLengths = {
    ["Waiting for Players"] = -1,
    ["Day 1"] = 15,
    ["Discussion"] = 45,
    ["Voting"] = 30,
    ["Defense"] = 20,
    ["Judgement"] = 20,
    ["Last Words"] = 5,
    ["Night"] = 30,
}

tod.data.roles = {
    [-1] = { name = "ERR_UNKNOWN_ROLE" },
    -- Town Investigative
    [0] = {
        id = 0,
        name = "Investigator",
        alignment = "town",
        space = "ti",
        unique = false,
        attack = 0,
        defense = 0,
        priority = 4,
        can_hear_whispers = false,
        night_chat = "none",
        sheriff_results = "Your target is not suspicious.",
        invest_results = "Your target could be a Investigator, Consigliere, or Mayor.",
        consig_results = "Your target gathers information about people. They must be an Investigator.",
        info = {
            summary = "A private eye who secretly gathers information.",
            abilities = "Investigate one person each night for a clue to their role.",
            attributes = "None.",
            Goal = "Lynch every criminal and evildoer."
        },
        victory_conditions = {
            "town"
        },
        visiting = true,
        night_action = function(self, target)
            local lines = {}
            if target == nil then
                table.insert(lines, "You did not perform you're night action.")
            else
                local target_role = tod.data.roles[target.role]
                table.insert(lines, target_role.invest_results)
            end
            return lines
        end,
        day_action = function()
        end,
    },
    [1] = {
        id = 1,
        name = "Lookout",
        alignment = "town",
        space = "ti",
        unique = false,
        attack = 0,
        defense = 0,
        priority = 4,
        can_hear_whispers = false,
        night_chat = "none",
        sheriff_results = "Your target is not suspicious.",
        invest_results = "Your target could be a Lookout, Forger, or Witch.",
        consig_results = "Your target watches who visits people at night. They must be a Lookout.",
        info = {
            summary = "An eagle-eyed observer, stealthily camping outside houses to gain information.",
            abilities = "Watch one person at night to see who visits them.",
            attributes = "None.",
            Goal = "Lynch every criminal and evildoer."
        },
        victory_conditions = {
            "town"
        },
        night_action = function(self, target)
            local lines = {}
            if contains(self.night_attrs, "rb") then
                table.insert(lines, "Someone occupied your night. You were role blocked!")
                return lines
            end
            for k,v in pairs(target.visitors) do
                table.insert(lines, v.nickname .. " visited your target last night!")
            end
        end,
        day_action = function()
        end,
    },
    [2] = {
        id = 2,
        name = "Psychic",
        alignment = "town",
        space = "ti",
        unique = false,
        attack = 0,
        defense = 0,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [3] = {
        id = 3,
        name = "Sheriff",
        alignment = "town",
        space = "ti",
        unique = false,
        attack = 0,
        defense = 0,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [4] = {
        id = 4,
        name = "Spy",
        alignment = "town",
        space = "ti",
        unique = false,
        attack = 0,
        defense = 0,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [5] = {
        id = 5,
        name = "Tracker",
        alignment = "town",
        space = "ti",
        unique = false,
        attack = 0,
        defense = 0,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    -- Town Killing
    [6] = {
        id = 6,
        name = "Jailor",
        alignment = "town",
        space = "tk",
        unique = true,
        attack = 3, -- unstoppable
        defense = 0,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "jail",
    },
    [7] = {
        id = 7,
        name = "Vampire Hunter",
        alignment = "town",
        space = "tk",
        unique = false,
        attack = 0,
        defense = 0,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "vampire_anon",
    },
    [8] = {
        id = 8,
        name = "Veteran",
        alignment = "town",
        space = "tk",
        unique = false,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [9] = {
        id = 9,
        name = "Vigilante",
        alignment = "town",
        space = "tk",
        unique = false,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    -- Town Protective
    [10] = {
        id = 10,
        name = "Bodyguard",
        alignment = "town",
        space = "tp",
        unique = false,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [11] = {
        id = 11,
        name = "Doctor",
        alignment = "town",
        space = "tp",
        unique = false,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [12] = {
        id = 12,
        name = "Crusader",
        alignment = "town",
        space = "tp",
        unique = false,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [13] = {
        id = 13,
        name = "Trapper",
        alignment = "town",
        space = "tp",
        unique = false,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [14] = {
        id = 14,
        name = "Escort",
        alignment = "town",
        space = "ts",
        unique = false,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [15] = {
        id = 15,
        name = "Mayor",
        alignment = "town",
        space = "ts",
        unique = true,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [16] = {
        id = 16,
        name = "Medium",
        alignment = "town",
        space = "ts",
        unique = false,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "dead",
    },
    [17] = {
        id = 17,
        name = "Retributionist",
        alignment = "town",
        space = "ts",
        unique = true,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
    [18] = {
        id = 18,
        name = "Transporter",
        alignment = "town",
        space = "ts",
        unique = false,
        night_action = function(self, target1, target2)
        end,
        day_action = function(self, target)
        end,
        can_hear_whispers = false,
        night_chat = "none",
    },
}