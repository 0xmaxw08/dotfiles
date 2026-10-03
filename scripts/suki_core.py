#!/usr/bin/env python3

"""
Suki - Local Linux AI Assistant

Designed for:
    CachyOS / Linux
    Hyprland
    Ollama
    Qwen 2.5 Coder 3B

Main features:
    - Local LLM through Ollama
    - Persistent memory
    - Linux system telemetry
    - Bash command execution with confirmation
    - File creation
    - Mako notifications
    - Obsidian notes
    - Simple interactive terminal UI
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Any

from openai import OpenAI


# ============================================================
# CONFIGURATION
# ============================================================

HOME = Path.home()

SUKI_DIR = HOME / ".config" / "suki"
MEMORY_FILE = SUKI_DIR / "memory.json"

OBSIDIAN_DIR = HOME / "Documents" / "ObsidianVault"

API_BASE = os.getenv(
    "SUKI_API_BASE",
    "http://localhost:11434/v1",
)

API_KEY = os.getenv(
    "SUKI_API_KEY",
    "ollama",
)

MODEL_NAME = os.getenv(
    "SUKI_MODEL",
    "qwen2.5-coder:3b",
)

MAX_HISTORY = 12


# ============================================================
# CLIENT
# ============================================================

client = OpenAI(
    base_url=API_BASE,
    api_key=API_KEY,
)


# ============================================================
# DIRECTORIES
# ============================================================

SUKI_DIR.mkdir(parents=True, exist_ok=True)


# ============================================================
# MEMORY
# ============================================================

def load_memory() -> dict[str, Any]:
    if not MEMORY_FILE.exists():
        return {
            "memories": [],
            "preferences": {},
        }

    try:
        data = json.loads(
            MEMORY_FILE.read_text(encoding="utf-8")
        )

        if not isinstance(data, dict):
            return {
                "memories": [],
                "preferences": {},
            }

        data.setdefault("memories", [])
        data.setdefault("preferences", {})

        return data

    except Exception:
        return {
            "memories": [],
            "preferences": {},
        }


def save_memory(memory: dict[str, Any]) -> None:
    MEMORY_FILE.write_text(
        json.dumps(
            memory,
            indent=2,
            ensure_ascii=False,
        ),
        encoding="utf-8",
    )


MEMORY = load_memory()


def remember(text: str) -> str:
    text = text.strip()

    if not text:
        return "Nothing to remember."

    if text not in MEMORY["memories"]:
        MEMORY["memories"].append(text)
        save_memory(MEMORY)

    return f"Remembered: {text}"


def forget(text: str) -> str:
    text = text.strip()

    if text in MEMORY["memories"]:
        MEMORY["memories"].remove(text)
        save_memory(MEMORY)
        return f"Forgot: {text}"

    return "I don't have that stored."


def set_preference(key: str, value: str) -> str:
    key = key.strip()
    value = value.strip()

    if not key:
        return "Preference key cannot be empty."

    MEMORY["preferences"][key] = value
    save_memory(MEMORY)

    return f"Preference saved: {key} = {value}"


# ============================================================
# SYSTEM TELEMETRY
# ============================================================

def run_command(
    command: str,
    timeout: int = 5,
) -> str:

    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout,
        )

        output = result.stdout.strip()

        if result.stderr.strip():
            output += (
                "\n" + result.stderr.strip()
            )

        return output[:4000]

    except subprocess.TimeoutExpired:
        return "Command timed out."

    except Exception as exc:
        return f"Command failed: {exc}"


def get_telemetry() -> dict[str, str]:
    telemetry: dict[str, str] = {}

    telemetry["battery"] = run_command(
        "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1"
    )

    telemetry["cpu"] = run_command(
        "awk '{u=$2+$4; t=$2+$4+$5} END {if(t>0) print int(u/t*100) \"%\"}' "
        "/proc/stat"
    )

    telemetry["ram"] = run_command(
        "free -h | awk '/Mem:/ {print $3 \" / \" $2}'"
    )

    telemetry["window"] = run_command(
        "hyprctl activewindow -j 2>/dev/null | "
        "python -c \"import sys,json; "
        "d=json.load(sys.stdin); "
        "print(d.get('class','') + ' — ' + d.get('title',''))\""
    )

    return telemetry


# ============================================================
# MAKO
# ============================================================

def notify(
    message: str,
    title: str = "Suki",
) -> str:

    try:
        subprocess.run(
            [
                "makoctl",
                "notify",
                "-a",
                title,
                message,
            ],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        return "Notification sent."

    except Exception as exc:
        return f"Notification failed: {exc}"


# ============================================================
# OBSIDIAN
# ============================================================

def create_note(
    title: str,
    content: str,
) -> str:

    if not title.strip():
        return "Note title cannot be empty."

    if not OBSIDIAN_DIR.exists():
        return (
            f"Obsidian vault not found at "
            f"{OBSIDIAN_DIR}"
        )

    safe_title = re.sub(
        r'[<>:"/\\|?*]',
        "_",
        title.strip(),
    )

    note_path = OBSIDIAN_DIR / f"{safe_title}.md"

    try:
        note_path.write_text(
            content,
            encoding="utf-8",
        )

        return f"Created Obsidian note: {note_path}"

    except Exception as exc:
        return f"Failed to create note: {exc}"


# ============================================================
# FILE WRITING
# ============================================================

def write_file(
    path: str,
    content: str,
    executable: bool = False,
) -> str:

    if not path.strip():
        return "File path cannot be empty."

    file_path = Path(path).expanduser().resolve()

    # Suki is only allowed to write inside HOME.
    try:
        file_path.relative_to(HOME)

    except ValueError:
        return (
            "Permission denied. "
            "Suki can only create or modify files "
            "inside your home directory."
        )

    try:
        file_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        file_path.write_text(
            content,
            encoding="utf-8",
        )

        if executable:
            mode = file_path.stat().st_mode
            file_path.chmod(mode | 0o111)

        return (
            f"File created successfully: "
            f"{file_path}"
        )

    except Exception as exc:
        return f"Failed to write file: {exc}"


# ============================================================
# BASH EXECUTION
# ============================================================

def execute_bash(
    command: str,
    confirmed: bool = False,
) -> str:

    if not command.strip():
        return "No command supplied."

    if not confirmed:
        print()
        print("Suki wants to run:")
        print()
        print(f"  {command}")
        print()

        answer = input(
            "Allow this command? [y/N]: "
        ).strip().lower()

        if answer not in {
            "y",
            "yes",
        }:
            return "Command cancelled."

    return run_command(
        command,
        timeout=30,
    )


# ============================================================
# TOOL DEFINITIONS
# ============================================================

TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "notify",
            "description": (
                "Send a desktop notification. "
                "Use only when the user explicitly asks "
                "for a notification or when a notification "
                "is genuinely useful."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "message": {
                        "type": "string",
                    },
                    "title": {
                        "type": "string",
                    },
                },
                "required": [
                    "message",
                ],
            },
        },
    },

    {
        "type": "function",
        "function": {
            "name": "execute_bash",
            "description": (
                "Execute a Linux shell command. "
                "Use this for commands that actually need "
                "to run on the user's system."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "command": {
                        "type": "string",
                    },
                },
                "required": [
                    "command",
                ],
            },
        },
    },

    {
        "type": "function",
        "function": {
            "name": "write_file",
            "description": (
                "Create or overwrite a text file inside "
                "the user's home directory. "
                "Use this whenever the user asks you to "
                "create, make, write, save, or generate a file."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "path": {
                        "type": "string",
                        "description": (
                            "Absolute path of the file."
                        ),
                    },
                    "content": {
                        "type": "string",
                        "description": (
                            "Complete contents of the file."
                        ),
                    },
                    "executable": {
                        "type": "boolean",
                        "description": (
                            "Whether the file should be executable."
                        ),
                    },
                },
                "required": [
                    "path",
                    "content",
                ],
            },
        },
    },

    {
        "type": "function",
        "function": {
            "name": "create_note",
            "description": (
                "Create a Markdown note in the user's "
                "Obsidian vault."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "title": {
                        "type": "string",
                    },
                    "content": {
                        "type": "string",
                    },
                },
                "required": [
                    "title",
                    "content",
                ],
            },
        },
    },

    {
        "type": "function",
        "function": {
            "name": "remember",
            "description": (
                "Store a useful piece of information "
                "in Suki's persistent memory."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "text": {
                        "type": "string",
                    },
                },
                "required": [
                    "text",
                ],
            },
        },
    },

    {
        "type": "function",
        "function": {
            "name": "forget",
            "description": (
                "Remove a previously stored memory."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "text": {
                        "type": "string",
                    },
                },
                "required": [
                    "text",
                ],
            },
        },
    },

    {
        "type": "function",
        "function": {
            "name": "set_preference",
            "description": (
                "Store a user preference."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "key": {
                        "type": "string",
                    },
                    "value": {
                        "type": "string",
                    },
                },
                "required": [
                    "key",
                    "value",
                ],
            },
        },
    },
]


# ============================================================
# TOOL EXECUTION
# ============================================================

def execute_tool(
    name: str,
    arguments: dict[str, Any],
) -> str:

    if name == "notify":
        return notify(
            message=str(
                arguments.get(
                    "message",
                    "",
                )
            ),
            title=str(
                arguments.get(
                    "title",
                    "Suki",
                )
            ),
        )

    if name == "execute_bash":
        return execute_bash(
            command=str(
                arguments.get(
                    "command",
                    "",
                )
            )
        )

    if name == "write_file":
        return write_file(
            path=str(
                arguments.get(
                    "path",
                    "",
                )
            ),
            content=str(
                arguments.get(
                    "content",
                    "",
                )
            ),
            executable=bool(
                arguments.get(
                    "executable",
                    False,
                )
            ),
        )

    if name == "create_note":
        return create_note(
            title=str(
                arguments.get(
                    "title",
                    "",
                )
            ),
            content=str(
                arguments.get(
                    "content",
                    "",
                )
            ),
        )

    if name == "remember":
        return remember(
            str(
                arguments.get(
                    "text",
                    "",
                )
            )
        )

    if name == "forget":
        return forget(
            str(
                arguments.get(
                    "text",
                    "",
                )
            )
        )

    if name == "set_preference":
        return set_preference(
            key=str(
                arguments.get(
                    "key",
                    "",
                )
            ),
            value=str(
                arguments.get(
                    "value",
                    "",
                )
            ),
        )

    return f"Unknown tool: {name}"


# ============================================================
# TOOL JSON PARSER
# ============================================================

def parse_json_tool_call(
    content: str,
) -> tuple[str, dict[str, Any]] | None:

    if not content:
        return None

    text = content.strip()

    # Remove Markdown code fences.
    text = re.sub(
        r"^```(?:json)?\s*",
        "",
        text,
        flags=re.IGNORECASE,
    )

    text = re.sub(
        r"\s*```$",
        "",
        text,
    )

    text = text.strip()

    # Direct JSON object.
    if text.startswith("{") and text.endswith("}"):
        try:
            data = json.loads(text)

            if (
                isinstance(data, dict)
                and isinstance(data.get("name"), str)
            ):
                arguments = data.get(
                    "arguments",
                    {},
                )

                if not isinstance(
                    arguments,
                    dict,
                ):
                    arguments = {}

                return (
                    data["name"],
                    arguments,
                )

        except json.JSONDecodeError:
            pass

    # Try to locate JSON embedded in other text.
    match = re.search(
        r'\{.*"name"\s*:\s*"[^"]+".*\}',
        text,
        flags=re.DOTALL,
    )

    if match:
        try:
            data = json.loads(
                match.group(0)
            )

            if (
                isinstance(data, dict)
                and isinstance(data.get("name"), str)
            ):
                arguments = data.get(
                    "arguments",
                    {},
                )

                if isinstance(
                    arguments,
                    dict,
                ):
                    return (
                        data["name"],
                        arguments,
                    )

        except json.JSONDecodeError:
            pass

    return None


# ============================================================
# SYSTEM PROMPT
# ============================================================

SYSTEM_PROMPT = """
You are Suki, a local Linux AI assistant.

