/**
 * Configuration for JSON file formatting.
 * From FunkinCrew/Funkin: https://github.com/FunkinCrew/Funkin/blob/main/.prettierrc.js
 */
module.exports = {
	// Line width before Prettier tries to add new lines.
	printWidth: 80,

	// Indent with 2 spaces.
	tabs: true,
	useTabs: true,
	tabWidth: 4,

	// Use double quotes.
	singleQuote: false,
	quoteProps: "preserve",
	parser: "json",

	bracketSpacing: true, // Spacing between brackets in object literals.
	trailingComma: "none", // No trailing commas.
	semi: false, // No semicolons at ends of statements.
};
