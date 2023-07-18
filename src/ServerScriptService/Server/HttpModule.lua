local HttpService = game:GetService("HttpService")

local Colours = {"00FF00","0000FF","FF8000","FF0080","00FF80","0080FF","00FFFF"}

local webhooks = {
	["Error"] = {
		["WebhookUrl"] = "https://discord.com/api/webhooks/1130931479606722650/gNUTzq7Eut_MqnFOgZEwS44c_nd2nYVDyP3jc39eSTLW2-B22OSsiMQC4LlzPG5mTvMk";
		["Username"] = "Error Logger";
		["Title"] = "Game Error";
		["Colour"] = 0xFF0000;

		["GenerateFields"] = function(args)
			local fields = {
				{
					["name"] = "Error";
					["value"] = args[1];
				};
				{
					["name"] = "Stack Trace";
					["value"] = args[2];
				};
			}

			return fields
		end;
	};
	["DataError"] = {
		["WebhookUrl"] = "https://discord.com/api/webhooks/1130931479606722650/gNUTzq7Eut_MqnFOgZEwS44c_nd2nYVDyP3jc39eSTLW2-B22OSsiMQC4LlzPG5mTvMk";
		["Username"] = "Data Logger";
		["Title"] = "Data Error";
		["Colour"] = 0xFF0000;

		["GenerateFields"] = function(args)
			local fields = {
				{
					["name"] = "Error";
					["value"] = args[1];
				};
				{
					["name"] = "Retry Iteration";
					["value"] = args[2];
				};
				{
					["name"] = "Method";
					["value"] = args[3];
				};
			}

			return fields
		end;

		["CustomFunction"] = function(webHookName,dataToSend,args)
			local dataTable = dataToSend["embeds"][1]
			dataTable["title"] = dataTable["title"] .. string.format(" from %s(%d)",args[4].Name,args[4].UserId)
		end
	};
}

local HttpModule = {}

function HttpModule:PostToWebhook(webhookName,...)
	local webhookData = webhooks[webhookName]
	if not webhookData then error("No webhookData for webhook "..webhookName) end

	local args = {...}
	local dataToSend = {
		["embeds"] = {
			{
				["fields"] = {};
				["footer"] = {
					["icon_url"] = 	"https://cdn.discordapp.com/icons/740399073949122581/0c2d15f82eaa3f1291379a880e6c5fc1.webp?size=256";
					["text"] = "";
				};
			}
		}
	}

	dataToSend["username"] = webhookData.Username
	dataToSend["embeds"][1]["title"] = webhookData.Title

	if webhookData.Colour then
		dataToSend["embeds"][1]["color"] = webhookData.Colour
	end

	local fields = webhookData.GenerateFields(args)

	for i,v in ipairs(fields) do
		dataToSend["embeds"][1]["fields"][i] = v
	end

	dataToSend["embeds"][1]["fields"][#fields + 1] = {
		["name"] = "Game";
		["value"] = "Anime Saga";
	}

	if webhookData.CustomFunction then
		webhookData.CustomFunction(webhookName,dataToSend,args)
	end

	return pcall(function()
		HttpService:PostAsync(webhookData.WebhookUrl,HttpService:JSONEncode(dataToSend))
	end)
end

return HttpModule