You run locally on the user's Linux computer using
Qwen 2.5 Coder 3B.

PERSONALITY:
- Helpful
- Calm
- Concise
- Slightly warm
- Practical
- Technical when appropriate
- Never unnecessarily verbose

GENERAL RULES:

1. Answer normal questions normally.

2. Do NOT use tools for greetings.

3. Do NOT call notify for a normal greeting.

4. Do NOT refuse normal programming or Linux requests.

5. When the user asks to create, make, write, generate,
   save, or modify a file, use write_file.

6. When creating a script, generate the COMPLETE script
   yourself and put it into write_file.

7. NEVER tell the user to open nano or vim when the user
   explicitly asked Suki to create the file.

8. NEVER use execute_bash merely to open an editor.

9. Use execute_bash when a shell command genuinely needs
   to be executed.

10. Do not invent successful tool execution.
    If a tool fails, explain the failure.

FILE CREATION EXAMPLE:

User:
"make a bash script for a simple calculator"

Correct behavior:
- Generate a complete Bash calculator.
- Call write_file.
- Use a sensible path such as ~/calc.sh if no path
  was specified.
- Set executable=true.
- Tell the user that the file was created.

Incorrect behavior:
- Refusing the request.
- Opening nano.
- Giving only a code snippet when the user asked
  for the file to be created.

