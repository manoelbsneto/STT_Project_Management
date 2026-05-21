# PMO Cockpit

Real-time monitoring dashboard for the M2 multi-agent execution.

## Quickstart

```bash
cd Web_MD_Viewer
node cockpit-server.js
```

Open http://localhost:7777

## Configuration

Edit `cockpit-config.json`:
```json
{
  "port": 7777,
  "host": "127.0.0.1",
  "polling_default_ms": 5000,
  "activity_log_default_limit": 50
}
```

## Development

```bash
node --test tests/
```

## Architecture

See `.planning/cockpit/SPECIFICATION.md`
