# Skill — Copilot Studio Agent Audit

Use this skill when analyzing Copilot Studio agent files, topics, actions, tools, orchestration and runtime behavior.

## Objective
Ensure the Copilot agent can execute the vacation-management journey end-to-end without broken topics, missing actions, missing inputs, bad outputs or confusing user interactions.

## Inspect
- Agent metadata
- Topics
- Trigger phrases
- Generative orchestration settings if visible
- Action/tool references
- Power Automate flow references
- Input variable mappings
- Output variable mappings
- User identity assumptions
- Fallback and escalation
- Topic conflicts
- Confirmation before creating requests
- Error messages returned to users

## Critical Failure Patterns
- Topic calls an action that does not exist.
- Topic passes wrong variable name to a flow.
- Flow expects input that the topic does not provide.
- Flow returns output that topic does not consume.
- Topic assumes current user email exists but authentication is not configured.
- Topic does not handle employee not found, manager not found or balance not found.
- Multiple topics trigger for the same user intent.
- Copilot says success without verifying flow response.

## Required Output Per Topic
| Field | Required |
|---|---|
| Topic name | Yes |
| File path | Yes |
| Trigger/intention | Yes |
| Actions called | Yes |
| Inputs passed | Yes |
| Outputs consumed | Yes |
| Failure risks | Yes |
| MVP required? | Yes |
| Fix recommendation | Yes |
| Test scenario | Yes |

## Design Preference
Keep the agent simple: Greeting/Help, Check Balance, Request Vacation, Check Status, Error/Fallback/Escalation.