SECURITY:

- Suki may only write files inside the user's home
  directory.
- Bash commands require confirmation.
- Do not execute destructive commands unnecessarily.
"""


# ============================================================
# SPECIAL FILE REQUEST DETECTION
# ============================================================

def looks_like_file_request(
    text: str,
) -> bool:

    text_lower = text.lower()

    file_verbs = (
        "make ",
        "create ",
        "write ",
        "generate ",
        "save ",
        "build ",
    )

    file_words = (
        "script",
        "file",
        ".sh",
        ".py",
        ".lua",
        ".json",
        ".txt",
        ".md",
        ".conf",
        ".desktop",
    )

    has_verb = any(
        text_lower.startswith(verb)
        or f" {verb.strip()} " in text_lower
        for verb in file_verbs
    )

    has_file_word = any(
        word in text_lower
        for word in file_words
    )

    return has_verb and has_file_word


# ============================================================
# DETERMINISTIC FILE REQUEST PROMPT
# ============================================================

def get_file_creation_response(
    user_text: str,
) -> str | None:

    """
    Qwen 3B can occasionally refuse or fail to emit
    native tool calls.

    For explicit file requests, ask it for a strict
    machine-readable response instead.
    """

    prompt = f"""
The user wants a file created.

USER REQUEST:
{user_text}

