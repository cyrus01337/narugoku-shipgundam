local ErrorManager = {}

local INVALID_LINE_ERROR = "Error Line was not provided."
local INVALID_FUNCTION_ERROR = "Error Function was not provided."
local INVALID_ARGUMENT_ERROR = "Error Argument was not provided"

function ErrorManager.InitiateError()
	return {
		Catch = ErrorManager.Catch
	}
end

function ErrorManager:Catch(ErrorData)
	ErrorData.ErrorLine = ErrorData.ErrorLine or warn(INVALID_LINE_ERROR)
	ErrorData.ErrorFunction = ErrorData.ErrorFunction or warn(INVALID_FUNCTION_ERROR)
	ErrorData.ErrorArgument = ErrorData.ErrorArgument or warn(INVALID_ARGUMENT_ERROR)
	
	return error("Error at line :  % ; Error at Function : %s ; Error Argument : %s"):format(ErrorData.ErrorLine,ErrorData.ErrorFunction,ErrorData.ErrorArgument)
end


return ErrorManager