local ChefLspOccurence = {}

-- Go to the next occurence of the highlighted identifier
function ChefLspOccurence.next()
	local highlights = vim.api.nvim_buf_get_extmarks(0, -1, 0, -1, {details = true})
	local foundNext = false
	for i,v in ipairs(highlights) do
		local is_lsp = v[4].hl_group == "LspReferenceText" or v[4].hl_group == "LspReferenceRead" or v[4].hl_group == "LspReferenceWrite"
		if is_lsp and v[2] + 1 > vim.api.nvim_win_get_cursor(0)[1] then -- V[2] is the line number
			vim.api.nvim_win_set_cursor(0, {v[2] + 1, v[3] + 1}) --lsp index is zero based, vim is 1 based
			foundNext = true
			break
		end
	end
	if not foundNext then
		-- Wrapped around, go to the first one
		if #highlights > 0 then
			vim.api.nvim_win_set_cursor(0, {highlights[1][2] + 1, highlights[1][3] + 1}) --lsp index is zero based, vim is 1 based
		end
	end
end

-- Go to the previous occurence of the highlighted identifier
function ChefLspOccurence.prev()
	local highlights = vim.api.nvim_buf_get_extmarks(0, -1, 0, -1, {details = true})
	local foundPrev = false
	for i=#highlights,1,-1 do
		local is_lsp = highlights[i][4].hl_group == "LspReferenceText" or highlights[i][4].hl_group == "LspReferenceRead" or highlights[i][4].hl_group == "LspReferenceWrite"
		if is_lsp and highlights[i][2] + 1 < vim.api.nvim_win_get_cursor(0)[1] then -- V[2] is the line number
			vim.api.nvim_win_set_cursor(0, {highlights[i][2] + 1, highlights[i][3] + 1}) --lsp index is zero based, vim is 1 based
			foundPrev = true
			break
		end
	end
	if not foundPrev then
		-- Wrapped around, go to the last one
		if #highlights > 0 then
			vim.api.nvim_win_set_cursor(0, {highlights[#highlights][2] + 1, highlights[#highlights][3] + 1}) --lsp index is zero based, vim is 1 based
		end
	end
end

function ChefLspOccurence.setup()
	local chefLspGroup = vim.api.nvim_create_augroup('ChefLspOccurence', { clear = true })
	vim.api.nvim_create_autocmd('LspAttach', {
		group = chefLspGroup,
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client.server_capabilities.documentHighlightProvider then
				vim.api.nvim_create_autocmd('CursorHold', {
					group = chefLspGroup,
					callback = function(ev)
						vim.lsp.buf.document_highlight()
					end
				})
				vim.api.nvim_create_autocmd('CursorHoldI', {
					group = chefLspGroup,
					callback = function(ev)
						vim.lsp.buf.document_highlight()
					end
				})
				vim.api.nvim_create_autocmd('CursorMoved', {
					group = chefLspGroup,
					callback = function(ev)
						vim.lsp.buf.clear_references()
					end
				})
			end
		end,
	})
end

return ChefLspOccurence