You MUST create the requested file.

Return ONLY valid JSON.

Use exactly this structure:

{{
  "path": "/home/max/filename",
  "content": "COMPLETE FILE CONTENT HERE",
  "executable": true
}}

Rules:
- Do not refuse.
- Do not explain.
- Do not use Markdown.
- Do not use code fences.
- Put the complete file contents inside "content".
- If the user did not specify a path, choose a sensible
  filename in /home/max/.
- If it is a shell script, executable must be true.
"""

    try:
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You are a file-generation engine. "
                        "You must fulfill normal programming "
                        "requests."
                    ),
                },
                {
                    "role": "user",
                    "content": prompt,
                },
            ],
            temperature=0.1,
        )

        content = (
            response.choices[0].message.content
            or ""
        ).strip()

        # Remove fences if Qwen adds them anyway.
        content = re.sub(
            r"^```(?:json)?\s*",
            "",
            content,
            flags=re.IGNORECASE,
        )

        content = re.sub(
            r"\s*```$",
            "",
            content,
        )

        try:
            data = json.loads(
                content.strip()
            )

        except json.JSONDecodeError:
            # Try extracting the JSON object.
            match = re.search(
                r"\{.*\}",
                content,
                flags=re.DOTALL,
            )

            if not match:
                return None

            try:
                data = json.loads(
                    match.group(0)
                )

            except json.JSONDecodeError:
                return None

        if not isinstance(data, dict):
            return None

        path = data.get("path")
        file_content = data.get("content")
        executable = bool(
            data.get(
                "executable",
                False,
            )
        )

        if not isinstance(path, str):
            return None

        if not isinstance(
            file_content,
            str,
        ):
            return None

        result = write_file(
            path=path,
            content=file_content,
            executable=executable,
        )

        return result

    except Exception:
        return None


# ============================================================
# NATIVE TOOL RESPONSE HANDLING
# ============================================================

def handle_native_tool_calls(
    response: Any,
    messages: list[dict[str, Any]],
) -> str | None:

    message = response.choices[0].message

    tool_calls = getattr(
        message,
        "tool_calls",
        None,
    )

    if not tool_calls:
        return None

    messages.append(
        {
            "role": "assistant",
            "content": message.content or "",
            "tool_calls": [
                {
                    "id": call.id,
                    "type": "function",
                    "function": {
                        "name": call.function.name,
                        "arguments": call.function.arguments,
                    },
                }
                for call in tool_calls
            ],
        }
    )

    for call in tool_calls:
        try:
            arguments = json.loads(
                call.function.arguments
            )

        except Exception:
            arguments = {}

        result = execute_tool(
            call.function.name,
            arguments,
        )

        messages.append(
            {
                "role": "tool",
                "tool_call_id": call.id,
                "content": result,
            }
        )

    try:
        final_response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=messages,
            tools=TOOLS,
            temperature=0.3,
        )

        return (
            final_response.choices[0].message.content
            or ""
        ).strip()

    except Exception as exc:
        return f"Tool completed, but final response failed: {exc}"


# ============================================================
# MAIN MODEL RESPONSE
# ============================================================

def get_response(
    user_text: str,
    history: list[dict[str, Any]],
) -> str:

    # --------------------------------------------------------
    # Explicit file creation path
    # --------------------------------------------------------

    if looks_like_file_request(user_text):
        result = get_file_creation_response(
            user_text
        )

        if result:
            return result

    # --------------------------------------------------------
    # Normal model conversation
    # --------------------------------------------------------

    telemetry = get_telemetry()

    memory_text = json.dumps(
        MEMORY,
        ensure_ascii=False,
    )

    telemetry_text = json.dumps(
        telemetry,
        ensure_ascii=False,
    )

    messages: list[dict[str, Any]] = [
        {
            "role": "system",
            "content": SYSTEM_PROMPT,
        },
        {
            "role": "system",
            "content": (
                f"Persistent memory:\n{memory_text}\n\n"
                f"Current system telemetry:\n{telemetry_text}"
            ),
        },
    ]

    messages.extend(
        history[-MAX_HISTORY:]
    )

    messages.append(
        {
            "role": "user",
            "content": user_text,
        }
    )

    try:
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=messages,
            tools=TOOLS,
            temperature=0.3,
        )

    except Exception as exc:
        return (
            f"Could not contact the local model:\n"
            f"{exc}"
        )

    # --------------------------------------------------------
    # Native tool call
    # --------------------------------------------------------

    native_result = handle_native_tool_calls(
        response,
        messages,
    )

    if native_result is not None:
        return native_result

    # --------------------------------------------------------
    # Text response
    # --------------------------------------------------------

    content = (
        response.choices[0].message.content
        or ""
    ).strip()

    # --------------------------------------------------------
    # Qwen text-based fake tool call
    # --------------------------------------------------------

    parsed_tool = parse_json_tool_call(
        content
    )

    if parsed_tool:
        tool_name, arguments = parsed_tool

        result = execute_tool(
            tool_name,
            arguments,
        )

        followup_messages = messages + [
            {
                "role": "assistant",
                "content": content,
            },
            {
                "role": "user",
                "content": (
                    f"The tool `{tool_name}` was executed.\n"
                    f"Result:\n{result}\n\n"
                    "Give the user a concise normal response."
                ),
            },
        ]

        try:
            followup = client.chat.completions.create(
                model=MODEL_NAME,
                messages=followup_messages,
                temperature=0.3,
            )

            return (
                followup.choices[0].message.content
                or result
            ).strip()

        except Exception:
            return result

    # --------------------------------------------------------
    # Refusal recovery
    # --------------------------------------------------------

    refusal_patterns = (
        "i'm sorry, but i can't help",
        "i’m sorry, but i can’t help",
        "i cannot help with that",
        "i can't help with that",
        "i’m unable to help",
        "i'm unable to help",
    )

    if any(
        pattern in content.lower()
        for pattern in refusal_patterns
    ):
        retry_messages = [
            {
                "role": "system",
                "content": SYSTEM_PROMPT
                + """

