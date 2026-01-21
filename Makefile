format:
	@uv pip install --no-cache-dir ruff
	@ruff format .
	@ruff check --fix .

format-check:
	@ruff format --check .
	@ruff check .

whl:
	@rm -rf ./dist/* ./build/*
	@uv pip install --no-cache-dir build
	@python3 -m build --wheel

sdist:
	@rm -rf ./dist/*
	@uv pip install --no-cache-dir build
	@python3 -m build --sdist

build:
	@rm -rf ./dist/* ./build/*
	@uv pip install --no-cache-dir build
	@python3 -m build

pytest:
	@uv pip install --no-cache-dir -r test/requirements.txt
	@pytest -s test/

install: whl
	@uv pip uninstall swagger-ui-py > /dev/null 2>/dev/null || true
	@uv pip install --no-cache-dir -r test/requirements.txt
	@uv pip install --no-cache-dir dist/swagger_ui_python-*.whl

upload: build
	@uv pip install --no-cache-dir twine
	@twine upload dist/*

version:
	@uv pip install --no-cache-dir setuptools-scm
	@python3 -m setuptools_scm
