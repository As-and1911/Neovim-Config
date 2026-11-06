-- =============================================================================
-- keywords_doc.lua : documentation des mots-clés C et C++ dans Neovim
-- =============================================================================
-- Fichier SÉPARÉ de ton init.lua. Pour l'activer, ajoute UNE ligne à la fin
-- de ton init.lua :
--
--     require("keywords_doc")
--
-- Emplacement : ~/.config/nvim/lua/keywords_doc.lua
--
-- Fonctionnement : dans un fichier C ou C++, K sur un mot-clé (return,
-- unsigned, static...) ouvre une petite fiche. Sur tout autre mot (fonction,
-- variable, type), K fait comme avant : il demande à clangd (hover LSP).
--
-- Pour ajouter ou corriger une fiche : modifie simplement la table "docs"
-- plus bas, une entrée par mot-clé.
-- =============================================================================

local M = {}

-- -----------------------------------------------------------------------------
-- 1. Les fiches : mot-clé = "description"
-- -----------------------------------------------------------------------------
-- Les descriptions sont volontairement courtes. Quand il y a un piège
-- classique pour la sécurité (comportement indéfini, débordement...), il est
-- signalé : c'est ce qui t'intéresse pour la suite de ta roadmap.
local docs = {

	-- ---- Types de base ----------------------------------------------------
	["int"] = "Entier signé. Taille typique : 4 octets (au moins 16 bits d'après la norme). "
		.. "Un dépassement d'`int` signé est un **comportement indéfini**.",
	["char"] = "Plus petit type entier, 1 octet. Qu'il soit signé ou non par défaut "
		.. "**dépend de la plateforme** : utilise `signed char` ou `unsigned char` "
		.. "si ça compte. Sert aussi à représenter les caractères.",
	["short"] = "Entier signé d'au moins 16 bits (2 octets en pratique). Se combine avec `unsigned`.",
	["long"] = "Entier signé d'au moins 32 bits. Sous Linux x86_64 et macOS ARM64 (modèle LP64) "
		.. "il fait **8 octets**, mais seulement 4 sous Windows 64 bits. `long long` fait 8 octets partout.",
	["float"] = "Nombre à virgule flottante simple précision (4 octets, norme IEEE 754 en pratique).",
	["double"] = "Nombre à virgule flottante double précision (8 octets en pratique).",
	["void"] = "Absence de type. `void f(void)` : ne renvoie rien et ne prend pas d'argument. "
		.. "`void *` : pointeur générique, convertible vers tout pointeur d'objet.",
	["signed"] = "Force un type entier à être signé. Surtout utile avec `char`.",
	["unsigned"] = "Type entier sans signe (≥ 0). Le dépassement est **bien défini** : il boucle "
		.. "modulo 2^n. Piège de sécurité classique : comparer ou mélanger signé et non signé, "
		.. "ou soustraire deux `unsigned` (le résultat 'négatif' devient un énorme nombre).",
	["_Bool"] = "Type booléen du C99 (`bool` avec `<stdbool.h>`). Vaut 0 ou 1.",

	-- ---- Qualificateurs et classes de stockage ------------------------------
	["const"] = "Déclare qu'une valeur ne doit pas être modifiée via ce nom. Modifier un objet "
		.. "réellement défini `const` est un **comportement indéfini**. `const char *p` : "
		.. "les caractères sont constants, pas le pointeur.",
	["volatile"] = "Indique que la valeur peut changer sans que le code ne la modifie "
		.. "(registre matériel, signal, autre thread) : le compilateur ne doit pas "
		.. "optimiser les accès. Ne remplace **pas** une synchronisation entre threads.",
	["restrict"] = "Promesse au compilateur : pendant la durée de vie du pointeur, l'objet "
		.. "pointé n'est accédé que par lui. Permet des optimisations. Violer la promesse "
		.. "est un **comportement indéfini**.",
	["static"] = "Selon le contexte : (1) variable locale = garde sa valeur entre les appels ; "
		.. "(2) fonction ou variable globale = visible **uniquement dans ce fichier** "
		.. "(liaison interne).",
	["extern"] = "Déclare qu'un objet ou une fonction est **défini ailleurs** (autre fichier "
		.. "source). Ne réserve pas de mémoire.",
	["register"] = "Suggestion historique de garder la variable dans un registre. Ignorée par "
		.. "les compilateurs modernes. On ne peut pas prendre l'adresse (`&`) d'une variable `register`.",
	["auto"] = "En C : classe de stockage par défaut des variables locales (inutile). "
		.. "En C++11 et plus : déduit automatiquement le type d'une variable.",
	["inline"] = "Suggère au compilateur d'insérer le corps de la fonction à l'endroit de l'appel. "
		.. "Sert surtout à autoriser la définition dans un en-tête.",
	["_Atomic"] = "Qualificateur du C11 : accès atomiques entre threads (voir `<stdatomic.h>`).",
	["_Thread_local"] = "C11 : une copie de la variable par thread.",
	["_Alignas"] = "C11 : impose l'alignement mémoire d'un objet.",
	["_Alignof"] = "C11 : donne l'alignement requis d'un type.",
	["_Noreturn"] = "C11 : indique que la fonction ne revient jamais (ex. `exit`).",
	["_Static_assert"] = "C11 : vérification à la **compilation**. Échoue la compilation si la condition est fausse.",
	["_Generic"] = "C11 : sélection d'une expression selon le type d'une valeur, à la compilation.",

	-- ---- Types composés -----------------------------------------------------
	["struct"] = "Regroupe plusieurs champs en un seul type. Le compilateur peut ajouter du "
		.. "**remplissage (padding)** entre les champs pour l'alignement : `sizeof` peut "
		.. "dépasser la somme des champs. Important pour comprendre la disposition en mémoire.",
	["union"] = "Tous les champs partagent la **même zone mémoire** ; la taille est celle du "
		.. "plus grand champ. Lire un champ autre que celui écrit en dernier réinterprète les octets.",
	["enum"] = "Définit un ensemble de constantes entières nommées. En C, les valeurs sont des `int`.",
	["typedef"] = "Crée un **alias** pour un type existant. Ne crée pas un nouveau type.",
	["sizeof"] = "Opérateur évalué à la compilation : taille en octets d'un type ou d'une expression, "
		.. "de type `size_t`. Piège : sur un **paramètre de fonction tableau**, il donne la taille "
		.. "d'un pointeur, pas du tableau.",

	-- ---- Structures de contrôle ---------------------------------------------
	["if"] = "Exécute un bloc si la condition est non nulle. Piège : `if (a = b)` (affectation) "
		.. "au lieu de `if (a == b)`.",
	["else"] = "Branche alternative d'un `if`.",
	["switch"] = "Choisit un bloc selon la valeur d'une expression entière. Sans `break`, "
		.. "l'exécution **continue** dans le `case` suivant (fallthrough).",
	["case"] = "Étiquette d'un `switch` : valeur constante entière.",
	["default"] = "Étiquette d'un `switch` exécutée si aucun `case` ne correspond.",
	["for"] = "Boucle avec initialisation, condition et incrément : `for (init; cond; incr)`. "
		.. "Piège : erreur d'un cran (`<=` au lieu de `<`) qui déborde d'un tableau.",
	["while"] = "Boucle tant que la condition est non nulle. Condition testée **avant** chaque tour.",
	["do"] = "Boucle `do { ... } while (cond);` : le corps s'exécute **au moins une fois**.",
	["break"] = "Sort immédiatement de la boucle ou du `switch` le plus proche.",
	["continue"] = "Passe à l'itération suivante de la boucle la plus proche.",
	["goto"] = "Saute vers une étiquette de la même fonction. Utilisé en C pour centraliser le "
		.. "nettoyage des erreurs (libérer les ressources), rarement ailleurs.",
	["return"] = "Termine la fonction et renvoie une valeur à l'appelant. Piège classique : "
		.. "**renvoyer l'adresse d'une variable locale** : elle n'existe plus après le retour "
		.. "(comportement indéfini). Oublier le `return` dans une fonction non `void` l'est aussi.",

	-- ---- Spécifique C++ ------------------------------------------------------
	["class"] = "C++ : type défini par l'utilisateur regroupant données et fonctions membres. "
		.. "Membres **privés par défaut** (contrairement à `struct`).",
	["namespace"] = "C++ : espace de noms qui évite les collisions de noms.",
	["template"] = "C++ : fonction ou classe paramétrée par un ou plusieurs types ou valeurs.",
	["typename"] = "C++ : désigne un nom de type dans un template.",
	["public"] = "C++ : membres accessibles de partout.",
	["private"] = "C++ : membres accessibles uniquement par la classe elle-même (et ses amies).",
	["protected"] = "C++ : membres accessibles par la classe et ses classes dérivées.",
	["virtual"] = "C++ : fonction membre résolue **à l'exécution** selon le type réel de l'objet.",
	["override"] = "C++11 : indique qu'une fonction redéfinit une fonction virtuelle de la classe de base.",
	["constexpr"] = "C++11 : valeur ou fonction évaluable à la compilation.",
	["nullptr"] = "C++11 : pointeur nul typé (remplace `NULL`).",
	["new"] = "C++ : alloue un objet sur le tas et appelle son constructeur. À libérer avec `delete`.",
	["delete"] = "C++ : détruit un objet créé avec `new` et libère sa mémoire. "
		.. "Double `delete` ou usage après `delete` = **comportement indéfini**.",
	["this"] = "C++ : pointeur vers l'objet courant dans une fonction membre.",
	["using"] = "C++ : alias de type, ou import d'un nom depuis un espace de noms.",
	["try"] = "C++ : début d'un bloc protégé contre les exceptions.",
	["catch"] = "C++ : bloc qui traite une exception levée dans le `try` associé.",
	["throw"] = "C++ : lève une exception.",
	["operator"] = "C++ : définit le comportement d'un opérateur pour un type.",
	["explicit"] = "C++ : interdit les conversions implicites d'un constructeur.",
	["friend"] = "C++ : donne à une fonction ou classe l'accès aux membres privés.",
	["mutable"] = "C++ : champ modifiable même dans un objet `const`.",
}

