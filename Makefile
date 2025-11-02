# Define the name of the virtual environment directory
# VENV_DIR := .venv
# PYTHON := $(VENV_DIR)/bin/python
# RUFF := $(VENV_DIR)/bin/ruff

# .PHONY is used to prevent make from conflicting with files of the same name.
.PHONY: all venv install format lint check run clean

# Default command if 'make' is run without arguments
all: install check

# -----------------
# Setup Commands
# -----------------

# 2. Install dependencies from requirements.txt
install:
	@echo "Installing dependencies..."
	pip install --upgrade pip && \
		pip install -r requirements.txt

# -----------------
# Tooling Commands (using Ruff, as it's in your requirements.txt)
# -----------------

# 3. Format the code using Ruff (re-writes files)
format:
	@echo "Formatting code with Ruff..."
	ruff format .

# 4. Lint the code for errors and style violations
lint:
	@echo "Linting code with Ruff..."
	ruff check .

test:
	@echo "Testing code with Pytest"
	pytest --nbval adaptive_yield_triggers.ipynb

# 5. Run both lint and format (good for pre-commit checks)
check: lint format
	@echo "Code checks complete."

# -----------------
# Run Command
# -----------------

# 6. Command to run the main application logic
run: 
# 	install
# 	@echo "Running application..."
# 	$(PYTHON) your_main_script.py

# -----------------
# Clean Commands
# -----------------

# 7. Remove all generated files
clean:
# 	@echo "Cleaning up..."
# 	find . -type f -name "*.pyc" -delete
# 	find . -type d -name "__pycache__" -exec rm -rf {} +
# 	rm -rf $(VENV_DIR)
# 	@echo "Cleanup complete."