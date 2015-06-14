function replace(text,data,args)
	local rpl
	local replacedText = text
	for i,v in ipairs(args) do
		rpl = "{" .. i .. "}"
		replacedText = (string.gsub(replacedText, rpl, data[v]))
    end
    return replacedText
end