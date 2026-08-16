return {
	name = "plugin名称",
	entry = "plugin_template",
	version = "版本",
	desc = "plugin 描述",
	url = "发布链接",
	by = "作者",
	category = "other", -- 插件类型。可选项："gameplay"（玩法）, "cosmetic"（美化）, "display"（显示）, "tower"（防御塔）, "hero"（英雄）, "enemy"（敌人）, "level"（关卡）, "other"（其它）,
	enabled = true, -- 启用状态，关闭则不加载此 plugin
	priority = 0 -- 优先级，若不知道可填 0
}
