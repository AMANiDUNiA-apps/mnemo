# Contributing to mnemo

Thank you for your interest in contributing to **mnemo** — the LLM Brain Memory Manager!

## Current Status

**This repository currently contains the architecture specification and initial folder skeleton.** The reference implementation is being developed as a set of agent profiles against this spec, and is actively in progress.

We welcome contributions to:
- The specification (`brain-memory-manager-spec.md`)
- The folder structure and templates (`brain-memory/`)
- Configuration templates (`brain-memory/config.yaml.example`)
- Documentation (`README.md`, this file)

## How to Contribute

### 1. Fork & Clone
```bash
git clone https://github.com/amaniagent/mnemo.git
cd mnemo
```

### 2. Create a Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b spec/your-spec-change
```

### 3. Make Your Changes
- **Spec changes**: Edit `brain-memory-manager-spec.md`
- **Structure changes**: Modify folders under `brain-memory/`
- **Templates**: Update `brain-memory/config.yaml.example` or add new templates
- **Docs**: Update `README.md`, `CONTRIBUTING.md`

### 4. Commit with Conventional Commits
```bash
git commit -m "spec: add sensitivity layer retention policy"
git commit -m "structure: add agent-memory/_all/skills-index.md template"
git commit -m "docs: fix README contributing link"
```

### 5. Push & Open PR
```bash
git push origin your-branch
# Open PR via GitHub UI
```

## Contribution Guidelines

### Specification Changes
- Use the **sequential clarification** approach: propose one clear change at a time
- Document the rationale in the PR description
- Reference any related issues or discussions

### Folder Structure Changes
- Follow the existing layer architecture (6 layers + sensitivity)
- Add `.gitkeep` files for empty directories
- Include an `index.md` in each layer root with a file table
- Use the doc-size tiering (xs/s/m/l/xl) naming convention

### Configuration Templates
- Use `.example` suffix for templates
- Document all fields with comments
- Use `${ENV_VAR}` for secrets

### Code of Conduct
- Be respectful and constructive
- Follow the [Contributor Covenant](https://www.contributor-covenant.org/)

## Development Setup

The reference implementation is designed to run as a set of specialized agent profiles, one per layer:
- `brain-memory-manager` (orchestrator)
- `brain-user-memory`, `brain-agent-memory`, `brain-session-memory`
- `brain-project-memory`, `brain-knowledge-memory`, `brain-longterm-memory`
- `brain-sensitivity`

To run locally, you'll need:
1. An LLM agent runtime that supports multiple profiles/sub-agents with filesystem access (e.g. Claude Code, or any agent framework that can load per-profile system prompts)
2. The 8 brain-* profiles configured per the spec
3. MCP servers: `gortex`, `pageindex`, `lightrag`, `rag-anything`
4. Langfuse instance (optional, for telemetry)

## Reporting Issues

Use GitHub Issues for:
- Spec clarifications / questions
- Missing folder structures or templates
- Documentation improvements
- Bug reports (once implementation lands)

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

**mnemo** — *Memory for machines that think.*