-- ajout du package pour le thème catppuccin et le définir par défaut
vim.pack.add {
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	--ajout du pluggin lualine
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	--ajout du pluggin treesitter pour parser le code Rust
	{ src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
	--ajout du pluggin tiny-install-diagnostic pour afficher les messages d'erreurs rust correctement
	{ src = 'https://github.com/rachartier/tiny-inline-diagnostic.nvim' },
	--ajout du pluggin pour le LSP(Language Server Protocol)
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	--ajout du pluggin autopairs pour ajouter automatiquement un second ' ou un second
	{ src = 'https://github.com/windwp/nvim-autopairs' },
	--ajout du pluggin blink pour l'autocomplétion
	{ src = 'https://github.com/saghen/blink.lib' },
	{ src = 'https://github.com/saghen/blink.cmp' },
	--ajout du pluggin leap pour pouvoir jumper dans l'éditeur de texte
	{ src = 'https://codeberg.org/andyg/leap.nvim' },
}

vim.g.mapleader = 'k'
vim.cmd.colorscheme "catppuccin-nvim"
vim.opt.showmode = false --Masque la barre par défaut de neovim
--importation du module lualine et lancement de la fonction setup
vim.cmd("set number")
vim.cmd("set shiftwidth=4") --nbre d'espaces d'une indentation
vim.cmd("set tabstop=8") -- largeur d'ene indentation en caractères
vim.diagnostic.config({
	virtual_text = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "●",
			[vim.diagnostic.severity.WARN]  = "●",
			[vim.diagnostic.severity.INFO]  = "●",
			[vim.diagnostic.severity.HINT]  = "●",
		},
	},
})
vim.o.winborder = "rounded"

require('keywords_doc')
require('lualine').setup()
require('nvim-autopairs').setup {}
require('snacks').setup({
	picker = { enable = true }, --permet de naviguer dans des fichiers
	explorer = { enable = true }, --arbre de fichiers de notre projet en cours qui s'affiche à
	--gauche
	lazygit = { enable = true}, -- chargement de lazygit : un outil permettant de manipuler git
	-- dans Neovim 
})
require("tiny-inline-diagnostic").setup({
	options = {
		multilines = {
			enabled = true,
		},
	},
     -- Available: "modern", "classic", "minimal", "powerline", "ghost", "simple", "nonerdfont", "amongus"
	preset = "ghost"

})
-- récupérer et charger blink.cmp
local cmp = require('blink.cmp')
cmp.build():pwait()

cmp.setup({
    --raccourcis de blink
	keymap = {
		["<CR>"] = { "accept", "fallback" }, -- entrée pour accepter une suggestion
		["<Tab>"] = { "select_next", "fallback" },  -- tab pour descendre dans les suggestion
		["<S-Tab>"] = { "select_prev", "fallback" }, -- shift tab pour y remonter
		["<Esc>"] = { "cancel", "fallback" }, -- escape pour sortir
	},

	completion = {
		accept = {
		    -- auto brackets pour que les brackets se ferment automatiquement
			auto_brackets = {
				enabled = true,
			},
		},
	},

	-- les sources càd les emplacements au niveau desquelles blink doit chercher
	sources = {
		default = {
			"lsp",
			"path",
			"snippets",
			"buffer",
		},
	},
})

--déclaration/activation des lsp que j'utilise
-- AJOUT : configuration de clangd (LSP pour C et C++)
vim.lsp.config('clangd', {
	cmd = {
		'clangd',
		'--background-index',   -- indexe tout le projet en arrière-plan 
		-- (navigation plus rapide)
		'--clang-tidy',         -- active les avertissements de clang-tidy 
		-- (bugs, mauvais usages)
		'--header-insertion=never', -- n'ajoute pas de #include automatiquement
	},
})

--déclaration/activation des lsp que j'utilise
-- AJOUT : 'clangd' dans la liste
vim.lsp.enable({ 'rust_analyzer', 'asm_lsp', 'clangd' })




--ajout de raccourcis clavier à base du mapleader pour exécuter quelques actions du pluggin Snacks

vim.keymap.set("n", "<leader>ff", Snacks.picker.files) --permet de rechercher un fichier et de 
--"sauter" dedans. Les deux fichiers(celui de départ et celui dans lequel on 
-- saute) apparaissent dans la liste des buffers
vim.keymap.set("n", "<leader>fg", Snacks.picker.grep) --chercher les occurences d'un pattern dans
-- tous les fichiers du système et permet de sauter dans le fichier contenant l'occurence que 
-- l'on cherche
vim.keymap.set("n", "<leader>fb", Snacks.picker.buffers) --affiche la liste des buffers (càd la 
-- liste des fichiers ouverts dans notre session actuelle) et permet de choisir celui de notre
-- choix
vim.keymap.set("n", "<leader>fd", Snacks.picker.diagnostics) --bilan des erreurs signalées par notre
--LSP (Language Server Protocole)
vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>fs", Snacks.picker.lsp_symbols)
vim.keymap.set("n", "<leader>fe", function() Snacks.explorer() end) --explorateur de fichiers avec pleins de 
--raccourcis utilse comme a pour créer un fichier/dossier d pour le supprimer etc
vim.keymap.set("n", "<leader>fS", Snacks.picker.lsp_workspace_symbols)
--raccourcis clavier pour leap
vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)', { desc = 'Leap jump on current window' })
vim.keymap.set('n', 'S', '<Plug>(leap-from-window)', { desc = 'Leap jump on other windows' })

--raccourcis clavier pour lazygit
vim.keymap.set("n", "<leader>lg", function() Snacks.lazygit() end)

-- Comment faire un copier coller dans neovim??
-- le copier-coller dans neovim utilise le concept du "yank" et du "put" et est souvent séparé du 
-- presse papier de l'OS
--
-- donc pour copier il faut taper (en mode normal) yy (ça copier toute la ligne sur laquelle
-- se trouve le curseur); yw sert à copier juste un mot; v (puis se déplacer avec les flèches
--  ou h, j, k et l pour sélectionner du texte) puis y pour copier la sélection personnalisée
--  Et pour coller il faut toujours en mode normal) taper p (minuscule) pour coller après le curseur
--  ou la ligne et P (majuscule) pour coller avant le curseur ou la ligne
