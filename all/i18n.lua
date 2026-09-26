-- chunkname: @./all/i18n.lua
local i18n = {}

i18n.msgs = {}
-- i18n.default_locale = "en"
-- i18n.current_locale = "en"
i18n.default_locale = "zh-Hans"
i18n.current_locale = "zh-Hans"
i18n.supported_locales = {"zh-Hans", "en"}
-- "de",
-- "es",
-- "fr",
-- "ja",
-- "ko",
-- "pt",
-- "ru",
-- "zh-Hant"
i18n.locale_names = {
	-- ko = "한국어",
	-- de = "Deutsch",
	-- ru = "Русский",
	-- pt = "Português",
	-- ["zh-Hant"] = "中文 (繁體)",
	-- fr = "Français",
	-- ja = "日本語",
	en = "English",
	["zh-Hans"] = "中文 (简体)"
-- es = "Español"
}

function i18n.load_locale(locale)
	i18n.msgs[locale] = require("strings." .. locale)
	i18n.current_locale = locale
end

function _(s, default)
	local l = i18n.msgs[i18n.current_locale]

	l = l or i18n.msgs[i18n.default_locale]

	local ts = l[s]

	if ts then
		return ts
	elseif default then
		return default
	else
		-- DEBUG_USE
		-- print("Missing translation for '" .. s .. "' in locale '" .. i18n.current_locale .. "'")
		-- print(debug.traceback())
		if _G.I18N_DEBUG or os.getenv("I18N_DEBUG") == "1" then
			print("I18N_MISSING\t" .. tostring(s) .. "\t" .. tostring(i18n.current_locale))
			print(debug.traceback("", 2))
		end
		return s
	end
end

function i18n:sw(default, ...)
	local args = {...}

	if #args > 0 then
		for i, a in ipairs(args) do
			if i % 2 == 1 and a == self.current_locale then
				return args[i + 1]
			end
		end
	end

	return default
end

function i18n:cjk(default, zh, ja, ko)
	local cl = self.current_locale

	if (cl == "zh-Hans" or cl == "zh-Hant") and zh then
		return zh
	end

	if cl == "ja" and ja then
		return ja
	end

	if cl == "ko" and ko then
		return ko
	end

	return default
end

function i18n:find_fallback_locale(lang, script)
	local l = lang or ""
	local s = script or ""
	local k1 = l
	local k2 = l .. "-" .. s

	if self.locale_names[k2] then
		return k2
	elseif self.locale_names[k1] then
		return k1
	else
		for _, sl in pairs(self.supported_locales) do
			local ssl = string.sub(sl, 1, string.len(l))

			if ssl == l then
				return sl
			end
		end
	end
end

-- 缺失文案可见化：只在显式开启时替换实现，正常工作路径不带任何检查
local fast_lookup = _
function i18n.set_debug_missing(on)
	if not on then
		_ = fast_lookup

		return
	end

	_ = function(s, default)
		local l = i18n.msgs[i18n.current_locale] or i18n.msgs[i18n.default_locale]
		local ts = l and l[s]

		if ts then
			return ts
		elseif default then
			return default
		end

		print("I18N_MISSING\t" .. tostring(s) .. "\t" .. tostring(i18n.current_locale))
		print(debug.traceback("", 2))

		return s
	end
end

return i18n

