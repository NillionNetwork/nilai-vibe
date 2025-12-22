# nilai-vibe

[![Python Version](https://img.shields.io/badge/python-3.12%2B-blue)](https://www.python.org/downloads/release/python-3120/)


**nilAI’s open-source CLI coding assistant.**

nilai-vibe is a command-line coding assistant powered by nilAI models. It provides a conversational interface to your codebase, allowing you to use natural language to explore, modify, and interact with your projects through a powerful set of tools.

> [!WARNING]
> nilai-vibe works on Windows, but we officially support and target UNIX environments.

### One-line install (recommended)

**Linux and macOS**

```bash
curl -LsSf https://nilai.ai/vibe/install.sh | bash
```

**Windows**

First, install uv

```bash
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Then, use the uv command below.

### Using uv

```bash
uv tool install nilai-vibe
```

### Using pip

```bash
pip install nilai-vibe
```

## Features

- **Interactive Chat**: A conversational AI agent that understands your requests and breaks down complex tasks.
- **Powerful Toolset**: A suite of tools for file manipulation, code searching, version control, and command execution, right from the chat prompt.
  - Read, write, and patch files (`read_file`, `write_file`, `search_replace`).
  - Execute shell commands in a stateful terminal (`bash`).
  - Recursively search code with `grep` (with `ripgrep` support).
  - Manage a `todo` list to track the agent's work.
- **Project-Aware Context**: nilai-vibe automatically scans your project's file structure and Git status to provide relevant context to the agent, improving its understanding of your codebase.
- **Advanced CLI Experience**: Built with modern libraries for a smooth and efficient workflow.
  - Autocompletion for slash commands (`/`) and file paths (`@`).
  - Persistent command history.
  - Beautiful themes.
- **Highly Configurable**: Customize models, providers, tool permissions, and UI preferences through a simple `config.toml` file.
- **Safety First**: Features tool execution approval.

## Quick Start

1. Navigate to your project's root directory:

   ```bash
   cd /path/to/your/project
   ```

2. Run nilai-vibe:

   ```bash
   uv run vibe
   ```

3. If this is your first time running nilai-vibe, it will:

   - Create a default configuration file at `~/.vibe/config.toml`.
   - Prompt you to enter your API key if it's not already configured.
   - Save your API key to `~/.vibe/.env` for future use.

4. Start interacting with the agent.

   ```text
   > Can you find all instances of the word "TODO" in the project?

   🤖 The user wants to find all instances of "TODO". The `grep` tool is perfect for this. I will use it to search the current directory.

   > grep(pattern="TODO", path=".")

   ... (grep tool output) ...

   🤖 I found the following "TODO" comments in your project.
   ```

## Usage

### Interactive Mode

Run `vibe` to enter the interactive chat loop.

- **Multi-line Input**: Press `Ctrl+J` or `Shift+Enter` for select terminals to insert a newline.
- **File Paths**: Reference files in your prompt using the `@` symbol for smart autocompletion (for example, `> Read the file @src/agent.py`).
- **Shell Commands**: Prefix any command with `!` to execute it directly in your shell, bypassing the agent (for example, `> !ls -l`).

You can start nilai-vibe with an initial prompt using:

```bash
vibe "Refactor the main function in cli/main.py to be more modular."
```

The `--auto-approve` flag automatically approves all tool executions without prompting. In interactive mode, you can also toggle auto-approve on or off using `Shift+Tab`.

### Programmatic Mode

You can run nilai-vibe non-interactively by piping input or using the `--prompt` flag, which is useful for scripting:

```bash
vibe --prompt "Refactor the main function in cli/main.py to be more modular."
```

By default, programmatic mode uses `auto-approve`.

### Slash Commands

Use slash commands for meta-actions and configuration changes during a session.

## Configuration

nilai-vibe is configured via a `config.toml` file. It looks for this file first in `./.vibe/config.toml` and then falls back to `~/.vibe/config.toml`.

### API Key Configuration

nilai-vibe supports multiple ways to configure your API keys:

1. **Interactive Setup (recommended for first-time users)**: When you run nilai-vibe for the first time or if your API key is missing, it prompts you to enter it. The key is securely saved to `~/.vibe/.env` for future sessions.

2. **Environment Variables**: Set your nilAI API key as an environment variable:

   ```bash
   export NILAI_API_KEY="your_nilai_api_key"
   export NILAI_API_BASE="your_nilai_api_base_url"
   ```

3. **`.env` File**: Create a `.env` file in `~/.vibe/` and add your API keys:

   ```bash
   NILAI_API_KEY=your_nilai_api_key
   NILAI_API_BASE=your_nilai_api_base_url
   ```

nilai-vibe automatically loads API keys from `~/.vibe/.env` on startup. Environment variables take precedence over the `.env` file if both are set.

The `.env` file is specifically for API keys and other provider credentials. General nilai-vibe configuration is done in `config.toml`.

### Custom System Prompts

You can create custom system prompts to replace the default one (`prompts/cli.md`). Create a markdown file in the `~/.vibe/prompts/` directory with your custom prompt content.

To use a custom system prompt, set the `system_prompt_id` in your configuration to match the filename (without the `.md` extension):

```toml
system_prompt_id = "my_custom_prompt"
```

This loads the prompt from `~/.vibe/prompts/my_custom_prompt.md`.

### Custom Agent Configurations

You can create custom agent configurations for specific use cases by adding agent-specific TOML files in the `~/.vibe/agents/` directory.

To use a custom agent, run nilai-vibe with the `--agent` flag:

```bash
vibe --agent my_custom_agent
```

nilai-vibe looks for a file named `my_custom_agent.toml` in the agents directory and applies its configuration.

Example custom agent configuration (`~/.vibe/agents/redteam.toml`):

```toml
active_model = "devstral-2"
system_prompt_id = "redteam"

disabled_tools = ["search_replace", "write_file"]

[tools.bash]
permission = "always"

[tools.read_file]
permission = "always"
```

This configuration assumes that you have set up a redteam prompt named `~/.vibe/prompts/redteam.md`.

### MCP Server Configuration

You can configure MCP (Model Context Protocol) servers to extend nilai-vibe’s capabilities. Add MCP server configurations under the `mcp_servers` section:

```toml
[[mcp_servers]]
name = "my_http_server"
transport = "http"
url = "http://localhost:8000"
headers = { "Authorization" = "Bearer my_token" }
api_key_env = "MY_API_KEY_ENV_VAR"
api_key_header = "Authorization"
api_key_format = "Bearer {token}"

[[mcp_servers]]
name = "my_streamable_server"
transport = "streamable-http"
url = "http://localhost:8001"
headers = { "X-API-Key" = "my_api_key" }

[[mcp_servers]]
name = "fetch_server"
transport = "stdio"
command = "uvx"
args = ["mcp-server-fetch"]
```

Supported transports:

- `http`: Standard HTTP transport.
- `streamable-http`: HTTP transport with streaming support.
- `stdio`: Standard input/output transport for local processes.

Key fields:

- `name`: A short alias for the server (used in tool names).
- `transport`: The transport type.
- `url`: Base URL for HTTP transports.
- `headers`: Additional HTTP headers.
- `api_key_env`: Environment variable containing the API key.
- `command`: Command to run for stdio transport.
- `args`: Additional arguments for stdio transport.

MCP tools are named using the pattern `{server_name}_{tool_name}` and can be configured with permissions like built-in tools:

```toml
[tools.fetch_server_get]
permission = "always"

[tools.my_http_server_query]
permission = "ask"
```

### Enable or Disable Tools with Patterns

You can control which tools are active using `enabled_tools` and `disabled_tools`. These fields support exact names, glob patterns, and regular expressions.

Examples:

```toml
enabled_tools = ["serena_*"]
enabled_tools = ["re:^serena_.*$"]
enabled_tools = ["serena.*"]
disabled_tools = ["mcp_*", "grep"]
```

Notes:

- MCP tool names use underscores, for example, `serena_list` not `serena.list`.
- Regex patterns are matched against the full tool name using `fullmatch`.

### Custom Vibe Home Directory

By default, nilai-vibe stores its configuration in `~/.vibe/`. You can override this by setting the `VIBE_HOME` environment variable:

```bash
export VIBE_HOME="/path/to/custom/vibe/home"
```

This affects where nilai-vibe looks for:

- `config.toml` for main configuration.
- `.env` for API keys.
- `agents/` for custom agent configurations.
- `prompts/` for custom system prompts.
- `tools/` for custom tools.
- `logs/` for session logs.

## Resources

- [CHANGELOG](CHANGELOG.md) - See what is new in each version.

## License

This project is licensed under the Apache License, Version 2.0. See the [LICENSE](LICENSE) file for the full license text.
