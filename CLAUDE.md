# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

swagger-ui-py is a Python library that provides seamless Swagger UI integration for 9+ Python web frameworks. It offers a unified, framework-agnostic API (`api_doc()`) that automatically detects the framework and registers routes for interactive OpenAPI documentation.

**Supported frameworks:** Flask, Tornado, Sanic, AIOHTTP, Quart, Starlette, Falcon, Bottle, Chalice

## Common Commands

```bash
# Run all tests
make pytest

# Run a single test file
pytest -s test/flask_test.py

# Run a specific test
pytest -s test/flask_test.py::test_flask -k "auto"

# Format code
make format

# Check formatting (CI uses this)
make format-check

# Build wheel
make whl

# Install locally for testing
make install

# Update Swagger UI/Editor versions
tox -e update
# or
python tools/update.py --ui-version=v5.25.3 --editor-version=v4.14.6
```

## Architecture

### Core Components

```
swagger_ui/
├── __init__.py       # Entry point: api_doc() and framework-specific aliases
├── core.py           # ApplicationDocument class - config handling, template rendering
├── utils.py          # Config loading (YAML/JSON), path utilities
├── handlers/         # Framework-specific route registration
│   ├── __init__.py   # Auto-discovers handlers via pkgutil
│   ├── flask.py      # Each handler implements handler(doc) and match(doc)
│   ├── tornado.py
│   └── ...
├── static/           # Swagger UI/Editor assets (CSS, JS, images)
└── templates/        # Jinja2 templates (doc.html, editor.html)
```

### Handler Pattern

Each framework handler in `swagger_ui/handlers/` must implement:

1. **`match(doc)`** - Returns `handler` function if `doc.app` is an instance of the framework's app class, otherwise `None`
2. **`handler(doc)`** - Registers routes on the app for UI, JSON spec, editor, and static files

The `api_doc()` function iterates through handlers until one matches, enabling auto-detection.

### Configuration Flow

1. `api_doc(app, ...)` creates `ApplicationDocument` with config source
2. `ApplicationDocument.match_handler()` finds the appropriate framework handler
3. Handler registers routes that serve:
   - `/api/doc` - Swagger UI HTML (rendered from Jinja2 template)
   - `/api/doc/swagger.json` - OpenAPI spec (loaded from file/URL/dict/string)
   - `/api/doc/editor` - Swagger Editor (optional)
   - `/api/doc/static/*` - Static assets

### Config Source Priority

One of these must be provided (in order of typical usage):
- `config_path` - Local YAML/JSON file
- `config_url` - Remote URL
- `config` - Python dict
- `config_spec` - JSON/YAML string
- `config_rel_url` - App provides its own endpoint

## Testing

Tests use pytest with framework-specific test clients. Each framework has its own test file (`test/{framework}_test.py`) that follows the same pattern:

```python
@pytest.mark.parametrize('mode, kwargs', parametrize_list)
def test_framework(app, mode, kwargs):
    # Test auto-detection and explicit modes
    # Verify routes: /, /swagger.json, /editor, /static/*
```

Test matrix in `test/common.py` covers: url_prefix variations, editor on/off, config_rel_url

## Adding a New Framework

1. Create `swagger_ui/handlers/{framework}.py`:
   ```python
   def handler(doc):
       # Register routes using framework's routing mechanism
       pass

   def match(doc):
       try:
           import framework
           if isinstance(doc.app, framework.Application):
               return handler
       except ImportError:
           pass
       return None
   ```

2. Add test file `test/{framework}_test.py` following existing patterns
3. Add framework to `test/requirements.txt`
4. Handler is auto-discovered via `pkgutil.iter_modules()`