The previous answer incorrectly refused a normal
Linux/programming request.

Do not refuse normal programming tasks.
Answer the user's request directly.
""",
            },
            {
                "role": "user",
                "content": user_text,
            },
        ]

        try:
            retry = client.chat.completions.create(
                model=MODEL_NAME,
                messages=retry_messages,
                tools=TOOLS,
                temperature=0.1,
            )

            retry_content = (
                retry.choices[0].message.content
                or ""
            ).strip()

            retry_tool = parse_json_tool_call(
                retry_content
            )

            if retry_tool:
                name, arguments = retry_tool

                result = execute_tool(
                    name,
                    arguments,
                )

                return result

            return retry_content

        except Exception:
            pass

    return content


# ============================================================
# CONNECTION TEST
# ============================================================

def test_connection() -> bool:

    try:
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {
                    "role": "user",
                    "content": "Reply with exactly: OK",
                }
            ],
            temperature=0,
        )

        content = (
            response.choices[0].message.content
            or ""
        ).strip()

        return bool(content)

    except Exception as exc:
        print()
        print("Could not connect to Ollama.")
        print()
        print(f"API:   {API_BASE}")
        print(f"Model: {MODEL_NAME}")
        print()
        print(f"Error: {exc}")
        print()

        return False


# ============================================================
# GREETING
# ============================================================

def startup_greeting() -> None:

    print()
    print("╭────────────────────────────────────────────╮")
    print("│                  SUKI                      │")
    print("│           Local Linux Assistant            │")
    print("╰────────────────────────────────────────────╯")
    print()
    print(f"Model: {MODEL_NAME}")
    print(f"API:   {API_BASE}")
    print()
    print("Type 'exit' or 'quit' to leave.")
    print()


# ============================================================
# INTERACTIVE LOOP
# ============================================================

def interactive() -> None:

    startup_greeting()

    if not test_connection():
        return

    history: list[dict[str, Any]] = []

    while True:

        try:
            user_text = input("You: ").strip()

        except KeyboardInterrupt:
            print()
            print("Suki: Goodbye.")
            break

        except EOFError:
            print()
            break

        if not user_text:
            continue

        if user_text.lower() in {
            "exit",
            "quit",
        }:
            print()
            print("Suki: Goodbye.")
            break

        # ----------------------------------------------------
        # Deterministic greetings
        # ----------------------------------------------------

        if user_text.lower() in {
            "hi",
            "hello",
            "hey",
            "yo",
            "sup",
        }:
            print()
            print(
                "Suki: Hey. What are we working on?"
            )
            print()
            continue

        try:
            response = get_response(
                user_text,
                history,
            )

        except Exception as exc:
            response = (
                f"Something went wrong: {exc}"
            )

        print()
        print(f"Suki: {response}")
        print()

        history.append(
            {
                "role": "user",
                "content": user_text,
            }
        )

        history.append(
            {
                "role": "assistant",
                "content": response,
            }
        )

        if len(history) > MAX_HISTORY:
            del history[:-MAX_HISTORY]


# ============================================================
# COMMAND LINE
# ============================================================

def main() -> None:

    parser = argparse.ArgumentParser(
        description="Suki local Linux assistant"
    )

    parser.add_argument(
        "--greet",
        action="store_true",
        help="Show Suki's greeting and exit.",
    )

    args = parser.parse_args()

    if args.greet:
        startup_greeting()
        return

    interactive()


# ============================================================
# ENTRY POINT
# ============================================================

if __name__ == "__main__":
    main()
