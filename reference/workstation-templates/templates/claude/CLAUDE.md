# Claude Code Operating Scope

Claude Code owns active implementation, project-local hooks, subagent workflows, tests, and multi-file feature work.

## Responsibilities

- Implement product features.
- Run project-specific tests.
- Maintain Claude Code hooks, commands, agents, and skills.
- Use Docker MCP for shared external tools.
- Save durable memories to Obsidian.

## Boundaries

- Do not place secrets in project files, memory notes, or public templates.
- Do not bypass hooks unless the operator explicitly approves.
- Keep large private session logs out of Git.

## Shared Tooling

MCP routing should use:

```json
{
  "mcpServers": {
    "MCP_DOCKER": {
      "command": "docker",
      "args": ["mcp", "gateway", "run"]
    }
  }
}
```

