# Project Rules for AI Assistants

## Markdown Formatting

When creating or editing markdown files (`.md`) in this project:

1. **Read and follow** the markdownlint configuration at `.markdownlint.yaml` in the project root
2. **Apply all rules** defined in that configuration file
3. **All markdown output must pass** `pre-commit run markdownlint` without errors

The `.markdownlint.yaml` file is the single source of truth for markdown formatting rules.
Refer to it directly for current rule settings, including which rules are enabled, disabled,
or configured with specific parameters.

Rule documentation: <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md>

## YAML Formatting

When creating or editing YAML files (`.yaml`, `.yml`) in this project:

1. **Read and follow** the yamllint configuration at `.yamllint.yaml` in the project root
2. **Apply all rules** defined in that configuration file
3. **All YAML output must pass** `pre-commit run yamllint` without errors

The `.yamllint.yaml` file is the single source of truth for YAML formatting rules.
Refer to it directly for current rule settings, including which rules are enabled, disabled,
or configured with specific parameters.

Rule documentation: <https://yamllint.readthedocs.io/en/stable/rules.html>
