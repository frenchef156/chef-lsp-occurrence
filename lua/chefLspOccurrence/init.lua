local ChefLspOccurrence = {}

ChefLspOccurrence.didJump = false

local function performJump(highlightData)
	ChefLspOccurrence.didJump = true
	vim.api.nvim_win_set_cursor(0, {highlightData[2] + 1, highlightData[3] + 1}) --lsp index is zero based, vim is 1 based
	foundNext = true
end

local function isLsp(highlightData)
	return v[4].hl_group == "LspReferenceText" or v[4].hl_group == "LspReferenceRead" or v[4].hl_group == "LspReferenceWrite"
end

-- Go to the next occurrence of the highlighted identifier
function ChefLspOccurrence.next()
	local highlights = vim.api.nvim_buf_get_extmarks(0, -1, 0, -1, {details = true})
	local foundNext = false
	for i,v in ipairs(highlights) do
		if isLsp(v) and v[2] + 1 > vim.api.nvim_win_get_cursor(0)[1] then -- V[2] is the line number
			performJump(v)
			break
		end
	end
	if not foundNext then
		-- Wrapped around, go to the first one
		for i,v in ipairs(highlights) do
			if isLsp(v) then
				performJump(v)
				break
			end
		end
	end
end

-- Go to the previous occurrence of the highlighted identifier
function ChefLspOccurrence.prev()
	local highlights = vim.api.nvim_buf_get_extmarks(0, -1, 0, -1, {details = true})
	local foundPrev = false
	for i=#highlights,1,-1 do
		if isLsp(highlights[i]) and highlights[i][2] + 1 < vim.api.nvim_win_get_cursor(0)[1] then -- V[2] is the line number
			performJump(highlights[i])
			break
		end
	end
	if not foundPrev then
		-- Wrapped around, go to the last one
		for i=#highlights,1,-1 do
			if isLsp(highlights[i]) then
				performJump(highlights[i])
				break
			end
		end
	end
end

local function onCursorHold(ev)
	if not ChefLspOccurrence.didJump then
		vim.lsp.buf.clear_references()
		vim.lsp.buf.document_highlight()
	end
	ChefLspOccurrence.didJump = false
end

function ChefLspOccurrence.setup()
	local chefLspGroup = vim.api.nvim_create_augroup('ChefLspOccurrence', { clear = true })
	vim.api.nvim_create_autocmd('LspAttach', {
		group = chefLspGroup,
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client.server_capabilities.documentHighlightProvider then
				vim.api.nvim_create_autocmd('CursorHold', {
					group = chefLspGroup,
					callback = onCursorHold
				})
				vim.api.nvim_create_autocmd('CursorHoldI', {
					group = chefLspGroup,
					callback = onCursorHold
				})
				-- vim.api.nvim_create_autocmd('CursorMoved', {
				-- 	group = chefLspGroup,
				-- 	callback = function(ev)
				-- 		vim.lsp.buf.clear_references()
				-- 	end
				-- })
			end
		end,
	})
end

return ChefLspOccurrence
