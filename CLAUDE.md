# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Application

```bash
# Install dependencies
uv sync

# Start the server (runs uvicorn on port 8000)
./run.sh

# Or manually
cd backend && uv run uvicorn app:app --reload --port 8000
```

Requires a `.env` file in the project root with `ANTHROPIC_API_KEY=...`.

The frontend is served as static files by FastAPI at `http://localhost:8000`. There is no separate frontend build step.

## Architecture

This is a RAG (Retrieval-Augmented Generation) chatbot. The backend is in `backend/`, the frontend is plain HTML/CSS/JS in `frontend/`, and course documents live in `docs/`.

### RAG Pipeline

Retrieval is implemented as a **Claude tool**, not a pre-retrieval step. On each query:

1. Claude receives the user question + a `search_course_content` tool definition
2. Claude decides whether to call the tool (course-specific questions) or answer directly (general knowledge)
3. If the tool is called, `VectorStore.search()` runs semantic similarity against ChromaDB and returns the top-5 matching chunks
4. Claude receives the chunks as a `tool_result` and generates the final answer

This means general knowledge questions never touch ChromaDB.

### Component Responsibilities

- **`rag_system.py`** — Orchestrator. Wires together all components and is the single entry point called by `app.py`.
- **`ai_generator.py`** — All Claude API interactions. Handles the two-call agentic loop (initial call → tool execution → follow-up call).
- **`vector_store.py`** — ChromaDB wrapper with two collections: `course_catalog` (course titles for fuzzy name resolution) and `course_content` (chunked lesson text for semantic search).
- **`document_processor.py`** — Parses `.txt` course files into `Course`/`Lesson`/`CourseChunk` models and splits content into overlapping chunks.
- **`search_tools.py`** — Defines `CourseSearchTool` (implements the Anthropic tool interface) and `ToolManager` (registry + executor).
- **`session_manager.py`** — In-memory conversation history; conversation context is passed to Claude as a formatted string in the system prompt, not as message history.

### Course Document Format

Documents in `docs/` must follow this structure for `DocumentProcessor` to parse them correctly:

```
Course Title: <title>
Course Link: <url>
Course Instructor: <name>

Lesson 1: <title>
Lesson Link: <url>
<lesson content>

Lesson 2: <title>
...
```

### Key Configuration (`backend/config.py`)

| Setting | Default | Purpose |
|---|---|---|
| `ANTHROPIC_MODEL` | `claude-sonnet-4-20250514` | Model for generation |
| `EMBEDDING_MODEL` | `all-MiniLM-L6-v2` | Sentence-transformers model for embeddings |
| `CHUNK_SIZE` | 800 | Characters per content chunk |
| `CHUNK_OVERLAP` | 100 | Overlap between adjacent chunks |
| `MAX_RESULTS` | 5 | Top-k chunks returned per search |
| `MAX_HISTORY` | 2 | Conversation exchanges retained per session |

### Adding a New Tool

1. Create a class extending `Tool` (abstract base in `search_tools.py`) implementing `get_tool_definition()` and `execute()`
2. Register it in `RAGSystem.__init__()` via `self.tool_manager.register_tool(...)`

The `AIGenerator` automatically passes all registered tool definitions to Claude and routes tool calls through `ToolManager.execute_tool()`.

## Dependencies

Always use `uv` to manage dependencies (e.g. `uv add <package>`, `uv sync`). Do not use `pip` directly. Use `uv run python <file>.py` instead of `python <file>.py`.

## Communication Style

When explaining code structure or workflow, always include the relevant code snippets with `file:line` references alongside the explanation.
