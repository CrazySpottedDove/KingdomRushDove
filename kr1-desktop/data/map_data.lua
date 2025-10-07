-- chunkname: @./kr1-desktop/data/map_data.lua
local V = require("klua.vector")
local v = V.v
local r = V.r
local deco_fn = require("map_decos_functions")
local ani_paths = require("data.map_animations_paths")
local ani_paths2 = require("data.map_animations_paths2")
local i18n = require("i18n")

local function CJK(default, zh, ja, kr)
    return i18n.cjk(i18n, default, zh, ja, kr)
end

local function fc(r, g, b, a)
    return {r / 255, g / 255, b / 255, a / 255}
end

local p11, p12 = 0, CJK(0.48, 0.5, 0.5, 0.5)
local p21, p22 = CJK(0.3, 0.35, 0.35, 0.35), CJK(0.5, 0.55, 0.55, 0.55)
local rs = GGLabel.static.ref_h / REF_H

return {
    hero_names_config = {
        default = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 183, 95, 255),
                c3 = fc(255, 98, 0, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(88, 19, 0, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(88, 19, 0, 255)
            }, {}}
        },
        hero_gerald = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(182, 232, 255, 255),
                c3 = fc(65, 178, 229, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(0, 69, 100, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(0, 69, 100, 255)
            }, {}}
        },
        hero_alleria = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(238, 255, 93, 255),
                c3 = fc(145, 215, 0, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(37, 93, 0, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(37, 93, 0, 255)
            }, {}}
        },
        hero_malik = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 246, 126, 255),
                c3 = fc(255, 168, 0, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(135, 74, 0, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(135, 74, 0, 255)
            }, {}}
        },
        hero_bolin = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 194, 79, 255),
                c3 = fc(255, 113, 25, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(98, 37, 0, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(98, 37, 0, 255)
            }, {}}
        },
        hero_magnus = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 222, 254, 255),
                c3 = fc(200, 86, 255, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(69, 0, 112, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(69, 0, 112, 255)
            }, {}}
        },
        hero_ignus = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 242, 63, 255),
                c3 = fc(255, 126, 0, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(105, 40, 0, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(105, 40, 0, 255)
            }, {}}
        },
        hero_denas = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 252, 219, 255),
                c3 = fc(255, 224, 0, 255)
            }, {
                thickness = 2 * rs,
                outline_color = fc(107, 65, 0, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(107, 65, 0, 255)
            }, {}}
        },
        hero_elora = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 255, 255, 255),
                c3 = fc(150, 237, 245, 255)
            }, {
                thickness = 1.5 * rs,
                outline_color = fc(17, 108, 119, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(17, 108, 119, 255)
            }, {}}
        },
        hero_ingvar = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 211, 159, 255),
                c3 = fc(255, 111, 0, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(102, 33, 0, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(102, 33, 0, 255)
            }, {}}
        },
        hero_hacksaw = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(205, 255, 70, 255),
                c3 = fc(85, 156, 11, 255)
            }, {
                thickness = 1.5 * rs,
                outline_color = fc(45, 88, 0, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(45, 88, 0, 255)
            }, {}}
        },
        hero_oni = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 167, 98, 255),
                c3 = fc(224, 44, 0, 255)
            }, {
                thickness = 1.5 * rs,
                outline_color = fc(114, 18, 0, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(114, 18, 0, 255)
            }, {}}
        },
        hero_thor = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(222, 248, 255, 255),
                c3 = fc(34, 185, 210, 255)
            }, {
                thickness = 2 * rs,
                outline_color = fc(0, 69, 93, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(0, 69, 93, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 2 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_10yr = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 242, 63, 255),
                c3 = fc(255, 126, 0, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(105, 40, 0, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(105, 40, 0, 255)
            }, {}}
        },
        hero_alric = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(255, 183, 95, 255),
                c3 = fc(255, 98, 0, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(88, 19, 0, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(88, 19, 0, 255)
            }, {}}
        },
        hero_mirage = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(255, 177, 252, 255),
                c3 = fc(140, 46, 212, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(77, 0, 75, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(77, 0, 75, 255)
            }, {}}
        },
        hero_pirate = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(215, 253, 255, 255),
                c3 = fc(29, 203, 217, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(0, 81, 84, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(0, 81, 84, 255)
            }, {}}
        },
        hero_beastmaster = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(228, 255, 95, 255),
                c3 = fc(107, 189, 0, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(32, 58, 0, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(32, 58, 0, 255)
            }, {}}
        },
        hero_voodoo_witch = {
            shader_args = {{
                margin = 2 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(231, 192, 255, 0),
                c2 = fc(209, 136, 255, 255),
                c3 = fc(128, 68, 190, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(61, 27, 86, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(61, 27, 86, 255)
            }, {}}
        },
        hero_wizard = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(255, 246, 83, 255),
                c3 = fc(255, 129, 5, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(79, 44, 26, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(79, 44, 26, 255)
            }, {}}
        },
        hero_priest = {
            shader_args = {{
                margin = 2 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(215, 251, 255, 255),
                c3 = fc(81, 202, 255, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(0, 97, 121, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(0, 97, 121, 255)
            }, {}}
        },
        hero_giant = {
            shader_args = {{
                margin = 2 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(187, 251, 255, 255),
                c3 = fc(0, 177, 172, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(0, 83, 86, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(0, 83, 86, 255)
            }, {}}
        },
        hero_alien = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(222, 180, 255, 255),
                c3 = fc(117, 65, 215, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(70, 20, 109, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(70, 20, 109, 255)
            }, {}}
        },
        hero_dragon = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 210, 0, 0),
                c2 = fc(255, 151, 25, 255),
                c3 = fc(222, 77, 22, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(98, 20, 0, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(98, 20, 0, 255)
            }, {}}
        },
        hero_crab = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(226, 255, 123, 255),
                c3 = fc(133, 170, 0, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(56, 72, 0, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(56, 72, 0, 255)
            }, {}}
        },
        hero_monk = {
            shader_args = {{
                margin = 2 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(251, 255, 184, 0),
                c2 = fc(255, 214, 28, 255),
                c3 = fc(255, 126, 0, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(98, 47, 0, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(98, 47, 0, 255)
            }, {}}
        },
        hero_van_helsing = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(255, 179, 175, 255),
                c3 = fc(212, 68, 83, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(100, 0, 16, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(100, 0, 16, 255)
            }, {}}
        },
        hero_dracolich = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(228, 255, 95, 255),
                c3 = fc(107, 173, 0, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(29, 51, 1, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(29, 51, 1, 255)
            }, {}}
        },
        hero_minotaur = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(255, 170, 88, 255),
                c3 = fc(255, 42, 0, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(81, 17, 0, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(81, 17, 0, 255)
            }, {}}
        },
        hero_monkey_god = {
            shader_args = {{
                margin = 2 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 255, 255, 0),
                c2 = fc(212, 255, 133, 255),
                c3 = fc(109, 212, 3, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(49, 107, 6, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(49, 107, 6, 255)
            }, {}}
        },
        hero_elves_archer = {
            shader_args = {{
                sharpness = 20,
                margin = 2.5 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(253, 255, 222, 255),
                c2 = fc(221, 236, 110, 255),
                c3 = fc(124, 156, 43, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(32, 41, 8, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(32, 41, 8, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_arivan = {
            shader_args = {{
                sharpness = 10,
                margin = 2 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 215, 154, 255),
                c2 = fc(255, 141, 98, 255),
                c3 = fc(175, 45, 0, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(91, 24, 0, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(91, 24, 0, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_catha = {
            shader_args = {{
                sharpness = 20,
                margin = 1.5 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(253, 243, 212, 255),
                c2 = fc(245, 242, 128, 255),
                c3 = fc(213, 119, 44, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(89, 29, 0, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(89, 29, 0, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 2 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_regson = {
            shader_args = {{
                sharpness = 20,
                margin = 1 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(212, 225, 255, 255),
                c2 = fc(156, 165, 255, 255),
                c3 = fc(76, 74, 224, 255)
            }, {
                thickness = 2 * rs,
                outline_color = fc(47, 31, 124, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(47, 31, 124, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_elves_denas = {
            shader_args = {{
                sharpness = 20,
                margin = 1 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 252, 222, 255),
                c2 = fc(250, 224, 76, 255),
                c3 = fc(209, 138, 48, 255)
            }, {
                thickness = 2 * rs,
                outline_color = fc(107, 65, 0, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(107, 65, 0, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_bravebark = {
            shader_args = {{
                sharpness = 20,
                margin = 1 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 249, 180, 255),
                c2 = fc(202, 216, 78, 255),
                c3 = fc(114, 113, 34, 255)
            }, {
                thickness = 2 * rs,
                outline_color = fc(60, 56, 0, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(60, 56, 0, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 2 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_veznan = {
            shader_args = {{
                sharpness = 20,
                margin = 1 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(230, 216, 247, 255),
                c2 = fc(176, 148, 248, 255),
                c3 = fc(94, 78, 204, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(51, 22, 127, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(51, 22, 127, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 2 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_faustus = {
            shader_args = {{
                sharpness = 20,
                margin = 1 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(206, 204, 249, 255),
                c2 = fc(169, 135, 245, 255),
                c3 = fc(96, 68, 153, 255)
            }, {
                thickness = 2 * rs,
                outline_color = fc(56, 38, 80, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(56, 38, 80, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 2 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_xin = {
            shader_args = {{
                sharpness = 20,
                margin = 1 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(252, 240, 196, 255),
                c2 = fc(242, 176, 65, 255),
                c3 = fc(187, 86, 34, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(89, 29, 0, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(89, 29, 0, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 2 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_rag = {
            single_line = true,
            shader_args = {{
                sharpness = 10,
                margin = 1 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 204, 241, 255),
                c2 = fc(255, 132, 186, 255),
                c3 = fc(206, 0, 119, 255)
            }, {
                thickness = 1.5 * rs,
                outline_color = fc(140, 0, 81, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(140, 0, 81, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_durax = {
            shader_args = {{
                sharpness = 20,
                margin = 1.5 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(160, 255, 252, 255),
                c2 = fc(0, 156, 189, 255),
                c3 = fc(0, 74, 90, 255)
            }, {
                thickness = 2 * rs,
                outline_color = fc(165, 235, 233, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(165, 235, 233, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_lilith = {
            shader_args = {{
                sharpness = 20,
                margin = 1 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 225, 177, 255),
                c2 = fc(255, 171, 51, 255),
                c3 = fc(207, 73, 19, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(107, 12, 3, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(89, 29, 0, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 2 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_bruce = {
            shader_args = {{
                sharpness = 20,
                margin = 1.5 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 255, 255, 255),
                c2 = fc(192, 253, 254, 255),
                c3 = fc(90, 168, 186, 255)
            }, {
                thickness = 2 * rs,
                outline_color = fc(30, 72, 88, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(30, 72, 88, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_lynn = {
            shader_args = {{
                sharpness = 10,
                p1 = 0.5,
                p2 = 0.5,
                margin = 2.5 * rs,
                c1 = fc(252, 239, 254, 255),
                c2 = fc(229, 118, 246, 255),
                c3 = fc(252, 239, 254, 255)
            }, {
                thickness = 3 * rs,
                outline_color = fc(104, 21, 127, 255)
            }, {
                thickness = 2 * rs,
                glow_color = fc(150, 135, 190, 155)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_phoenix = {
            shader_args = {{
                sharpness = 10,
                p1 = 0.5,
                p2 = 0.5,
                margin = 2.5 * rs,
                c1 = fc(255, 255, 218, 255),
                c2 = fc(255, 254, 104, 255),
                c3 = fc(255, 255, 218, 255)
            }, {
                thickness = 2 * rs,
                outline_color = fc(236, 121, 48, 255)
            }, {
                thickness = 3 * rs,
                glow_color = fc(112, 42, 15, 200)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_wilbur = {
            shader_args = {{
                sharpness = 10,
                margin = 2 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 255, 203, 255),
                c2 = fc(255, 254, 84, 255),
                c3 = fc(237, 132, 50, 255)
            }, {
                thickness = 3 * rs,
                outline_color = fc(67, 20, 5, 255)
            }, {
                thickness = 0.4 * rs,
                glow_color = fc(67, 20, 5, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_hunter = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(255, 179, 175, 255),
                c3 = fc(212, 68, 83, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(100, 0, 16, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(100, 0, 16, 255)
            }, {}}
        },
        hero_space_elf = {
            shader_args = {{
                sharpness = 20,
                margin = 1 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(230, 216, 247, 255),
                c2 = fc(176, 148, 248, 255),
                c3 = fc(94, 78, 204, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(51, 22, 127, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(51, 22, 127, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 2 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}

        },
        hero_raelyn = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(255, 183, 95, 255),
                c3 = fc(255, 98, 0, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(88, 19, 0, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(88, 19, 0, 255)
            }, {}}

        },
        hero_venom = {
            shader_args = {{
                margin = 2 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(231, 192, 255, 0),
                c2 = fc(209, 136, 255, 255),
                c3 = fc(128, 68, 190, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(61, 27, 86, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(61, 27, 86, 255)
            }, {}}

        },
        hero_dragon_gem = {
            shader_args = {{
                sharpness = 10,
                margin = 2 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 215, 154, 255),
                c2 = fc(255, 141, 98, 255),
                c3 = fc(175, 45, 0, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(91, 24, 0, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(91, 24, 0, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}

        },
        hero_witch = {
            single_line = true,
            shader_args = {{
                sharpness = 10,
                margin = 1 * rs,
                p1 = p21,
                p2 = p22,
                c1 = fc(255, 204, 241, 255),
                c2 = fc(255, 132, 186, 255),
                c3 = fc(206, 0, 119, 255)
            }, {
                thickness = 1.5 * rs,
                outline_color = fc(140, 0, 81, 255)
            }, {
                thickness = 0.2 * rs,
                glow_color = fc(140, 0, 81, 255)
            }, {
                shadow_width = 0.5 * rs,
                shadow_height = 3 * rs,
                shadow_color = fc(0, 0, 0, 255)
            }}
        },
        hero_dragon_bone = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 0),
                c2 = fc(228, 255, 95, 255),
                c3 = fc(107, 173, 0, 255)
            }, {
                thickness = 4.5 * rs,
                outline_color = fc(29, 51, 1, 255)
            }, {
                thickness = 1.5 * rs,
                glow_color = fc(29, 51, 1, 255)
            }, {}}

        },
        hero_lumenir = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(182, 232, 255, 255),
                c3 = fc(65, 178, 229, 255)
            }, {
                thickness = 2.5 * rs,
                outline_color = fc(0, 69, 100, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(0, 69, 100, 255)
            }, {}}

        },
        hero_wukong = {
            shader_args = {{
                margin = 0 * rs,
                p1 = p11,
                p2 = p12,
                c1 = fc(0, 0, 0, 255),
                c2 = fc(255, 252, 219, 255),
                c3 = fc(255, 224, 0, 255)
            }, {
                thickness = 2 * rs,
                outline_color = fc(107, 65, 0, 255)
            }, {
                thickness = 1 * rs,
                glow_color = fc(107, 65, 0, 255)
            }, {}}

        }
    },
    hero_data = { -- 爵士
    {
        portrait = 1,
        thumb = 1,
        name = "hero_gerald",
        available_level = 6,
        starting_level = 1,
        icon = 1,
        stats = {6, 5, 0, 4}
    }, -- 小公主
    {
        portrait = 2,
        thumb = 2,
        name = "hero_alleria",
        available_level = 5,
        starting_level = 1,
        icon = 2,
        stats = {4, 3, 5, 7}
    }, -- 大锤
    {
        portrait = 3,
        thumb = 3,
        name = "hero_malik",
        available_level = 3,
        starting_level = 1,
        icon = 3,
        stats = {8, 6, 0, 3}
    }, -- 波林
    {
        portrait = 4,
        thumb = 4,
        name = "hero_bolin",
        available_level = 7,
        starting_level = 1,
        icon = 4,
        stats = {7, 5, 4, 3}
    }, -- 小马哥
    {
        portrait = 5,
        thumb = 5,
        name = "hero_magnus",
        available_level = 6,
        starting_level = 1,
        icon = 5,
        stats = {3, 2, 7, 8}
    }, -- 火男
    {
        portrait = 6,
        thumb = 6,
        name = "hero_ignus",
        available_level = 11,
        starting_level = 1,
        icon = 6,
        stats = {7, 7, 0, 7}
    }, -- 国王
    {
        portrait = 7,
        thumb = 7,
        name = "hero_denas",
        available_level = 12,
        starting_level = 1,
        icon = 7,
        stats = {5, 5, 8, 3}
    }, -- 冰女
    {
        portrait = 8,
        thumb = 8,
        name = "hero_elora",
        available_level = 9,
        starting_level = 1,
        icon = 8,
        stats = {4, 3, 6, 7}
    }, -- 熊人
    {
        portrait = 9,
        thumb = 9,
        name = "hero_ingvar",
        available_level = 8,
        starting_level = 1,
        icon = 9,
        stats = {8, 6, 0, 5}
    }, -- 钢锯
    {
        portrait = 10,
        thumb = 10,
        name = "hero_hacksaw",
        available_level = 22,
        starting_level = 1,
        icon = 10,
        stats = {6, 5, 0, 2}
    }, -- 鬼侍
    {
        portrait = 11,
        thumb = 11,
        name = "hero_oni",
        available_level = 20,
        starting_level = 1,
        icon = 11,
        stats = {7, 8, 0, 6}
    }, -- 雷神
    {
        portrait = 12,
        thumb = 12,
        name = "hero_thor",
        available_level = 10,
        starting_level = 1,
        icon = 12,
        stats = {7, 5, 0, 6}
    }, -- 天十
    {
        portrait = 13,
        thumb = 13,
        name = "hero_10yr",
        available_level = 16,
        starting_level = 1,
        icon = 13,
        stats = {6, 5, 0, 8}
    }, --[[
			二代
		--]] -- 沙王
    {
        from_kr = 2,
        portrait = 1,
        thumb = 1,
        name = "hero_alric",
        available_level = 27,
        starting_level = 1,
        icon = 1,
        stats = {6, 5, 0, 4}
    }, -- 幻影
    {
        from_kr = 2,
        portrait = 2,
        thumb = 2,
        name = "hero_mirage",
        available_level = 30,
        starting_level = 1,
        icon = 2,
        stats = {4, 3, 5, 7}
    }, -- 船长
    {
        from_kr = 2,
        portrait = 3,
        thumb = 3,
        name = "hero_pirate",
        available_level = 31,
        starting_level = 1,
        icon = 3,
        stats = {5, 5, 5, 5}
    }, -- 大法师
    {
        from_kr = 2,
        portrait = 6,
        thumb = 6,
        name = "hero_wizard",
        available_level = 32,
        starting_level = 1,
        icon = 6,
        stats = {3, 2, 6, 8}
    }, -- 兽王
    {
        from_kr = 2,
        portrait = 4,
        thumb = 4,
        name = "hero_beastmaster",
        available_level = 33,
        starting_level = 1,
        icon = 4,
        stats = {7, 5, 0, 3}
    }, -- 女巫
    {
        from_kr = 2,
        portrait = 5,
        thumb = 5,
        name = "hero_voodoo_witch",
        available_level = 34,
        starting_level = 4,
        icon = 5,
        stats = {6, 5, 6, 5}
    }, -- 沙塔
    {
        from_kr = 2,
        portrait = 9,
        thumb = 9,
        name = "hero_alien",
        available_level = 35,
        starting_level = 1,
        icon = 9,
        stats = {4, 5, 0, 6}
    }, -- 武僧
    {
        from_kr = 2,
        portrait = 12,
        thumb = 12,
        name = "hero_monk",
        available_level = 36,
        starting_level = 1,
        icon = 12,
        stats = {6, 5, 0, 6}
    }, -- 猴神
    {
        from_kr = 2,
        portrait = 16,
        thumb = 16,
        name = "hero_monkey_god",
        available_level = 37,
        starting_level = 5,
        icon = 16,
        stats = {5, 5, 0, 7}
    }, -- 石头人
    {
        from_kr = 2,
        portrait = 8,
        thumb = 8,
        name = "hero_giant",
        available_level = 38,
        starting_level = 5,
        icon = 8,
        stats = {7, 5, 0, 2}
    }, -- 火龙
    {
        from_kr = 2,
        portrait = 10,
        thumb = 10,
        name = "hero_dragon",
        available_level = 39,
        starting_level = 1,
        icon = 10,
        stats = {7, 6, 5, 6}
    }, -- 女祭司
    {
        from_kr = 2,
        portrait = 7,
        thumb = 7,
        name = "hero_priest",
        available_level = 40,
        starting_level = 1,
        icon = 7,
        stats = {6, 3, 5, 8}
    }, -- 鲁林
    {
        from_kr = 2,
        portrait = 17,
        thumb = 17,
        name = "hero_dwarf",
        available_level = 40,
        starting_level = 1,
        icon = 17,
        stats = {7, 5, 0, 4}
    }, -- 牛头人
    {
        from_kr = 2,
        portrait = 15,
        thumb = 15,
        name = "hero_minotaur",
        available_level = 41,
        starting_level = 5,
        icon = 15,
        stats = {5, 5, 0, 5}
    }, -- 螃蟹
    {
        from_kr = 2,
        portrait = 11,
        thumb = 11,
        name = "hero_crab",
        available_level = 42,
        starting_level = 5,
        icon = 11,
        stats = {7, 5, 0, 6}
    }, -- 但丁
    {
        from_kr = 2,
        portrait = 13,
        thumb = 13,
        name = "hero_van_helsing",
        available_level = 45,
        starting_level = 1,
        icon = 13,
        stats = {6, 7, 5, 6}
    }, -- 骨龙
    {
        from_kr = 2,
        portrait = 14,
        thumb = 14,
        name = "hero_dracolich",
        available_level = 46,
        starting_level = 1,
        icon = 14,
        stats = {7, 5, 5, 6}
    }, -- 女吸血鬼
    {
        from_kr = 2,
        portrait = 18,
        thumb = 18,
        name = "hero_vampiress",
        available_level = 47,
        starting_level = 1,
        icon = 18,
        stats = {7, 6, 0, 6}
    }, --[[
			三代
		--]] -- 艾莉丹
    {
        from_kr = 3,
        portrait = 1,
        thumb = 1,
        name = "hero_elves_archer",
        available_level = 49,
        starting_level = 1,
        icon = 1,
        stats = {6, 5, 6, 6}
    }, -- 埃里汎
    {
        from_kr = 3,
        portrait = 2,
        thumb = 2,
        name = "hero_arivan",
        available_level = 51,
        starting_level = 3,
        icon = 2,
        stats = {5, 6, 6, 6}
    }, -- 树人
    {
        from_kr = 3,
        portrait = 7,
        thumb = 7,
        name = "hero_bravebark",
        available_level = 52,
        starting_level = 5,
        icon = 7,
        stats = {6, 5, 0, 7}
    }, -- 熊猫
    {
        from_kr = 3,
        portrait = 9,
        thumb = 9,
        name = "hero_xin",
        available_level = 53,
        starting_level = 5,
        icon = 9,
        stats = {6, 4, 0, 8}
    }, -- 王子迪纳斯
    {
        from_kr = 3,
        portrait = 5,
        thumb = 5,
        name = "hero_elves_denas",
        available_level = 54,
        starting_level = 5,
        icon = 5,
        stats = {7, 4, 0, 4}
    }, -- 大瑞格
    {
        from_kr = 3,
        portrait = 6,
        thumb = 6,
        name = "hero_rag",
        available_level = 56,
        starting_level = 5,
        icon = 6,
        stats = {5, 4, 4, 5}
    }, -- 水晶人
    {
        from_kr = 3,
        portrait = 11,
        thumb = 11,
        name = "hero_durax",
        available_level = 57,
        starting_level = 5,
        icon = 11,
        stats = {5, 8, 0, 7}
    }, -- 仙子
    {
        from_kr = 3,
        portrait = 3,
        thumb = 3,
        name = "hero_catha",
        available_level = 58,
        starting_level = 4,
        icon = 3,
        stats = {5, 3, 6, 6}
    }, -- 雷格森
    {
        from_kr = 3,
        portrait = 4,
        thumb = 4,
        name = "hero_regson",
        available_level = 59,
        starting_level = 5,
        icon = 4,
        stats = {7, 5, 0, 6}
    }, -- 堕天使
    {
        from_kr = 3,
        portrait = 14,
        thumb = 14,
        name = "hero_lilith",
        available_level = 60,
        starting_level = 5,
        icon = 14,
        stats = {6, 5, 5, 6}
    }, -- 火凤凰
    {
        from_kr = 3,
        portrait = 10,
        thumb = 10,
        name = "hero_phoenix",
        available_level = 61,
        starting_level = 5,
        icon = 10,
        stats = {5, 6, 0, 6}
    }, -- 浮士德
    {
        from_kr = 3,
        portrait = 16,
        thumb = 16,
        name = "hero_faustus",
        available_level = 62,
        starting_level = 5,
        icon = 16,
        stats = {6, 6, 6, 6}
    }, -- 维兹南
    {
        from_kr = 3,
        portrait = 8,
        thumb = 8,
        name = "hero_veznan",
        available_level = 63,
        starting_level = 5,
        icon = 8,
        stats = {3, 5, 0, 8}
    }, -- 狮王
    {
        from_kr = 3,
        portrait = 13,
        thumb = 13,
        name = "hero_bruce",
        available_level = 64,
        starting_level = 5,
        icon = 13,
        stats = {6, 6, 0, 5}
    }, -- 利恩
    {
        from_kr = 3,
        portrait = 12,
        thumb = 12,
        name = "hero_lynn",
        available_level = 67,
        starting_level = 5,
        icon = 12,
        stats = {6, 6, 0, 5}
    }, -- 飞机
    {
        from_kr = 3,
        portrait = 15,
        thumb = 15,
        name = "hero_wilbur",
        available_level = 69,
        starting_level = 5,
        icon = 15,
        stats = {6, 7, 5, 5}
    }, -- 波尔维克
    {
        from_kr = 3,
        portrait = 19,
        thumb = 19,
        name = "hero_bolverk",
        available_level = 70,
        starting_level = 5,
        icon = 19,
        stats = {5, 5, 0, 6}
    }, --[[
			五代
		--]] -- 安雅
    {
        from_kr = 5,
        portrait = 6,
        thumb = 6,
        name = "hero_hunter",
        available_level = 1,
        starting_level = 1,
        icon = 6,
        stats = {6, 5, 6, 7}
    }, -- 虚空法师
    {
        from_kr = 5,
        portrait = 7,
        thumb = 7,
        name = "hero_space_elf",
        available_level = 1,
        starting_level = 1,
        icon = 7,
        stats = {4, 4, 6, 8}
    }, -- 黑暗中尉
    {
        from_kr = 5,
        portrait = 2,
        thumb = 2,
        name = "hero_raelyn",
        available_level = 1,
        starting_level = 1,
        icon = 2,
        stats = {7, 6, 0, 3}
    }, -- 毒液
    {
        from_kr = 5,
        portrait = 4,
        thumb = 4,
        name = "hero_venom",
        available_level = 1,
        starting_level = 1,
        icon = 4,
        stats = {5, 5, 5, 6}
    }, -- 晶龙
    {
        from_kr = 5,
        portrait = 12,
        thumb = 12,
        name = "hero_dragon_gem",
        available_level = 1,
        starting_level = 1,
        icon = 12,
        stats = {7, 6, 5, 5}
    }, -- 小女巫
    {
        from_kr = 5,
        portrait = 13,
        thumb = 13,
        name = "hero_witch",
        available_level = 1,
        starting_level = 1,
        icon = 13,
        stats = {5, 4, 5, 7}
    }, -- 骨龙
    {
        from_kr = 5,
        portrait = 14,
        thumb = 14,
        name = "hero_dragon_bone",
        available_level = 1,
        starting_level = 1,
        icon = 14,
        stats = {6, 0, 5, 5}
    }, -- 圣龙
    {
        from_kr = 5,
        portrait = 11,
        thumb = 11,
        name = "hero_lumenir",
        available_level = 1,
        starting_level = 1,
        icon = 11,
        stats = {7, 0, 5, 5}
    }, -- 悟空
    {
        from_kr = 5,
        portrait = 18,
        thumb = 18,
        name = "hero_wukong",
        available_level = 1,
        starting_level = 1,
        icon = 18,
        stats = {5, 7, 4, 5}
    }},
    level_data = {
        {
            upgrades = {
                heroe = false,
                level = 1
            },
            iron = {"archers", "mages"}
        },
        {
            upgrades = {
                heroe = false,
                level = 2
            },
            iron = {"barracks"}
        },
        {
            upgrades = {
                heroe = false,
                level = 2
            },
            iron = {"artillery"}
        },
        {
            upgrades = {
                heroe = false,
                level = 2
            },
            iron = {"mages", "artillery"}
        },
        {
            upgrades = {
                heroe = false,
                level = 3
            },
            iron = {"barracks"}
        },
        {
            upgrades = {
                heroe = false,
                level = 3
            },
            iron = {"archers", "mages", "artillery"}
        },
        {
            upgrades = {
                heroe = false,
                level = 3
            },
            iron = {"barracks", "artillery"}
        },
        {
            upgrades = {
                heroe = false,
                level = 4
            },
            iron = {"archers", "mages"}
        },
        {
            upgrades = {
                heroe = false,
                level = 4
            },
            iron = {"archers", "barracks", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 4
            },
            iron = {"artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"artillery", "archers"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"artillery", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "barracks"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"barracks", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"barracks", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "barracks"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "artillery"}
        }, -- 2代
        {
            upgrades = {
                heroe = false,
                level = 1
            },
            iron = {"archers", "mages"}
        },
        {
            upgrades = {
                heroe = false,
                level = 2
            },
            iron = {"archers", "artillery"}
        },
        {
            upgrades = {
                heroe = false,
                level = 2
            },
            iron = {"artillery"}
        },
        {
            upgrades = {
                heroe = false,
                level = 2
            },
            iron = {"artillery", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 2
            },
            iron = {"barracks", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 3
            },
            iron = {"barracks", "archers"}
        },
        {
            upgrades = {
                heroe = true,
                level = 3
            },
            iron = {"artillery", "archers"}
        },
        {
            upgrades = {
                heroe = true,
                level = 3
            },
            iron = {"mages", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 4
            },
            iron = {"barracks", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 4
            },
            iron = {"artillery", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 4
            },
            iron = {"barracks", "archers"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"artillery", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages", "archers"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"artillery", "barracks"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "barracks"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"barracks", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"artillery", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "barracks"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"barracks", "mages"}
        }, -- 3代
        {
            upgrades = {
                heroe = true,
                level = 1
            },
            iron = {"archers", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 2
            },
            iron = {"mages", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 2
            },
            iron = {"archers", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 2
            },
            iron = {"barracks", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 2
            },
            iron = {"barracks", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 3
            },
            iron = {"archers", "barracks"}
        },
        {
            upgrades = {
                heroe = true,
                level = 3
            },
            iron = {"mages", "barracks"}
        },
        {
            upgrades = {
                heroe = true,
                level = 3
            },
            iron = {"mages", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 4
            },
            iron = {"barracks", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 4
            },
            iron = {"archers", "barracks"}
        },
        {
            upgrades = {
                heroe = true,
                level = 4
            },
            iron = {"barracks", "mages"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"barracks", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages", "archers"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages", "archers"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"barracks", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages", "artillery"}
        },
        {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "artillery"}
        },
        -- 额外
        [71] = {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"mages", "artillery"}
        },
        [90] = {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "artillery", "barracks"}
        },
        [110] = {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {"archers", "mages"}
        },
        [1000] = {
            upgrades = {
                heroe = true,
                level = 5
            },
            iron = {}
        }
    },
    tower_data = {{
        --     name = "tower_archer_1"
        -- }, {
        --     name = "tower_barrack_1"
        -- }, {
        --     name = "tower_mage_1"
        -- }, {
        --     name = "tower_engineer_1"
        -- }, {
        --     name = "tower_archer_2"
        -- }, {
        --     name = "tower_barrack_2"
        -- }, {
        --     name = "tower_mage_2"
        -- }, {
        --     name = "tower_engineer_2"
        -- }, {
        --     name = "tower_archer_3"
        -- }, {
        --     name = "tower_barrack_3"
        -- }, {
        --     name = "tower_mage_3"
        -- }, {
        --     name = "tower_engineer_3"
        -- },{
        name = "tower_ranger",
        icon = 13
    }, {
        name = "tower_paladin",
        icon = 14
    }, {
        name = "tower_arcane_wizard",
        icon = 15
    }, {
        name = "tower_bfg",
        icon = 16
    }, {
        name = "tower_musketeer",
        icon = 17
    }, {
        name = "tower_barbarian",
        icon = 18
    }, {
        name = "tower_sorcerer",
        icon = 19
    }, {
        name = "tower_tesla",
        icon = 20
    }, {
        name = "tower_crossbow",
        icon = 13
    }, {
        name = "tower_assassin",
        icon = 14
    }, {
        name = "tower_archmage",
        icon = 15
    }, {
        name = "tower_dwaarp",
        icon = 16
    }, {
        name = "tower_totem",
        icon = 17
    }, {
        name = "tower_templar",
        icon = 18
    }, {
        name = "tower_necromancer",
        icon = 19
    }, {
        name = "tower_mech",
        icon = 20
    }, {
        icon = 17,
        name = "tower_arcane"
    }, {
        icon = 20,
        name = "tower_blade"
    }, {
        icon = 16,
        name = "tower_wild_magus"
    }, {
        icon = 13,
        name = "tower_druid"
    }, {
        icon = 18,
        name = "tower_silver"
    }, {
        icon = 19,
        name = "tower_forest"
    }, {
        icon = 15,
        name = "tower_high_elven"
    }, {
        icon = 14,
        name = "tower_entwood"
    }},
    map_animations1 = {{
        sail_time = 15,
        id = "ma_big_boat",
        wait_in = 12.5,
        loop = true,
        wait_out = 15,
        layer = 2,
        pos = v(216, 900),
        fns = {
            prepare = deco_fn.ma_big_boat.prepare
        },
        pos_in = v(216, 900),
        pos_out = v(-80, 1000),
        animations = {
            in_sail = {
                to = 301,
                prefix = "bigBoat",
                from = 245
            },
            in_idle = {
                to = 167,
                prefix = "bigBoat",
                from = 85
            },
            out_sail = {
                to = 244,
                prefix = "bigBoat",
                from = 189
            },
            out_idle = {
                to = 84,
                prefix = "bigBoat",
                from = 1
            }
        }
    }, {
        loop = true,
        id = "ma_boats",
        layer = 2,
        pos = v(423, 955),
        animation = {
            to = 110,
            prefix = "boats",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_darkTower_fire",
        layer = 3,
        pos = v(1735, 673),
        animation = {
            to = 24,
            prefix = "darkTower_fire",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_darkTower_glow",
        layer = 3,
        pos = v(1735, 673),
        animation = {
            to = 96,
            prefix = "darkTower_glow",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_darkTower_fog",
        layer = 3,
        pos = v(1735, 705),
        scale = v(1.8, 1.8),
        animation = {
            to = 118,
            prefix = "darktower_fog",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_darkTower_river_left_glow",
        layer = 1,
        pos = v(1625, 794),
        animation = {
            to = 96,
            prefix = "darkTower_river_left_glow",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_darkTower_river_left_lava",
        layer = 1,
        pos = v(1627, 794),
        animation = {
            to = 52,
            prefix = "darkTower_river_left_lava",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_darkTower_river_right_glow",
        layer = 1,
        pos = v(1818, 794),
        animation = {
            to = 96,
            prefix = "darkTower_river_right_glow",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_darkTower_river_right_lava",
        layer = 1,
        pos = v(1819, 796),
        animation = {
            to = 52,
            prefix = "darkTower_river_right_lava",
            from = 1
        }
    }, {
        id = "ma_eagle",
        layer = 2,
        pos = v(958, 85),
        wait = {2, 3},
        animation = {
            to = 203,
            prefix = "eagle_1",
            from = 1
        }
    }, {
        id = "ma_fisher man",
        layer = 2,
        pos = v(456, 898),
        wait = {1, 5},
        animation = {
            to = 172,
            prefix = "fisherMan",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_flags",
        layer = 2,
        pos = v(771, 558),
        animation = {
            to = 15,
            prefix = "flags",
            from = 1
        }
    }, {
        id = "ma_ghost",
        layer = 2,
        pos = v(1485, 455),
        wait = {3, 12},
        animation = {
            to = 188,
            prefix = "ghost",
            from = 1
        }
    }, {
        id = "ma_north_lights",
        layer = 2,
        pos = v(1423, 272),
        wait = {8, 15},
        scale = v(0.8, 0.8),
        animation = {
            to = 25,
            prefix = "ma_north_lights",
            from = 1
        }
    }, {
        id = "ma_hacker",
        layer = 2,
        pos = v(378, 431),
        wait = {1, 3},
        animation = {
            to = 255,
            prefix = "hacker",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_light tower",
        layer = 2,
        pos = v(655, 948),
        animation = {
            to = 119,
            prefix = "lighTower",
            from = 1
        }
    }, {
        id = "ma_mobiDick",
        layer = 2,
        pos = v(1099, 55),
        wait = {2, 10},
        animation = {
            to = 224,
            prefix = "mobiDick",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_molinos1",
        layer = 2,
        pos = v(111, 781),
        animation = {
            to = 24,
            prefix = "molino",
            from = 1
        }
    }, {
        id = "ma_molinos2",
        template = "ma_molinos1",
        pos = v(145, 765)
    }, {
        id = "ma_molinos3",
        template = "ma_molinos1",
        pos = v(694, 805)
    }, {
        id = "ma_molinos4",
        template = "ma_molinos1",
        pos = v(721, 834)
    }, {
        id = "ma_molinos5",
        template = "ma_molinos1",
        pos = v(747, 799)
    }, {
        id = "ma_rottenBubbles1",
        layer = 2,
        pos = v(1757, 309),
        wait = {3, 12},
        animation = {
            to = 47,
            prefix = "rottenBubble",
            from = 1
        }
    }, {
        id = "ma_rottenBubbles2",
        template = "ma_rottenBubbles1",
        pos = v(1780, 313)
    }, {
        id = "ma_rottenBubbles3",
        template = "ma_rottenBubbles1",
        pos = v(1796, 283)
    }, {
        id = "ma_rottenBubbles4",
        template = "ma_rottenBubbles1",
        pos = v(1798, 300)
    }, {
        id = "ma_rottenBubbles5",
        template = "ma_rottenBubbles1",
        pos = v(1821, 304)
    }, {
        loop = true,
        id = "ma_rottenFog01",
        layer = 2,
        pos = v(1828, 208),
        animation = {
            to = 110,
            prefix = "rottenFogClip",
            from = 1
        }
    }, {
        id = "ma_rottenFog02",
        template = "ma_rottenFog01",
        pos = v(1880, 173)
    }, {
        id = "ma_rottenFog03",
        template = "ma_rottenFog01",
        pos = v(1807, 212),
        scale = v(1.5, 1.5)
    }, {
        id = "ma_rottenFog04",
        template = "ma_rottenFog01",
        pos = v(1695, 212),
        scale = v(1.7, 1.7)
    }, {
        id = "ma_rottenFog05",
        template = "ma_rottenFog01",
        pos = v(1743, 158),
        scale = v(1.5, 1.5)
    }, {
        id = "ma_rottenFog06",
        template = "ma_rottenFog01",
        pos = v(1699, 248),
        scale = v(1, 1)
    }, {
        id = "ma_rottenFog07",
        template = "ma_rottenFog01",
        pos = v(1637, 189),
        scale = v(1.3, 1.3)
    }, {
        id = "ma_rottenFog08",
        template = "ma_rottenFog01",
        pos = v(1581, 260),
        scale = v(1.5, 1.5)
    }, {
        id = "ma_rottenFog09",
        template = "ma_rottenFog01",
        pos = v(1600, 332),
        scale = v(1.1, 1.1)
    }, {
        id = "ma_rottenFog10",
        template = "ma_rottenFog01",
        pos = v(1642, 288),
        scale = v(1.3, 1.3)
    }, {
        id = "ma_rottenFog11",
        template = "ma_rottenFog01",
        pos = v(1700, 331),
        scale = v(1.4, 1.4)
    }, {
        id = "ma_rottenFog12",
        template = "ma_rottenFog01",
        pos = v(1794, 384),
        scale = v(1.6, 1.6)
    }, {
        id = "ma_rottenFog13",
        template = "ma_rottenFog01",
        pos = v(1862, 333),
        scale = v(1.7, 1.7)
    }, {
        id = "ma_sheep1",
        layer = 2,
        pos = v(240, 758),
        wait = {1, 8},
        animation = {
            to = 18,
            prefix = "sheep",
            from = 1
        }
    }, {
        id = "ma_sheep2",
        template = "ma_sheep1",
        pos = v(250, 775),
        scale = v(-1, 1)
    }, {
        id = "ma_sheep3",
        template = "ma_sheep1",
        pos = v(362, 807)
    }, {
        id = "ma_sheep4",
        template = "ma_sheep1",
        pos = v(664, 797),
        scale = v(-1, 1)
    }, {
        id = "ma_sheep5",
        template = "ma_sheep1",
        pos = v(757, 835)
    }, {
        id = "ma_sheepSmall1",
        layer = 2,
        pos = v(380, 817),
        wait = {1, 8},
        animation = {
            to = 18,
            prefix = "sheepSmall",
            from = 1
        }
    }, {
        id = "ma_sheepSmall2",
        template = "ma_sheepSmall1",
        pos = v(776, 845)
    }, {
        id = "ma_sheepSmall3",
        template = "ma_sheepSmall1",
        pos = v(227, 774),
        scale = v(-1, 1)
    }, {
        loop = true,
        id = "ma_smoke1",
        layer = 2,
        pos = v(436, 742),
        animation = {
            to = 30,
            prefix = "smoke",
            from = 1
        }
    }, {
        id = "ma_smoke2",
        template = "ma_smoke1",
        pos = v(534, 183)
    }, {
        loop = true,
        id = "ma_snow01",
        layer = 2,
        pos = v(1098, 136),
        animation = {
            to = 35,
            prefix = "snowClip",
            from = 1
        }
    }, {
        id = "ma_snow02",
        template = "ma_snow01",
        pos = v(1216, 155)
    }, {
        id = "ma_snow03",
        template = "ma_snow01",
        pos = v(1190, 281)
    }, {
        id = "ma_snow04",
        template = "ma_snow01",
        pos = v(1221, 362)
    }, {
        id = "ma_snow05",
        template = "ma_snow01",
        pos = v(1295, 226)
    }, {
        id = "ma_spider1",
        layer = 2,
        pos = v(431, 123),
        wait = {3, 6},
        animation = {
            to = 87,
            prefix = "spider_1",
            from = 1
        }
    }, {
        id = "ma_spider2",
        layer = 2,
        pos = v(431, 123),
        wait = {3, 6},
        animation = {
            to = 79,
            prefix = "spider_2",
            from = 1
        }
    }, {
        id = "ma_spider3",
        layer = 2,
        pos = v(431, 123),
        wait = {3, 6},
        animation = {
            to = 85,
            prefix = "spider_3",
            from = 1
        }
    }, {
        id = "ma_treant",
        layer = 2,
        pos = v(1869, 255),
        anchor = v(60, 40),
        fns = {
            prepare = deco_fn.ani_seq.prepare
        },
        animations = {
            default = {
                to = 1,
                prefix = "treant",
                from = 1
            },
            left = {
                to = 123,
                prefix = "treant",
                from = 1
            },
            right = {
                to = 246,
                prefix = "treant",
                from = 124
            }
        },
        sequence = {{"default", 3, 6}, {"left", 3, 6}, {"right", 3, 6}}
    }, {
        id = "ma_twister",
        layer = 2,
        pos = v(1409, 914),
        wait = {5, 15},
        animation = {
            to = 119,
            prefix = "twister",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_volcanoSmokes",
        layer = 2,
        pos = v(1448, 601),
        animation = {
            to = 52,
            prefix = "volcanoSmokes",
            from = 1
        }
    }, {
        id = "ma_volcanoes1",
        layer = 2,
        pos = v(1448, 604),
        wait = {3, 12},
        animation = {
            to = 62,
            prefix = "volcanos_1",
            from = 1
        }
    }, {
        id = "ma_volcanoes2",
        layer = 2,
        pos = v(1448, 604),
        wait = {3, 12},
        animation = {
            to = 62,
            prefix = "volcanos_2",
            from = 1
        }
    }, {
        id = "ma_volcanoes3",
        layer = 2,
        pos = v(1448, 604),
        wait = {3, 12},
        animation = {
            to = 62,
            prefix = "volcanos_3",
            from = 1
        }
    }, {
        id = "ma_volcanoes4",
        layer = 2,
        pos = v(1448, 604),
        wait = {3, 12},
        animation = {
            to = 62,
            prefix = "volcanos_4",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waterFall_1",
        layer = 2,
        pos = v(454, 290),
        animation = {
            to = 18,
            prefix = "waterFall_1",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waterFall_2",
        layer = 2,
        pos = v(58, 304),
        animation = {
            to = 32,
            prefix = "waterFall_2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waterFall_3",
        layer = 2,
        pos = v(1040, 835),
        animation = {
            to = 27,
            prefix = "waterFall_3",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waterWheel",
        layer = 2,
        pos = v(734, 891),
        animation = {
            to = 64,
            prefix = "waterWheel",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves1",
        layer = 1,
        pos = v(216, 930),
        animation = {
            to = 116,
            prefix = "waves1",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves2",
        layer = 1,
        pos = v(563, 929),
        animation = {
            to = 116,
            prefix = "waves2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves3",
        layer = 1,
        pos = v(897, 1047),
        animation = {
            to = 116,
            prefix = "waves3",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves4",
        layer = 1,
        pos = v(713, 60),
        animation = {
            to = 116,
            prefix = "waves4",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves5",
        layer = 1,
        pos = v(1183, 70),
        animation = {
            to = 116,
            prefix = "waves5",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_wavesBeach",
        layer = 1,
        pos = v(822, 967),
        animation = {
            to = 126,
            prefix = "wavesBeach",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_spark_01",
        layer = 1,
        pos = v(169, 938),
        animation = {
            to = 33,
            prefix = "waterSparks",
            from = 1
        }
    }, {
        id = "ma_spark_02",
        template = "ma_spark_01",
        pos = v(77, 972)
    }, {
        id = "ma_spark_03",
        template = "ma_spark_01",
        pos = v(239, 1019)
    }, {
        id = "ma_spark_04",
        template = "ma_spark_01",
        pos = v(368, 1015)
    }, {
        id = "ma_spark_05",
        template = "ma_spark_01",
        pos = v(345, 1074)
    }, {
        id = "ma_spark_06",
        template = "ma_spark_01",
        pos = v(515, 906)
    }, {
        id = "ma_spark_07",
        template = "ma_spark_01",
        pos = v(594, 932)
    }, {
        id = "ma_spark_08",
        template = "ma_spark_01",
        pos = v(536, 954)
    }, {
        id = "ma_spark_09",
        template = "ma_spark_01",
        pos = v(475, 994)
    }, {
        id = "ma_spark_10",
        template = "ma_spark_01",
        pos = v(431, 1049)
    }, {
        id = "ma_spark_11",
        template = "ma_spark_01",
        pos = v(579, 994)
    }, {
        id = "ma_spark_12",
        template = "ma_spark_01",
        pos = v(536, 1033)
    }, {
        id = "ma_spark_13",
        template = "ma_spark_01",
        pos = v(644, 1040)
    }, {
        id = "ma_spark_14",
        template = "ma_spark_01",
        pos = v(734, 1033)
    }, {
        id = "ma_spark_15",
        template = "ma_spark_01",
        pos = v(786, 1071)
    }, {
        id = "ma_spark_16",
        template = "ma_spark_01",
        pos = v(766, 1116)
    }, {
        id = "ma_spark_17",
        template = "ma_spark_01",
        pos = v(857, 762)
    }, {
        id = "ma_spark_18",
        template = "ma_spark_01",
        pos = v(489, 1082)
    }, {
        id = "ma_spark_19",
        template = "ma_spark_01",
        pos = v(594, 1076)
    }, {
        id = "ma_spark_20",
        template = "ma_spark_01",
        pos = v(697, 1085)
    }, {
        id = "ma_spark_21",
        template = "ma_spark_01",
        pos = v(631, 1119)
    }, {
        id = "ma_spark_22",
        template = "ma_spark_01",
        pos = v(550, 1116)
    }, {
        id = "ma_spark_23",
        template = "ma_spark_01",
        pos = v(421, 1108)
    }, {
        id = "ma_spark_24",
        template = "ma_spark_01",
        pos = v(271, 1119)
    }, {
        id = "ma_spark_25",
        template = "ma_spark_01",
        pos = v(197, 1074)
    }, {
        id = "ma_spark_26",
        template = "ma_spark_01",
        pos = v(156, 1116)
    }, {
        id = "ma_spark_27",
        template = "ma_spark_01",
        pos = v(41, 1100)
    }, {
        id = "ma_spark_28",
        template = "ma_spark_01",
        pos = v(731, -35)
    }, {
        id = "ma_spark_29",
        template = "ma_spark_01",
        pos = v(825, -18)
    }, {
        id = "ma_spark_30",
        template = "ma_spark_01",
        pos = v(788, 35)
    }, {
        id = "ma_spark_31",
        template = "ma_spark_01",
        pos = v(1042, -35)
    }, {
        id = "ma_spark_32",
        template = "ma_spark_01",
        pos = v(1078, 31)
    }, {
        id = "ma_spark_33",
        template = "ma_spark_01",
        pos = v(1155, 25)
    }, {
        id = "ma_spark_34",
        template = "ma_spark_01",
        pos = v(1221, -39)
    }, {
        id = "ma_spark_35",
        template = "ma_spark_01",
        pos = v(1130, -28)
    }, {
        random_start = true,
        alpha = 0.9,
        loop = true,
        id = "ma_cloud_1",
        layer = 3,
        scale = v(0.8, 0.8),
        move = {
            time = 60,
            from = v(-250, 1000),
            to = v(2250, 1020)
        },
        wait = {1, 60},
        animation = {
            to = 1,
            prefix = "ma_cloud",
            from = 1
        }
    }, {
        id = "ma_cloud_2",
        template = "ma_cloud_1",
        alpha = 0.6,
        scale = v(0.6, 0.6),
        move = {
            time = 70,
            from = v(-200, 1040),
            to = v(2100, 1040)
        }
    }, {
        id = "ma_cloud_3",
        template = "ma_cloud_1",
        alpha = 0.4,
        scale = v(0.7, 0.7),
        move = {
            time = 80,
            from = v(-200, 1090),
            to = v(2100, 1090)
        }
    }, {
        id = "ma_cloud_4",
        template = "ma_cloud_1",
        alpha = 0.6,
        scale = v(-0.4, 0.4),
        move = {
            time = 83,
            from = v(-200, 1050),
            to = v(2100, 1050)
        }
    }, {
        id = "ma_cloud_5",
        template = "ma_cloud_1",
        alpha = 0.9,
        scale = v(0.4, 0.4),
        move = {
            time = 90,
            from = v(-200, 1070),
            to = v(2100, 1070)
        }
    }, {
        id = "ma_cloud_6",
        template = "ma_cloud_1",
        alpha = 0.7,
        scale = v(-0.5, 0.5),
        move = {
            time = 60,
            from = v(-200, 990),
            to = v(2100, 1020)
        }
    }, {
        id = "ma_cloud_7",
        template = "ma_cloud_1",
        alpha = 0.5,
        scale = v(-0.6, 0.6),
        move = {
            time = 70,
            from = v(-200, 1030),
            to = v(2100, 1030)
        }
    }, {
        id = "ma_cloud_8",
        template = "ma_cloud_1",
        alpha = 0.6,
        scale = v(0.7, 0.7),
        move = {
            time = 65,
            from = v(-200, 1040),
            to = v(2100, 1040)
        }
    }, {
        id = "ma_cloud_t1",
        template = "ma_cloud_1",
        alpha = 0.9,
        scale = v(0.7, 0.7),
        move = {
            time = 60,
            from = v(-200, 0),
            to = v(2100, 0)
        }
    }, {
        id = "ma_cloud_t2",
        template = "ma_cloud_1",
        alpha = 0.6,
        scale = v(0.6, 0.6),
        move = {
            time = 70,
            from = v(-200, -20),
            to = v(2100, -20)
        }
    }, {
        id = "ma_cloud_t3",
        template = "ma_cloud_1",
        alpha = 0.9,
        scale = v(0.8, 0.8),
        move = {
            time = 80,
            from = v(-200, 10),
            to = v(2100, 10)
        }
    }, {
        id = "ma_cloud_t4",
        template = "ma_cloud_1",
        alpha = 0.6,
        scale = v(0.9, 0.9),
        move = {
            time = 90,
            from = v(-200, -5),
            to = v(2100, 0)
        }
    }, {
        id = "ma_cloud_t5",
        template = "ma_cloud_1",
        alpha = 0.5,
        scale = v(0.7, 0.7),
        move = {
            time = 70,
            from = v(-200, 0),
            to = v(2100, 0)
        }
    }, {
        id = "ma_cloud_t6",
        template = "ma_cloud_1",
        alpha = 0.9,
        scale = v(0.8, 0.8),
        move = {
            time = 80,
            from = v(-200, 10),
            to = v(2100, 10)
        }
    }},
    map_animations2 = {{
        loop = true,
        id = "ma_waterfall_left",
        layer = 1,
        pos = v(32, 192),
        animation = {
            to = 18,
            prefix = "ma_waterfall_left",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_oasis",
        layer = 1,
        pos = v(495, 514),
        animation = {
            to = 33,
            prefix = "ma_waterSparks",
            from = 1
        }
    }, {
        id = "ma_twister_1",
        layer = 1,
        pos = v(312, 183),
        wait = {10, 20},
        animation = {
            to = 119,
            prefix = "ma_twister_1",
            from = 1
        }
    }, {
        id = "ma_twister_2",
        layer = 1,
        pos = v(97, 467),
        wait = {10, 20},
        animation = {
            to = 119,
            prefix = "ma_twister_2",
            from = 1
        }
    }, {
        id = "ma_twister_3",
        layer = 1,
        pos = v(259, 386),
        wait = {10, 20},
        animation = {
            to = 119,
            prefix = "ma_twister_3",
            from = 1
        }
    }, {
        id = "ma_sandworm",
        layer = 1,
        pos = v(283, 490),
        wait = {20, 40},
        animation = {
            to = 81,
            prefix = "ma_sandworm",
            from = 1
        }
    }, {
        id = "ma_bantha_1",
        layer = 1,
        pos = v(53, 323),
        wait = {2, 4},
        animation = {
            to = 54,
            prefix = "ma_bantha",
            from = 1
        }
    }, {
        id = "ma_goat_1",
        layer = 1,
        pos = v(522, 642),
        wait = {3, 7},
        animation = {
            to = 32,
            prefix = "ma_goat",
            from = 1
        }
    }, {
        id = "ma_goat_2",
        template = "ma_goat_1",
        pos = v(464, 516),
        scale = v(-1, 1)
    }, {
        id = "ma_mini_volcano_a_1",
        layer = 1,
        pos = v(556, 16),
        wait = {5, 10},
        animation = {
            to = 60,
            prefix = "ma_mini_volcano_1",
            from = 1
        }
    }, {
        id = "ma_mini_volcano_a_2",
        template = "ma_mini_volcano_a_1",
        pos = v(954, 32)
    }, {
        id = "ma_mini_volcano_a_3",
        template = "ma_mini_volcano_a_1",
        pos = v(1043, 18)
    }, {
        loop = true,
        id = "ma_mini_volcano_a_smoke_1",
        layer = 1,
        pos = v(555, -5),
        animation = {
            to = 52,
            prefix = "ma_mini_volcano_smoke_1",
            from = 1
        }
    }, {
        id = "ma_mini_volcano_a_smoke_2",
        template = "ma_mini_volcano_a_smoke_1",
        pos = v(953, 10)
    }, {
        id = "ma_mini_volcano_a_smoke_3",
        template = "ma_mini_volcano_a_smoke_1",
        pos = v(1042, -3)
    }, {
        id = "ma_mini_volcano_a_smoke_4",
        template = "ma_mini_volcano_a_smoke_1",
        pos = v(370, 33)
    }, {
        id = "ma_mini_volcano_a_smoke_5",
        template = "ma_mini_volcano_a_smoke_1",
        pos = v(417, 11)
    }, {
        id = "ma_mini_volcano_b_1",
        layer = 1,
        pos = v(321, 33),
        wait = {5, 10},
        animation = {
            to = 60,
            prefix = "ma_mini_volcano_2",
            from = 1
        }
    }, {
        id = "ma_mini_volcano_b_2",
        template = "ma_mini_volcano_b_1",
        pos = v(997, 29)
    }, {
        loop = true,
        id = "ma_mini_volcano_b_smoke_1",
        layer = 1,
        pos = v(323, 6),
        animation = {
            to = 52,
            prefix = "ma_mini_volcano_smoke_2",
            from = 1
        }
    }, {
        id = "ma_mini_volcano_b_smoke_2",
        template = "ma_mini_volcano_b_smoke_1",
        pos = v(999, 2)
    }, {
        loop = true,
        id = "ma_north_river",
        layer = 1,
        pos = v(1119, 197),
        animation = {
            to = 30,
            prefix = "ma_north_river",
            from = 1
        }
    }, {
        id = "ma_north_lights",
        layer = 1,
        pos = v(986, 171),
        wait = {8, 15},
        animation = {
            to = 25,
            prefix = "ma_north_lights",
            from = 1
        }
    }, {
        id = "ma_skeleton",
        layer = 1,
        pos = v(1094, 222),
        wait = {10, 30},
        animation = {
            to = 129,
            prefix = "ma_skeleton",
            from = 1
        }
    }, {
        id = "ma_castle_window_1",
        toggle = true,
        layer = 1,
        pos = v(1269, 89),
        wait = {8, 25},
        animation = {
            to = 1,
            prefix = "ma_castle_window_1",
            from = 1
        }
    }, {
        id = "ma_castle_window_2",
        toggle = true,
        layer = 1,
        pos = v(1275, 100),
        wait = {8, 25},
        animation = {
            to = 1,
            prefix = "ma_castle_window_2",
            from = 1
        }
    }, {
        id = "ma_castle_window_3",
        toggle = true,
        layer = 1,
        pos = v(1303, 99),
        wait = {8, 25},
        animation = {
            to = 1,
            prefix = "ma_castle_window_3",
            from = 1
        }
    }, {
        id = "ma_castle_window_4",
        toggle = true,
        layer = 1,
        pos = v(1276, 126),
        wait = {8, 25},
        animation = {
            to = 1,
            prefix = "ma_castle_window_4",
            from = 1
        }
    }, {
        id = "ma_castle_window_5",
        toggle = true,
        layer = 1,
        pos = v(1286, 83),
        wait = {8, 25},
        animation = {
            to = 1,
            prefix = "ma_castle_window_5",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_castle_flame_1",
        layer = 1,
        pos = v(1258, 138),
        animation = {
            to = 12,
            prefix = "ma_castle_flame",
            from = 1
        }
    }, {
        id = "ma_castle_flame_2",
        template = "ma_castle_flame_1",
        pos = v(1282, 148)
    }, {
        id = "ma_lava_1_glow",
        layer = 1,
        pos = v(585, 133),
        wait = {5, 10},
        animation = {
            to = 96,
            prefix = "ma_lava_1_glow",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_lava_1",
        layer = 1,
        pos = v(593, 127),
        animation = {
            to = 45,
            prefix = "ma_lava_1",
            from = 1
        }
    }, {
        id = "ma_lava_2_glow",
        layer = 1,
        pos = v(759, 126),
        wait = {5, 10},
        animation = {
            to = 96,
            prefix = "ma_lava_2_glow",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_lava_2",
        layer = 1,
        pos = v(747, 107),
        animation = {
            to = 46,
            prefix = "ma_lava_2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_lava_sparks_1",
        layer = 1,
        pos = v(1219, 430),
        animation = {
            to = 81,
            prefix = "ma_lava_sparks",
            from = 1
        }
    }, {
        id = "ma_lava_sparks_2",
        template = "ma_lava_sparks_1",
        pos = v(1302, 358),
        scale = v(0.8, 0.8)
    }, {
        id = "ma_lava_sparks_3",
        template = "ma_lava_sparks_1",
        pos = v(1242, 362),
        scale = v(0.7, 0.7)
    }, {
        loop = true,
        id = "ma_lava_smoke",
        layer = 1,
        pos = v(1257, 375),
        animation = {
            to = 66,
            prefix = "ma_lava_smoke",
            from = 1
        }
    }, {
        id = "ma_diamond",
        layer = 1,
        pos = v(1522, 349),
        wait = {3, 6},
        animation = {
            to = 70,
            prefix = "ma_diamond",
            from = 1
        }
    }, {
        id = "ma_mountain_lava_1",
        layer = 1,
        pos = v(1539, 142),
        wait = {3, 6},
        animation = {
            to = 80,
            prefix = "ma_mountain_lava_1",
            from = 1
        }
    }, {
        alpha = 0.8,
        id = "ma_mountain_lava_2",
        layer = 1,
        pos = v(1520, 187),
        wait = {3, 6},
        animation = {
            to = 60,
            prefix = "ma_mountain_lava_2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_mountain_sparks",
        layer = 1,
        pos = v(1542, 142),
        animation = {
            to = 80,
            prefix = "ma_mountain_sparks",
            from = 1
        }
    }, {
        id = "ma_mountain_sparks_2",
        template = "ma_mountain_sparks",
        alpha = 0.8,
        pos = v(1542, 130),
        scale = v(0.8, 0.8)
    }, {
        loop = true,
        id = "ma_river_l",
        layer = 1,
        pos = v(1231, 797),
        animation = {
            to = 18,
            prefix = "ma_river_l",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_river_r",
        layer = 1,
        pos = v(1561, 636),
        animation = {
            to = 18,
            prefix = "ma_river_r",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_falls_left",
        layer = 1,
        pos = v(1064, 578),
        animation = {
            to = 18,
            prefix = "ma_falls_left",
            from = 1
        }
    }, {
        loop = true,
        layer = 1,
        id = "ma_bottle_1",
        path = ani_paths2.ma_bottle_1,
        wait = {10, 20},
        animation = {
            to = 27,
            prefix = "ma_bottle_loop",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_bottle_cover",
        layer = 1,
        pos = v(1217, 722),
        animation = {
            to = 1,
            prefix = "ma_bottle_cover",
            from = 1
        }
    }, {
        id = "ma_monkey_vine_1",
        layer = 1,
        pos = v(977, 602),
        wait = {15, 30},
        animation = {
            to = 82,
            prefix = "ma_monkey_vine_1",
            from = 1
        }
    }, {
        id = "ma_monkey_vine_2",
        layer = 1,
        pos = v(1131, 686),
        wait = {25, 25},
        animation = {
            to = 56,
            prefix = "ma_monkey_vine_2",
            from = 1
        }
    }, {
        id = "ma_monkey_vine_3",
        layer = 1,
        pos = v(1593, 636),
        wait = {30, 45},
        animation = {
            to = 55,
            prefix = "ma_monkey_vine_3",
            from = 1
        }
    }, {
        id = "ma_monkey_shout_1",
        layer = 1,
        pos = v(971, 854),
        scale = v(-1, 1),
        wait = {20, 45},
        animation = {
            to = 85,
            prefix = "ma_monkey_shout",
            from = 1
        }
    }, {
        id = "ma_monkey_shout_2",
        layer = 1,
        pos = v(1303, 731),
        wait = {20, 45},
        animation = {
            to = 85,
            prefix = "ma_monkey_shout",
            from = 1
        }
    }, {
        id = "ma_monkey_shout_3",
        layer = 1,
        pos = v(1745, 546),
        wait = {20, 45},
        animation = {
            to = 85,
            prefix = "ma_monkey_shout",
            from = 1
        }
    }, {
        id = "ma_volcano_bubble",
        layer = 1,
        pos = v(1440, 610),
        wait = {1, 2},
        animation = {
            to = 70,
            prefix = "ma_volcano_bubble",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_volcano_smoke",
        layer = 1,
        pos = v(1441, 535),
        animation = {
            to = 52,
            prefix = "ma_volcano_smoke",
            from = 1
        }
    }, {
        id = "ma_alien_ship",
        layer = 1,
        pos = v(1565, 783),
        wait = {1, 3},
        animation = {
            to = 80,
            prefix = "ma_alien_ship",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves_1",
        layer = 1,
        pos = v(66, 658),
        animation = {
            to = 120,
            prefix = "ma_waves_1",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves_2",
        layer = 1,
        pos = v(111, 797),
        animation = {
            to = 120,
            prefix = "ma_waves_2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves_3",
        layer = 1,
        pos = v(120, 987),
        animation = {
            to = 120,
            prefix = "ma_waves_3",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves_4",
        layer = 1,
        pos = v(513, 1014),
        animation = {
            to = 120,
            prefix = "ma_waves_4",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves_5",
        layer = 1,
        pos = v(373, 865),
        animation = {
            to = 120,
            prefix = "ma_waves_5",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves_6",
        layer = 1,
        pos = v(328, 647),
        animation = {
            to = 120,
            prefix = "ma_waves_6",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves_7",
        layer = 1,
        pos = v(339, 775),
        animation = {
            to = 120,
            prefix = "ma_waves_7",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_waves_8",
        layer = 1,
        pos = v(107, 910),
        animation = {
            to = 120,
            prefix = "ma_waves_8",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_beach_1",
        layer = 1,
        pos = v(502, 924),
        wait = {5, 5},
        animation = {
            to = 135,
            prefix = "ma_beach_1",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_beach_2",
        layer = 1,
        pos = v(269, 636),
        wait = {5, 5},
        animation = {
            to = 131,
            prefix = "ma_beach_2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_beach_3",
        layer = 1,
        pos = v(301, 990),
        wait = {5, 5},
        animation = {
            to = 131,
            prefix = "ma_beach_3",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_beach_4",
        layer = 1,
        pos = v(173, 966),
        wait = {5, 5},
        animation = {
            to = 131,
            prefix = "ma_beach_4",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_water_sparks_1",
        layer = 1,
        pos = v(66, 706),
        animation = {
            to = 33,
            prefix = "ma_waterSparks",
            from = 1
        }
    }, {
        id = "ma_water_sparks_2",
        template = "ma_water_sparks_1",
        pos = v(3, 764)
    }, {
        id = "ma_water_sparks_3",
        template = "ma_water_sparks_1",
        pos = v(17, 891)
    }, {
        id = "ma_water_sparks_4",
        template = "ma_water_sparks_1",
        pos = v(7, 1006)
    }, {
        id = "ma_water_sparks_5",
        template = "ma_water_sparks_1",
        pos = v(63, 933)
    }, {
        id = "ma_water_sparks_6",
        template = "ma_water_sparks_1",
        pos = v(65, 829)
    }, {
        id = "ma_water_sparks_7",
        template = "ma_water_sparks_1",
        pos = v(35, 1077)
    }, {
        id = "ma_water_sparks_8",
        template = "ma_water_sparks_1",
        pos = v(105, 1031)
    }, {
        id = "ma_water_sparks_9",
        template = "ma_water_sparks_1",
        pos = v(179, 1070)
    }, {
        id = "ma_water_sparks_10",
        template = "ma_water_sparks_1",
        pos = v(260, 1020)
    }, {
        id = "ma_water_sparks_11",
        template = "ma_water_sparks_1",
        pos = v(288, 1080)
    }, {
        id = "ma_water_sparks_12",
        template = "ma_water_sparks_1",
        pos = v(396, 1058)
    }, {
        id = "ma_water_sparks_13",
        template = "ma_water_sparks_1",
        pos = v(458, 964)
    }, {
        id = "ma_water_sparks_14",
        template = "ma_water_sparks_1",
        pos = v(179, 670)
    }, {
        id = "ma_water_sparks_15",
        template = "ma_water_sparks_1",
        pos = v(475, 1030)
    }, {
        id = "ma_water_sparks_16",
        template = "ma_water_sparks_1",
        pos = v(223, 834)
    }, {
        id = "ma_water_sparks_17",
        template = "ma_water_sparks_1",
        pos = v(307, 787)
    }, {
        id = "ma_water_sparks_18",
        template = "ma_water_sparks_1",
        pos = v(325, 936)
    }, {
        id = "ma_tentacle",
        layer = 1,
        pos = v(351, 1012),
        wait = {22, 45},
        animation = {
            to = 140,
            prefix = "ma_tentacle",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_lighthouse_light",
        layer = 1,
        pos = v(122, 965),
        animation = {
            to = 119,
            prefix = "ma_lighthouse_light",
            from = 1
        }
    }, {
        id = "ma_ship_left",
        layer = 2,
        pos = v(115, 742),
        wait = {15, 30},
        animation = {
            to = 505,
            prefix = "ma_ship",
            from = 1
        }
    }, {
        id = "ma_snapvine",
        layer = 2,
        pos = v(1345, 867),
        wait = {15, 30},
        animation = {
            to = 20,
            prefix = "ma_snapvine",
            from = 1
        }
    }, {
        id = "ma_vulture",
        layer = 3,
        pos = v(80, 480),
        wait = {20, 40},
        animation = {
            to = 160,
            prefix = "ma_vulture",
            from = 1
        }
    }, {
        loop = true,
        layer = 3,
        id = "ma_bat_1",
        path = ani_paths2.ma_bat_1,
        wait = {3, 10},
        animation = {
            to = 8,
            prefix = "ma_bat_loop",
            from = 1
        }
    }, {
        loop = true,
        layer = 3,
        id = "ma_bat_2",
        path = ani_paths2.ma_bat_2,
        wait = {3, 10},
        animation = {
            to = 8,
            prefix = "ma_bat_loop",
            from = 1
        }
    }, {
        loop = true,
        layer = 3,
        id = "ma_bat_3",
        path = ani_paths2.ma_bat_3,
        wait = {3, 10},
        animation = {
            to = 8,
            prefix = "ma_bat_loop",
            from = 1
        }
    }, {
        loop = true,
        layer = 3,
        id = "ma_bat_4",
        path = ani_paths2.ma_bat_4,
        wait = {3, 10},
        animation = {
            to = 8,
            prefix = "ma_bat_loop",
            from = 1
        }
    }, {
        loop = true,
        layer = 3,
        id = "ma_bat_5",
        path = ani_paths2.ma_bat_5,
        wait = {3, 10},
        animation = {
            to = 8,
            prefix = "ma_bat_loop",
            from = 1
        }
    }, {
        loop = true,
        layer = 3,
        id = "ma_big_bird",
        path = ani_paths2.ma_big_bird_1,
        wait = {10, 20},
        animation = {
            to = 24,
            prefix = "ma_big_bird_loop",
            from = 1
        }
    }, {
        loop = true,
        layer = 3,
        id = "ma_jungle_bird_1",
        path = ani_paths2.ma_jungle_bird_1,
        wait = {10, 20},
        scale = v(0.6, 0.6),
        animation = {
            to = 8,
            prefix = "ma_jungle_bird_1",
            from = 1
        }
    }, {
        loop = true,
        layer = 3,
        id = "ma_jungle_bird_2",
        path = ani_paths2.ma_jungle_bird_2,
        wait = {10, 20},
        scale = v(0.6, 0.6),
        animation = {
            to = 8,
            prefix = "ma_jungle_bird_2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_emberspike_cloud",
        layer = 3,
        pos = v(1535, 150),
        scale = v(1.4, 1.4),
        animation = {
            to = 118,
            prefix = "darktower_fog",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_cloud_1",
        layer = 3,
        alpha = 0.8,
        scale = v(0.8, 0.8),
        move = {
            time = 60,
            from = v(-250, 1020),
            to = v(2250, 1020)
        },
        wait = {1, 60},
        animation = {
            to = 1,
            prefix = "ma_cloud",
            from = 1
        }
    }, {
        id = "ma_cloud_2",
        template = "ma_cloud_1",
        alpha = 0.6,
        scale = v(0.6, 0.6),
        move = {
            time = 70,
            from = v(-200, 1040),
            to = v(2100, 1040)
        }
    }, {
        id = "ma_cloud_3",
        template = "ma_cloud_1",
        alpha = 0.4,
        scale = v(0.7, 0.7),
        move = {
            time = 80,
            from = v(-200, 1090),
            to = v(2100, 1090)
        }
    }, {
        id = "ma_cloud_4",
        template = "ma_cloud_1",
        alpha = 0.4,
        scale = v(-0.4, 0.4),
        move = {
            time = 83,
            from = v(-200, 1050),
            to = v(2100, 1050)
        }
    }, {
        id = "ma_cloud_5",
        template = "ma_cloud_1",
        alpha = 0.5,
        scale = v(0.4, 0.4),
        move = {
            time = 90,
            from = v(-200, 1070),
            to = v(2100, 1070)
        }
    }, {
        id = "ma_cloud_6",
        template = "ma_cloud_1",
        alpha = 0.7,
        scale = v(-0.5, 0.5),
        move = {
            time = 60,
            from = v(-200, 1020),
            to = v(2100, 1020)
        }
    }, {
        id = "ma_cloud_7",
        template = "ma_cloud_1",
        alpha = 0.5,
        scale = v(-0.6, 0.6),
        move = {
            time = 70,
            from = v(-200, 1030),
            to = v(2100, 1030)
        }
    }, {
        id = "ma_cloud_8",
        template = "ma_cloud_1",
        alpha = 0.6,
        scale = v(0.7, 0.7),
        move = {
            time = 65,
            from = v(-200, 1040),
            to = v(2100, 1040)
        }
    }, {
        id = "ma_cloud_t1",
        template = "ma_cloud_1",
        alpha = 0.4,
        scale = v(0.7, 0.7),
        move = {
            time = 60,
            from = v(-200, 0),
            to = v(2100, 0)
        }
    }, {
        id = "ma_cloud_t2",
        template = "ma_cloud_1",
        alpha = 0.6,
        scale = v(0.6, 0.6),
        move = {
            time = 70,
            from = v(-200, -20),
            to = v(2100, -20)
        }
    }, {
        id = "ma_cloud_t3",
        template = "ma_cloud_1",
        alpha = 0.6,
        scale = v(0.8, 0.8),
        move = {
            time = 80,
            from = v(-200, 10),
            to = v(2100, 10)
        }
    }, {
        id = "ma_cloud_t4",
        template = "ma_cloud_1",
        alpha = 0.4,
        scale = v(0.9, 0.9),
        move = {
            time = 90,
            from = v(-200, -5),
            to = v(2100, 0)
        }
    }, {
        id = "ma_cloud_t5",
        template = "ma_cloud_1",
        alpha = 0.5,
        scale = v(0.7, 0.7),
        move = {
            time = 70,
            from = v(-200, 0),
            to = v(2100, 0)
        }
    }, {
        id = "ma_cloud_t6",
        template = "ma_cloud_1",
        alpha = 0.4,
        scale = v(0.8, 0.8),
        move = {
            time = 80,
            from = v(-200, 10),
            to = v(2100, 10)
        }
    }},
    map_animations3 = {{
        id = "ma_george_shout_1",
        layer = 1,
        wait = {2, 6},
        animation = {
            to = 103,
            prefix = "ma_george_shout",
            from = 1
        },
        pos_list = {v(153, 484), v(153, 528), v(97, 490), v(210, 511), v(439, 553), v(152, 690)},
        scale_list = {v(-1, 1), v(1, 1), v(1, 1), v(-1, 1), v(1, 1), v(-1, 1)}
    }, {
        id = "ma_venom_vine_1",
        layer = 1,
        pos = v(785, 664),
        wait = {8, 12},
        action_animation = {
            to = 79,
            prefix = "ma_venom_vine",
            from = 49
        },
        idle_animation = {
            to = 48,
            prefix = "ma_venom_vine",
            from = 1
        }
    }, {
        id = "ma_ft_bubbles",
        layer = 1,
        pos = v(1364, 263),
        wait = {1, 3},
        animation = {
            to = 74,
            prefix = "ma_ft_bubbles",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_ft_smoke",
        layer = 1,
        pos = v(1369, 218),
        animation = {
            to = 60,
            prefix = "ma_ft_smoke",
            from = 1
        }
    }, {
        id = "ma_hr_crystals",
        layer = 1,
        pos = v(793, 196),
        wait = {8, 12},
        animation = {
            to = 32,
            prefix = "ma_hr_crystals",
            from = 1
        }
    }, {
        id = "ma_hr_sparks",
        layer = 1,
        pos = v(793, 194),
        wait = {4, 8},
        animation = {
            to = 42,
            prefix = "ma_hr_sparks",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_lake_water_sparks",
        layer = 1,
        pos = v(845, 503),
        animation = {
            to = 24,
            prefix = "ma_lake_water_sparks",
            from = 1
        }
    }, {
        id = "ma_lake_crystals",
        layer = 1,
        pos = v(848, 495),
        wait = {8, 12},
        animation = {
            to = 43,
            prefix = "ma_lake_crystals",
            from = 1
        }
    }, {
        id = "ma_lake_sparks",
        layer = 1,
        pos = v(845, 495),
        wait = {4, 8},
        animation = {
            to = 45,
            prefix = "ma_lake_sparks",
            from = 1
        }
    }, {
        id = "ma_lake_serpent",
        layer = 1,
        wait = {6, 12},
        pos_list = {v(846, 496), v(846, 496)},
        scale_list = {v(1, 1), v(-1, 1)},
        animation = {
            to = 66,
            prefix = "ma_lake_serpent",
            from = 1
        }
    }, {
        id = "ma_metro_spider_1",
        layer = 2,
        pos = v(1721, 632),
        wait = {3, 5},
        animation = {
            to = 35,
            prefix = "ma_metro_spider_1",
            from = 1
        }
    }, {
        id = "ma_metro_spider_2",
        layer = 2,
        pos = v(1783, 671),
        wait = {3, 5},
        animation = {
            to = 36,
            prefix = "ma_metro_spider_2",
            from = 1
        }
    }, {
        id = "ma_metro_spider_3",
        layer = 2,
        pos = v(1721, 753),
        wait = {3, 5},
        animation = {
            to = 34,
            prefix = "ma_metro_spider_3",
            from = 1
        }
    }, {
        id = "ma_br_tree",
        layer = 1,
        pos = v(1541, 375),
        wait = {4, 8},
        action_animation = {
            to = 89,
            prefix = "ma_br_tree",
            from = 40
        },
        idle_animation = {
            to = 39,
            prefix = "ma_br_tree",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_br_castle_flame",
        layer = 1,
        pos = v(1767, 231),
        animation = {
            to = 14,
            prefix = "ma_br_castle_flame",
            from = 1
        }
    }, {
        id = "ma_br_castle_glow",
        layer = 1,
        pos = v(1769, 266),
        wait = {1, 3},
        animation = {
            to = 90,
            prefix = "ma_br_castle_glow",
            from = 1
        }
    }, {
        id = "ma_broom",
        layer = 1,
        pos = v(1662, 480),
        wait = {4, 10},
        animation = {
            to = 166,
            prefix = "ma_broom",
            from = 1
        }
    }, {
        layer = 3,
        id = "ma_gryphon",
        move = {
            time = 8,
            from = v(-30, 700),
            to = v(1000, 1200)
        },
        wait = {10, 20},
        animation = {
            to = 16,
            prefix = "ma_gryphon",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_hr_worker",
        layer = 1,
        pos = v(724, 231),
        animation = {
            to = 34,
            prefix = "ma_hr_worker",
            from = 1
        }
    }, {
        id = "ma_hr_worker_2",
        layer = 1,
        pos = v(804, 227),
        wait = {4, 10},
        animation = {
            to = 143,
            prefix = "ma_hr_worker_2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_lake_waterfall",
        layer = 1,
        pos = v(801, 503),
        animation = {
            to = 20,
            prefix = "ma_lake_waterfall",
            from = 1
        }
    }, {
        id = "ma_magic_flower_1",
        layer = 2,
        pos = v(498, 831),
        wait = {3, 6},
        action_animation = {
            to = 66,
            prefix = "ma_magic_flower",
            from = 36
        },
        idle_animation = {
            to = 35,
            prefix = "ma_magic_flower",
            from = 1
        }
    }, {
        id = "ma_magic_flower_2",
        template = "ma_magic_flower_1",
        pos = v(380, 279),
        wait = {4, 8}
    }, {
        loop = true,
        id = "ma_metro_diamond",
        layer = 1,
        pos = v(1798, 508),
        animation = {
            to = 147,
            prefix = "ma_metro_diamond",
            from = 1
        }
    }, {
        loop = true,
        layer = 3,
        id = "ma_metro_ducks",
        move = {
            time = 10,
            from = v(800, 1100),
            to = v(1950, 500)
        },
        wait = {10, 30},
        animation = {
            to = 8,
            prefix = "ma_metro_ducks",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_pixie_1",
        layer = 1,
        pos = v(1107, 408),
        animation = {
            to = 21,
            prefix = "ma_pixie_1",
            from = 1
        }
    }, {
        id = "ma_pixie_2",
        layer = 1,
        pos = v(1042, 425),
        wait = {5, 15},
        animation = {
            to = 77,
            prefix = "ma_pixie_2",
            from = 1
        }
    }, {
        loop = true,
        alpha = 1,
        id = "ma_waterfall1_foam",
        layer = 1,
        pos = v(86, 439),
        animation = {
            to = 20,
            prefix = "ma_waterfall1_foam",
            from = 1
        }
    }, {
        loop = true,
        alpha = 0.5,
        id = "ma_waterfall1_sparks",
        layer = 1,
        pos = v(67, 394),
        animation = {
            to = 20,
            prefix = "ma_waterfall1_sparks",
            from = 1
        }
    }, {
        loop = true,
        alpha = 0.5,
        id = "ma_waterfall1_sparks_top",
        layer = 1,
        pos = v(45, 334),
        animation = {
            to = 20,
            prefix = "ma_waterfall1_sparks_top",
            from = 1
        }
    }, {
        loop = true,
        alpha = 1,
        id = "ma_waterfall2_foam",
        layer = 1,
        pos = v(170, 470),
        animation = {
            to = 20,
            prefix = "ma_waterfall2_foam",
            from = 1
        }
    }, {
        loop = true,
        alpha = 0.5,
        id = "ma_waterfall2_sparks",
        layer = 1,
        pos = v(167, 419),
        animation = {
            to = 20,
            prefix = "ma_waterfall2_sparks",
            from = 1
        }
    }, {
        id = "ma_wolf",
        layer = 1,
        pos = v(920, 661),
        wait = {4, 10},
        animation = {
            to = 45,
            prefix = "ma_wolf",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_f_castle_glows",
        layer = 1,
        pos = v(1343, 535),
        animation = {
            to = 120,
            prefix = "ma_f_casle_glows",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_f_castle_spotlights",
        layer = 1,
        pos = v(1349, 536),
        animation = {
            to = 120,
            prefix = "ma_f_casle_spotlights",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_wisps_1_1",
        layer = 1,
        pos = v(1000, 552),
        animation = {
            to = 84,
            prefix = "wisps_1",
            from = 1
        }
    }, {
        id = "ma_wisps_1_2",
        template = "ma_wisps_1_1",
        pos = v(900, 628)
    }, {
        id = "ma_wisps_1_3",
        template = "ma_wisps_1_1",
        pos = v(1312, 407)
    }, {
        id = "ma_wisps_1_4",
        template = "ma_wisps_1_1",
        pos = v(1140, 449)
    }, {
        id = "ma_wisps_1_5",
        template = "ma_wisps_1_1",
        pos = v(1155, 908)
    }, {
        loop = true,
        id = "ma_wisps_2_1",
        layer = 1,
        pos = v(1018, 462),
        animation = {
            to = 84,
            prefix = "wisps_2",
            from = 1
        }
    }, {
        id = "ma_wisps_2_2",
        template = "ma_wisps_2_1",
        pos = v(1258, 338)
    }, {
        id = "ma_wisps_2_3",
        template = "ma_wisps_2_1",
        pos = v(976, 348)
    }, {
        id = "ma_wisps_2_4",
        template = "ma_wisps_2_1",
        pos = v(1139, 723)
    }, {
        id = "ma_wisps_2_5",
        template = "ma_wisps_2_1",
        pos = v(886, 928)
    }, {
        loop = true,
        id = "ma_wisps_3_1",
        layer = 1,
        pos = v(1177, 608),
        animation = {
            to = 84,
            prefix = "wisps_3",
            from = 1
        }
    }, {
        id = "ma_wisps_3_2",
        template = "ma_wisps_3_1",
        pos = v(940, 1005)
    }, {
        id = "ma_wisps_3_3",
        template = "ma_wisps_3_1",
        pos = v(1063, 747)
    }, {
        id = "ma_wisps_3_4",
        template = "ma_wisps_3_1",
        pos = v(1376, 361)
    }, {
        id = "ma_wisps_3_5",
        template = "ma_wisps_3_1",
        pos = v(1086, 313)
    }, {
        loop = true,
        id = "ma_wisps_4_1",
        layer = 1,
        pos = v(1238, 556),
        animation = {
            to = 84,
            prefix = "wisps_4",
            from = 1
        }
    }, {
        id = "ma_wisps_4_2",
        template = "ma_wisps_4_1",
        pos = v(1161, 812)
    }, {
        id = "ma_wisps_4_3",
        template = "ma_wisps_4_1",
        pos = v(1048, 901)
    }, {
        id = "ma_wisps_4_4",
        template = "ma_wisps_4_1",
        pos = v(856, 418)
    }, {
        id = "ma_wisps_4_5",
        template = "ma_wisps_4_1",
        pos = v(885, 816)
    }, {
        id = "ma_wisps_5_1",
        layer = 1,
        pos = v(1256, 679),
        wait = {2, 6},
        animation = {
            to = 58,
            prefix = "wisps_5",
            from = 1
        }
    }, {
        id = "ma_wisps_5_2",
        template = "ma_wisps_5_1",
        pos = v(1082, 641)
    }, {
        id = "ma_wisps_6_1",
        layer = 1,
        pos = v(1194, 332),
        wait = {2, 6},
        animation = {
            to = 26,
            prefix = "wisps_6",
            from = 1
        }
    }, {
        id = "ma_wisps_6_2",
        template = "ma_wisps_6_1",
        pos = v(1179, 421)
    }, {
        id = "ma_wisps_7_1",
        layer = 1,
        pos = v(975, 396),
        wait = {2, 6},
        animation = {
            to = 40,
            prefix = "wisps_7",
            from = 1
        }
    }, {
        id = "ma_wisps_7_2",
        template = "ma_wisps_7_1",
        pos = v(801, 460)
    }, {
        id = "ma_wisps_8_1",
        layer = 1,
        pos = v(1074, 414),
        wait = {2, 6},
        animation = {
            to = 26,
            prefix = "wisps_8",
            from = 1
        }
    }, {
        id = "ma_wisps_8_2",
        template = "ma_wisps_8_1",
        pos = v(885, 780)
    }, {
        id = "ma_wisps_9_1",
        layer = 1,
        pos = v(899, 747),
        wait = {2, 6},
        animation = {
            to = 22,
            prefix = "wisps_9",
            from = 1
        }
    }, {
        id = "ma_wisps_9_2",
        template = "ma_wisps_9_1",
        pos = v(1097, 603)
    }, {
        id = "ma_wisps_10_1",
        layer = 1,
        pos = v(1080, 838),
        wait = {2, 6},
        animation = {
            to = 24,
            prefix = "wisps_10",
            from = 1
        }
    }, {
        id = "ma_wisps_10_2",
        template = "ma_wisps_10_1",
        pos = v(1367, 424)
    }, {
        loop = true,
        id = "ma_river_ne_1",
        layer = 1,
        pos = v(862, 367),
        animation = {
            to = 20,
            prefix = "ma_river_ne_1",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_river_ne_2",
        layer = 1,
        pos = v(1014, 301),
        animation = {
            to = 20,
            prefix = "ma_river_ne_2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_river_ne_3",
        layer = 1,
        pos = v(1153, 261),
        animation = {
            to = 20,
            prefix = "ma_river_ne_3",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_river_ne_4",
        layer = 1,
        pos = v(1266, 193),
        animation = {
            to = 20,
            prefix = "ma_river_ne_4",
            from = 1
        }
    }, {
        loop = true,
        alpha = 0.6,
        id = "ma_river_nw_1",
        layer = 1,
        pos = v(637, 357),
        animation = {
            to = 20,
            prefix = "ma_river_nw_1",
            from = 1
        }
    }, {
        loop = true,
        alpha = 0.4,
        id = "ma_river_nw_2",
        layer = 1,
        pos = v(550, 218),
        animation = {
            to = 20,
            prefix = "ma_river_nw_2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_river_s_1",
        layer = 1,
        pos = v(730, 677),
        animation = {
            to = 20,
            prefix = "ma_river_s_1",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_river_s_2",
        layer = 1,
        pos = v(804, 846),
        animation = {
            to = 20,
            prefix = "ma_river_s_2",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_river_s_3",
        layer = 1,
        pos = v(807, 976),
        animation = {
            to = 20,
            prefix = "ma_river_s_3",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_0",
        layer = 1,
        pos = v(100, 122),
        wait = {0, 1},
        animation = {
            to = 143,
            prefix = "ma_sea_bounce_0",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_1",
        layer = 1,
        pos = v(119, 120),
        wait = {0, 1},
        animation = {
            to = 133,
            prefix = "ma_sea_bounce_1",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_2",
        layer = 1,
        pos = v(311, 82),
        wait = {0, 1},
        animation = {
            to = 137,
            prefix = "ma_sea_bounce_2",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_3",
        layer = 1,
        pos = v(447, 114),
        wait = {0, 1},
        animation = {
            to = 120,
            prefix = "ma_sea_bounce_3",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_4",
        layer = 1,
        pos = v(625, 89),
        wait = {0, 1},
        animation = {
            to = 120,
            prefix = "ma_sea_bounce_4",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_5",
        layer = 1,
        pos = v(821, 73),
        wait = {0, 1},
        animation = {
            to = 120,
            prefix = "ma_sea_bounce_5",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_6",
        layer = 1,
        pos = v(1005, 62),
        wait = {0, 1},
        animation = {
            to = 141,
            prefix = "ma_sea_bounce_6",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_7",
        layer = 1,
        pos = v(1203, 68),
        wait = {0, 1},
        animation = {
            to = 120,
            prefix = "ma_sea_bounce_7",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_8",
        layer = 1,
        pos = v(1323, 143),
        wait = {0, 1},
        animation = {
            to = 137,
            prefix = "ma_sea_bounce_8",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_9",
        layer = 1,
        pos = v(1505, 121),
        wait = {0, 1},
        animation = {
            to = 193,
            prefix = "ma_sea_bounce_9",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_10",
        layer = 1,
        pos = v(1636, 150),
        wait = {0, 1},
        animation = {
            to = 140,
            prefix = "ma_sea_bounce_10",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_11",
        layer = 1,
        pos = v(1840, 195),
        wait = {0, 1},
        animation = {
            to = 120,
            prefix = "ma_sea_bounce_11",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_12",
        layer = 1,
        pos = v(309, 135),
        wait = {0, 1},
        animation = {
            to = 121,
            prefix = "ma_sea_bounce_12",
            from = 1
        }
    }, {
        id = "ma_sea_bounce_13",
        layer = 1,
        pos = v(300, 27),
        wait = {0, 1},
        animation = {
            to = 157,
            prefix = "ma_sea_bounce_13",
            from = 1
        }
    }, {
        loop = true,
        id = "ma_sea_sparks_1",
        layer = 1,
        pos = v(31, 22),
        animation = {
            to = 24,
            prefix = "ma_sea_sparks_1",
            from = 1
        }
    }, {
        id = "ma_sea_sparks_2",
        template = "ma_sea_sparks_1",
        pos = v(1409, 10)
    }, {
        id = "ma_sea_sparks_3",
        template = "ma_sea_sparks_1",
        pos = v(276, 133)
    }, {
        id = "ma_sea_sparks_4",
        template = "ma_sea_sparks_1",
        pos = v(1481, 44)
    }, {
        id = "ma_sea_sparks_5",
        template = "ma_sea_sparks_1",
        pos = v(1890, 22)
    }, {
        id = "ma_sea_sparks_6",
        template = "ma_sea_sparks_1",
        pos = v(1870, 123)
    }, {
        id = "ma_sea_sparks_7",
        template = "ma_sea_sparks_1",
        pos = v(1628, 13)
    }, {
        id = "ma_sea_sparks_8",
        template = "ma_sea_sparks_1",
        pos = v(1570, 146)
    }, {
        id = "ma_sea_sparks_9",
        template = "ma_sea_sparks_1",
        pos = v(1751, 176)
    }, {
        id = "ma_sea_sparks_10",
        template = "ma_sea_sparks_1",
        pos = v(990, 5)
    }, {
        id = "ma_sea_sparks_11",
        template = "ma_sea_sparks_1",
        pos = v(778, 40)
    }, {
        id = "ma_sea_sparks_12",
        template = "ma_sea_sparks_1",
        pos = v(1288, 37)
    }, {
        id = "ma_sea_sparks_13",
        template = "ma_sea_sparks_1",
        pos = v(1149, 6)
    }, {
        id = "ma_sea_sparks_14",
        template = "ma_sea_sparks_1",
        pos = v(847, 17)
    }, {
        id = "ma_sea_sparks_15",
        template = "ma_sea_sparks_1",
        pos = v(690, 25)
    }, {
        id = "ma_sea_sparks_16",
        template = "ma_sea_sparks_1",
        pos = v(592, 8)
    }, {
        id = "ma_sea_sparks_17",
        template = "ma_sea_sparks_1",
        pos = v(515, 55)
    }, {
        id = "ma_sea_sparks_18",
        template = "ma_sea_sparks_1",
        pos = v(442, 25)
    }, {
        id = "ma_sea_sparks_19",
        template = "ma_sea_sparks_1",
        pos = v(131, 22)
    }, {
        id = "ma_sea_sparks_20",
        template = "ma_sea_sparks_1",
        pos = v(169, 82)
    }, {
        loop = true,
        layer = 1,
        id = "ma_metro_c1",
        move = {
            time = 6,
            permanent = true,
            pingpong = true,
            interp = "in-out-sine",
            from = v(953, 539),
            to = v(967, 541)
        },
        wait = {0, 0},
        animation = {
            to = 11,
            prefix = "map_background",
            from = 11
        }
    }, {
        id = "ma_metro_c2",
        template = "ma_metro_c1",
        move = {
            time = 7,
            from = v(966, 538),
            to = v(954, 542)
        },
        animation = {
            from = 12,
            to = 12
        }
    }, {
        loop = true,
        id = "ma_metro_0",
        layer = 1,
        pos = v(960, 540),
        animation = {
            to = 4,
            prefix = "map_background",
            from = 4
        }
    }, {
        loop = true,
        layer = 1,
        id = "ma_metro_1",
        move = {
            time = 3,
            permanent = true,
            pingpong = true,
            interp = "in-out-sine",
            from = v(960, 538),
            to = v(960, 542)
        },
        wait = {0, 0},
        animation = {
            to = 5,
            prefix = "map_background",
            from = 5
        }
    }, {
        id = "ma_metro_2",
        template = "ma_metro_1",
        move = {
            time = 1,
            from = {
                y = 539
            },
            to = {
                y = 542
            }
        },
        animation = {
            from = 6,
            to = 6
        }
    }, {
        id = "ma_metro_3",
        template = "ma_metro_1",
        move = {
            time = 2,
            from = {
                y = 538
            },
            to = {
                y = 541
            }
        },
        animation = {
            from = 7,
            to = 7
        }
    }, {
        id = "ma_metro_4",
        template = "ma_metro_1",
        move = {
            time = 3,
            from = {
                y = 539
            },
            to = {
                y = 542
            }
        },
        animation = {
            from = 8,
            to = 8
        }
    }, {
        id = "ma_metro_5",
        template = "ma_metro_1",
        move = {
            time = 1,
            from = {
                y = 538
            },
            to = {
                y = 542
            }
        },
        animation = {
            from = 9,
            to = 9
        }
    }, {
        id = "ma_metro_6",
        template = "ma_metro_1",
        move = {
            time = 2.2,
            from = {
                y = 538
            },
            to = {
                y = 542
            }
        },
        animation = {
            from = 10,
            to = 10
        }
    }, {
        id = "ma_hood_l",
        layer = 2,
        pos = v(1010, 658),
        fns = {
            prepare = deco_fn.ani_seq.prepare
        },
        animations = {
            default = {
                to = 1,
                prefix = "ma_hood",
                from = 1
            },
            left = {
                to = 77,
                prefix = "ma_hood",
                from = 1
            },
            right = {
                to = 156,
                prefix = "ma_hood",
                from = 78
            }
        },
        sequence = {{"default", 3, 6}, {"left", 1, 3}, {"right", 1, 3}}
    }, {
        id = "ma_ewok",
        layer = 1,
        pos = v(160, 600),
        fns = {
            prepare = deco_fn.ani_seq.prepare
        },
        sequence = {{"default", 3, 5}, {"go_out", 1, 3}, {"left", 1, 3}, {"right", 1, 3}, {"left", 1, 2},
                    {"right", 1, 2}, {"go_in", 0, 0}},
        animations = {
            default = {
                to = 89,
                prefix = "ma_ewok",
                from = 89
            },
            go_out = {
                to = 46,
                prefix = "ma_ewok",
                from = 1
            },
            go_in = {
                to = 89,
                prefix = "ma_ewok",
                from = 50
            },
            right = {
                to = 46,
                prefix = "ma_ewok",
                from = 49
            },
            left = {
                to = 49,
                prefix = "ma_ewok",
                from = 46
            }
        }
    }, {
        id = "ma_hr_dragon",
        layer = 2,
        pos = v(1120, 66),
        fns = {
            prepare = deco_fn.ani_seq.prepare
        },
        animations = {
            default = {
                to = 1,
                prefix = "ma_hr_dragon",
                from = 1
            },
            flame = {
                to = 50,
                prefix = "ma_hr_dragon",
                from = 1
            },
            tail = {
                to = 74,
                prefix = "ma_hr_dragon",
                from = 51
            },
            blink = {
                to = 87,
                prefix = "ma_hr_dragon",
                from = 75
            },
            move = {
                to = 140,
                prefix = "ma_hr_dragon",
                from = 88
            }
        },
        sequence = {{"blink", 2, 3}, {"blink", 2, 3}, {"move", 1, 2}, {"blink", 2, 3}, {"tail", 1, 2}, {"blink", 2, 3},
                    {"blink", 2, 3}, {"tail", 1, 2}, {"move", 1, 2}, {"blink", 2, 3}, {"flame", 1, 2}, {"blink", 2, 3},
                    {"move", 1, 2}, {"blink", 2, 3}, {"tail", 1, 2}}
    }, {
        speed_x = 50,
        loop = true,
        id = "ma_waterfall1_barrel",
        layer = 1,
        pos = v(-10, 307),
        fns = {
            prepare = deco_fn.ma_waterfall1_barrel.prepare
        },
        wait_out = {8, 12},
        sequence = {{"idle", v(88, 337)}, {"fall", v(110, 418)}, {"crash", v(105, 418)}},
        animations = {
            default = {
                to = 30,
                prefix = "ma_waterfall1_barrel",
                from = 1
            },
            idle = {
                to = 30,
                prefix = "ma_waterfall1_barrel",
                from = 1
            },
            fall = {
                to = 60,
                prefix = "ma_waterfall1_barrel",
                from = 31
            },
            crash = {
                to = 80,
                prefix = "ma_waterfall1_barrel",
                from = 61
            }
        }
    }, {
        sail_time = 10,
        id = "ma_ship",
        wait_in = 12.5,
        loop = true,
        wait_out = 15,
        layer = 1,
        pos = v(253, 153),
        fns = {
            prepare = deco_fn.ma_ship.prepare
        },
        pos_in = v(194, 114),
        pos_out = v(-90, -90),
        animations = {
            in_sail = {
                to = 45,
                prefix = "ma_ship_in",
                from = 1
            },
            in_idle = {
                to = 120,
                prefix = "ma_ship_in",
                from = 46
            },
            in_trail = {
                to = 45,
                prefix = "ma_ship_trail_in",
                from = 1
            },
            out_sail = {
                to = 45,
                prefix = "ma_ship_out",
                from = 1
            },
            out_idle = {
                to = 120,
                prefix = "ma_ship_out",
                from = 46
            },
            out_trail = {
                to = 45,
                prefix = "ma_ship_trail_out",
                from = 1
            }
        }
    }},
    map_decos = {
        [1] = {{
            id = "md_muelle",
            image = "muelle",
            layer = 2,
            pos = v(297, 965)
        }, {
            id = "md_compass",
            image = "compass",
            layer = 1,
            pos = v(75, 1000)
        }, {
            id = "md_darkTower",
            image = "darkTower",
            layer = 2,
            pos = v(1735, 673)
        }, {
            id = "md_cover_swamp",
            image = "map_overFlags_0001",
            layer = 3,
            pos = v(1803, 305)
        }, {
            id = "md_cover_woods",
            image = "map_overFlags_0002",
            layer = 3,
            pos = v(647, 365)
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_01",
            image = "map_path_1_0010",
            trigger_level = 2,
            pos = v(322, 821),
            animations = {
                to = 10,
                prefix = "map_path_1",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_02",
            image = "map_path_2_0010",
            trigger_level = 3,
            pos = v(415, 783),
            animations = {
                to = 10,
                prefix = "map_path_2",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_03",
            image = "map_path_3_0025",
            trigger_level = 4,
            pos = v(559, 772),
            animations = {
                to = 25,
                prefix = "map_path_3",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_04",
            image = "map_path_4_0030",
            trigger_level = 5,
            pos = v(488, 650),
            animations = {
                to = 30,
                prefix = "map_path_4",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_05",
            image = "map_path_5_0059",
            trigger_level = 6,
            pos = v(426, 394),
            animations = {
                to = 59,
                prefix = "map_path_5",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_06",
            image = "map_path_6_0050",
            trigger_level = 7,
            pos = v(568, 209),
            animations = {
                to = 50,
                prefix = "map_path_6",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_07",
            image = "map_path_7_0034",
            trigger_level = 8,
            pos = v(815, 194),
            animations = {
                to = 34,
                prefix = "map_path_7",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_08",
            image = "map_path_8_0116",
            trigger_level = 9,
            pos = v(953, 185),
            animations = {
                to = 116,
                prefix = "map_path_8",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_09",
            image = "map_path_9_0090",
            trigger_level = 10,
            pos = v(1289, 357),
            animations = {
                to = 90,
                prefix = "map_path_9",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_10",
            image = "map_path_10_0025",
            trigger_level = 11,
            pos = v(1612, 528),
            animations = {
                to = 25,
                prefix = "map_path_10",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_11",
            image = "map_path_11_0071",
            trigger_level = 12,
            pos = v(1747, 668),
            animations = {
                to = 71,
                prefix = "map_path_11",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_23",
            image = "map_path_23_0026",
            trigger_level = 24,
            pos = v(1378, 238),
            animations = {
                to = 26,
                prefix = "map_path_23",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_24",
            image = "map_path_24_0021",
            trigger_level = 25,
            pos = v(1380, 164),
            animations = {
                to = 21,
                prefix = "map_path_24",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }, {
            layer = 1,
            hidden = true,
            id = "md_path_25",
            image = "map_path_25_0016",
            trigger_level = 26,
            pos = v(1448, 138),
            animations = {
                to = 16,
                prefix = "map_path_25",
                from = 1
            },
            fns = {
                unlock = deco_fn.path_open.unlock
            }
        }},
        [2] = { -- {
        -- 	layer = 3,
        -- 	id = "md_m1",
        -- 	image = "map_background_cover_1",
        -- 	trigger_level = 12,
        -- 	pos = v(1250, 378),
        -- 	fns = {
        -- 		unlock = deco_fn.m1.unlock
        -- 	}
        -- },
        -- {
        -- 	layer = 3,
        -- 	id = "md_m2",
        -- 	image = "map_background_cover_2",
        -- 	trigger_level = 14,
        -- 	pos = v(1460, 335),
        -- 	fns = {
        -- 		unlock = deco_fn.m2.unlock
        -- 	}
        -- },
        {
            layer = 2,
            id = "md_gate",
            image = "ma_gate_0001",
            trigger_level = 7,
            pos = v(680, 836),
            fns = {
                unlock = deco_fn.gate.unlock
            }
        }, {
            loop = true,
            layer = 2,
            id = "ship",
            image = "big_ship_0001",
            trigger_level = 6,
            pos = v(0, 0),
            fns = {
                prepare = deco_fn.ship.prepare,
                unlock = deco_fn.ship.unlock,
                update = deco_fn.ship.update
            },
            animations = {
                down_stopped = {
                    to = 225,
                    prefix = "big_ship",
                    from = 181
                },
                down = {
                    to = 45,
                    prefix = "big_ship",
                    from = 1
                },
                down_side = {
                    to = 90,
                    prefix = "big_ship",
                    from = 46
                },
                side = {
                    to = 135,
                    prefix = "big_ship",
                    from = 91
                },
                side_stopped = {
                    to = 180,
                    prefix = "big_ship",
                    from = 136
                }
            }
        }},
        [3] = {{
            layer = 3,
            id = "md_ft_mountain",
            image = "kr3_map_background_0002",
            trigger_level = 21,
            pos = v(960, 540),
            hit_rect = r(1240, 110, 300, 240),
            fns = {
                unlock = deco_fn.md_ft_mountain.unlock
            }
        }}
    }
}
