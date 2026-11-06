-- =============================================================================
-- copilot_setup.lua : configuration de GitHub Copilot pour Neovim
-- =============================================================================
-- Ce fichier est SÉPARÉ de ton init.lua : il contient uniquement l'ajout de
-- Copilot. Pour l'activer, ajoute UNE ligne à la fin de ton init.lua :
--
--     require("copilot_setup")
--
-- Pour le désactiver entièrement : supprime (ou commente) cette ligne.
--
-- Emplacement du fichier : ~/.config/nvim/lua/copilot_setup.lua
-- (crée le dossier "lua" à côté de ton init.lua s'il n'existe pas)
--
-- Prérequis : Node.js installé (brew install node sur Mac, ou apt dans ta VM).
-- Vérifie la version minimale demandée dans le README de copilot.lua.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Installation des plugins (même méthode que ton init.lua : vim.pack)
-- -----------------------------------------------------------------------------
vim.pack.add {
	-- copilot.lua : le plugin qui connecte Neovim à GitHub Copilot
	-- (suggestions en texte fantôme, version écrite en Lua)
	{ src = "https://github.com/zbirenbaum/copilot.lua" },

	-- plenary.nvim : bibliothèque utilitaire dont CopilotChat peut dépendre
	-- selon sa version (sans danger si elle n'est pas utilisée)
	{ src = "https://github.com/nvim-lua/plenary.nvim" },

	-- CopilotChat.nvim : une fenêtre de chat pour poser des questions sur
	-- ton code (expliquer, relire, corriger). Complète copilot.lua.
	{ src = "https://github.com/CopilotC-Nvim/CopilotChat.nvim" },
}


-- -----------------------------------------------------------------------------
-- 2. Configuration des suggestions (copilot.lua)
-- -----------------------------------------------------------------------------
require("copilot").setup({

	-- Le panneau de suggestions multiples est désactivé : on garde simple.
	panel = { enabled = false },

	suggestion = {
		enabled = true,

		-- IMPORTANT : suggestions automatiques DÉSACTIVÉES par défaut.
		-- Copilot ne propose rien tant que tu ne le demandes pas (touche
		-- "next" ci-dessous) ou que tu n'actives l'auto-déclenchement avec
		-- <leader>ct. C'est voulu : tu écris d'abord, l'IA vient ensuite.
		auto_trigger = false,

		-- Cache la suggestion Copilot pendant que le menu de blink.cmp est
		-- ouvert, pour éviter que les deux se superposent.
		hide_during_completion = true,

		-- Touches choisies pour ne PAS entrer en conflit avec blink.cmp
		-- (dans ton init.lua, Tab / Shift-Tab / Entrée sont déjà pris par blink).
		keymap = {
			accept      = "<C-l>", -- accepter toute la suggestion
			accept_word = "<C-Right>", -- accepter seulement le mot suivant
			accept_line = false,   -- non utilisé
			next        = "<C-j>", -- suggestion suivante (en demande une s'il n'y en a pas)
			prev        = "<C-k>", -- suggestion précédente
			dismiss     = "<C-]>", -- rejeter la suggestion
		},
	},

	-- Types de fichiers où Copilot est DÉSACTIVÉ.
	-- Ici : tes exercices d'assembleur, pour que la roadmap (ASM, pwn) reste
	-- faite à la main. Retire une ligne si tu veux Copilot sur ce type de fichier.
	filetypes = {
		asm    = false,
		nasm   = false,
		masm   = false,
		-- Fichiers de configuration sensibles : jamais d'envoi vers Copilot
		["env"] = false,
		-- Valeurs par défaut conservées : markdown, yaml, help, gitcommit, etc.
		markdown  = false,
		yaml      = false,
		help      = false,
		gitcommit = false,
		gitrebase = false,
		["."]     = false,
	},
})


-- -----------------------------------------------------------------------------
-- 3. Cohabitation avec blink.cmp
-- -----------------------------------------------------------------------------
-- blink.cmp émet des événements quand son menu s'ouvre ou se ferme.
-- On masque la suggestion Copilot pendant que le menu est ouvert, puis on la
-- réaffiche à la fermeture.
vim.api.nvim_create_autocmd("User", {
	pattern = "BlinkCmpMenuOpen",
	callback = function() vim.b.copilot_suggestion_hidden = true end,
})
vim.api.nvim_create_autocmd("User", {
	pattern = "BlinkCmpMenuClose",
	callback = function() vim.b.copilot_suggestion_hidden = false end,
})


-- -----------------------------------------------------------------------------
-- 4. Configuration du chat (CopilotChat.nvim)
-- -----------------------------------------------------------------------------
require("CopilotChat").setup({})


-- -----------------------------------------------------------------------------
-- 5. Raccourcis clavier (même logique que ton init.lua : à base de <leader>)
-- -----------------------------------------------------------------------------
-- Rappel : ton leader est 'k', donc <leader>ct = taper "k" puis "c" puis "t".

-- Activer / désactiver les suggestions automatiques à la volée
vim.keymap.set("n", "<leader>ct", function()
	require("copilot.suggestion").toggle_auto_trigger()
end, { desc = "Copilot : activer/désactiver les suggestions auto" })

-- Couper / rallumer Copilot complètement (plus aucune requête envoyée)
vim.keymap.set("n", "<leader>cT", "<cmd>Copilot toggle<cr>",
	{ desc = "Copilot : couper/rallumer entièrement" })

-- Ouvrir / fermer la fenêtre de chat
vim.keymap.set("n", "<leader>cc", "<cmd>CopilotChatToggle<cr>",
	{ desc = "CopilotChat : ouvrir/fermer" })

-- Sur une sélection visuelle (v puis déplacement), demander :
--   une explication, une relecture ou une correction
vim.keymap.set("v", "<leader>ce", "<cmd>CopilotChatExplain<cr>",
	{ desc = "CopilotChat : expliquer la sélection" })
vim.keymap.set("v", "<leader>cr", "<cmd>CopilotChatReview<cr>",
	{ desc = "CopilotChat : relire la sélection" })
vim.keymap.set("v", "<leader>cf", "<cmd>CopilotChatFix<cr>",
	{ desc = "CopilotChat : proposer une correction" })


-- =============================================================================
-- Première utilisation
-- =============================================================================
-- 1. Ajoute la ligne require("copilot_setup") à la fin de ton init.lua.
-- 2. Relance Neovim : vim.pack va proposer d'installer les 3 plugins, accepte.
-- 3. Relance Neovim une seconde fois, puis tape  :Copilot auth
--    Un code s'affiche : valide-le sur github.com/login/device avec ton
--    compte GitHub étudiant. Ça se fait une seule fois.
-- 4. Pour vérifier l'état : :Copilot status
-- =============================================================================
