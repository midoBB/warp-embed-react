.PHONY: all clean

# Directories
FRONTEND_DIR = vite-project
EXECUTABLE_DIR = target/release
EXECUTABLE = $(EXECUTABLE_DIR)/warp-emebed-react

# Frontend source files (excluding dist folders)
FRONTEND_FILES := $(shell find $(FRONTEND_DIR) -type f \( -name '*.jsx' -o -name '*.js' -o -name '*.css' -o -name '*.html' \) -not -path "*/dist/*")

# Source files (excluding target folder)
SRC_FILES := $(shell find src -type f \( -name '*.rs' -o -name '*.toml' \) -not -path "*/target/*")

PACKAGE_FILE = $(FRONTEND_DIR)/package.json
FRONTEND_BUILD_MARKER = $(FRONTEND_DIR)/.build_complete

all: $(EXECUTABLE)

$(PACKAGE_FILE):
	@cd $(FRONTEND_DIR) && pnpm install
	@echo "Dependencies installed"

$(FRONTEND_BUILD_MARKER): $(PACKAGE_FILE) $(FRONTEND_FILES)
	@cd $(FRONTEND_DIR) && pnpm build
	@touch $@
	@echo "Frontend build complete"

$(EXECUTABLE): $(FRONTEND_BUILD_MARKER) $(SRC_FILES)
	cargo build --release
	@touch $@

clean:
	rm -rf $(EXECUTABLE_DIR)
	rm -rf $(FRONTEND_DIR)/dist $(FIRSTRUN_DIR)/dist
	rm -f $(FRONTEND_BUILD_MARKER)
	rm -f $(EXECUTABLE)
