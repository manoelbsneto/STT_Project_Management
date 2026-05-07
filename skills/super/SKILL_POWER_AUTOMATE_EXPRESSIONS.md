# Skill — Power Automate Expression Troubleshooting

Use this skill when analyzing Power Automate expressions, Parse JSON, JSON paths, variables, arrays, objects, null handling, dates, type coercion, regex, encode/decode and runtime flow errors.

## Objective
Return robust, minimal, safe, validated fixes for expression problems.

## Mandatory Analysis
For every expression issue, identify:
1. Runtime surface: Power Automate Cloud Flow, Azure Logic Apps, Power Fx, Power Automate Desktop, or other.
2. Root cause: wrong function, syntax, type, null property, empty array, missing field, invalid date, wrong locale, wrong JSON path, wrong loop context, wrong trigger/body reference.
3. Safer alternative: native connector action, Compose, Condition, Select, Filter array, Parse JSON, variables, or expression only if justified.

## Rules
- Never invent functions.
- Never mix Power Fx syntax with Power Automate syntax.
- Never call an expression safe unless null/type/empty cases were considered.
- Do not use regex unless native actions are insufficient.
- Avoid `first()` unless empty-array handling exists.
- Avoid direct deep JSON paths unless missing-property handling exists.
- Validate Brazil date format and timezone where relevant.
- Prefer readable expressions over clever one-liners.

## Lightweight Quality Gates
| Gate | Question |
|---|---|
| Compatibility | Does the function exist in the exact runtime surface? |
| Syntax | Are parentheses, quotes, commas, brackets and paths valid? |
| Null safety | What happens with null, empty string, missing field or empty array? |
| Type safety | Is the value string, number, boolean, object or array? |
| Date/locale | Is the date format unambiguous? Is timezone handled? |
| Encoding | Are Unicode, quotes, line breaks, URL encoding or base64 involved? |
| Regression | Does the fix preserve valid existing cases? |
| Observability | Can the failure be diagnosed without logging secrets/PII? |

## Required Output Per Expression Fix
- Problem
- Runtime surface
- Root cause
- Corrected expression
- Where to apply
- Example input
- Expected output
- Edge cases
- Residual risk
- Validation method
