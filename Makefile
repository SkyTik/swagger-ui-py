format:
	@python3 -m pip install --disable-pip-version-check --no-cache-dir autopep8 isort flake8
	@autopep8 --recursive --max-line-length 100 --in-place --ignore-local-config .
	@isort --line-width=100 --force-single-line-imports .

format-check:
	@python3 -m pip install --disable-pip-version-check --no-cache-dir autopep8 isort flake8
	@autopep8 --recursive --max-line-length 100 --diff --ignore-local-config .
	@isort --line-width=100 --force-single-line-imports --check .

whl:
	@rm -rf ./dist/* ./build/*
	@python3 -m pip install --disable-pip-version-check --no-cache-dir build
	@python3 -m build --wheel

sdist:
	@rm -rf ./dist/*
	@python3 -m pip install --disable-pip-version-check --no-cache-dir build
	@python3 -m build --sdist

build:
	@rm -rf ./dist/* ./build/*
	@python3 -m pip install --disable-pip-version-check --no-cache-dir build
	@python3 -m build

pytest:
	@python3 -m pip install --disable-pip-version-check --no-cache-dir -r test/requirements.txt
	@pytest -s test/

install: whl
	@python3 -m pip uninstall -y swagger-ui-py > /dev/null 2>/dev/null || true
	@python3 -m pip install --disable-pip-version-check --no-cache-dir -r test/requirements.txt
	@python3 -m pip install --disable-pip-version-check --no-cache-dir dist/swagger_ui_py-*.whl

upload: build
	@python3 -m pip install --disable-pip-version-check --no-cache-dir twine
	@twine upload dist/*

version:
	@python3 -m pip install --disable-pip-version-check --no-cache-dir setuptools-scm
	@python3 -m setuptools_scm