-- Rend la table accessible, utile pour la compléter depuis un autre fichier
M.docs = docs


-- -----------------------------------------------------------------------------
-- 2. Affichage d'une fiche dans une fenêtre flottante
-- -----------------------------------------------------------------------------
local function show_doc(word)
	local lines = {
		"**`" .. word .. "`**",
		"",
	}
	-- La description peut être longue : on la découpe en lignes lisibles
	for _, l in ipairs(vim.split(docs[word], "\n", { plain = true })) do
		table.insert(lines, l)
	end
	table.insert(lines, "")
	table.insert(lines, "_Mot-clé du langage. Voir cppreference.com pour le détail._")

	-- Utilise la même fenêtre flottante que le hover LSP, donc la même
	-- bordure arrondie (vim.o.winborder) que dans ton init.lua.
	vim.lsp.util.open_floating_preview(lines, "markdown", {
		focus_id = "keywords_doc",
		max_width = 80,
		wrap = true,
	})
end


-- -----------------------------------------------------------------------------
-- 3. Le comportement de K
-- -----------------------------------------------------------------------------
-- Si le mot sous le curseur est un mot-clé documenté : on affiche la fiche.
-- Sinon : on laisse clangd répondre (comportement habituel de K).
function M.hover()
	local word = vim.fn.expand("<cword>")
	if docs[word] then
		show_doc(word)
	else
		vim.lsp.buf.hover()
	end
end

-- Appliqué uniquement dans les fichiers C et C++, pour ne pas toucher à K
-- ailleurs (Rust, Lua...).
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function(args)
		vim.keymap.set("n", "K", M.hover, {
			buffer = args.buf,
			desc = "Doc d'un mot-clé C/C++, sinon hover LSP",
		})
	end,
})

return M
