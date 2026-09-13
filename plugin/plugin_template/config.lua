return {
	name = _("PLUGIN_UI_TEMPLATE_NAME"),
	entry = "plugin_template",
	version = _("PLUGIN_UI_TEMPLATE_VERSION"),
	desc = _("PLUGIN_UI_TEMPLATE_DESC"),
	url = _("PLUGIN_UI_TEMPLATE_URL"),
	by = _("PLUGIN_UI_TEMPLATE_AUTHOR"),
	category = "other", -- 插件类型。可选项："gameplay"（玩法）, "cosmetic"（美化）, "display"（显示）, "tower"（防御塔）, "hero"（英雄）, "enemy"（敌人）, "level"（关卡）, "other"（其它）,
	enabled = true, -- 启用状态，关闭则不加载此 plugin
	priority = 0 -- 优先级，若不知道可填 0
}
