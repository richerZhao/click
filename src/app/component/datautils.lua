local datautils = {}

function datautils.readData(filePath)
	return io.readfile(filePath)
end

function datautils.saveData(filePath,data)
	return io.writefile(filePath, data)
end

return datautils