# IOTA Crash Course - Makefile
#
# This Makefile provides convenient commands for the IOTA crash course examples.
# Run 'make help' to see all available commands.

.PHONY: help install-rust install-iota-cli check-dependencies audit-trail-help audit-trail-build audit-trail-publish 
.PHONY: audit-trail-create-product audit-trail-add-trail audit-trail-clean audit-trail-setup 
.PHONY: create-account list-accounts faucet balance switch-account

# Variables
EXAMPLES_DIR = examples
SCRIPTS_DIR = $(EXAMPLES_DIR)/scripts
AUDIT_TRAIL_DIR = $(EXAMPLES_DIR)/dummy-audit-trails

# Default target
help:
	@echo "🚀 IOTA Crash Course - Available Commands"
	@echo ""
	@echo "⚙️  Prerequisites and Setup:"
	@echo "  make install-rust               - Install or update Rust and Cargo"
	@echo "  make install-iota-cli          - Install IOTA CLI (requires Rust)"
	@echo "  make check-dependencies        - Check if all dependencies are installed"
	@echo ""
	@echo "👤 Account Management (Global):"
	@echo "  make create-account [ALIAS=test] - Create new IOTA account and request faucet"
	@echo "  make list-accounts              - List all accounts and show active one"
	@echo "  make faucet                     - Request tokens for current account"
	@echo "  make balance                    - Check current account balance"
	@echo "  make switch-account ALIAS=name  - Switch to specific account"
	@echo ""
	@echo "📦 Audit Trail Example:"
	@echo "  make audit-trail-help           - Show audit trail specific commands"
	@echo "  make audit-trail-build          - Build the audit trail contract"
	@echo "  make audit-trail-publish        - Publish the audit trail contract"
	@echo "  make audit-trail-create-product - Create a new product (shared object)"
	@echo "  make audit-trail-add-trail      - Add trail record (owned object)"
	@echo "  make audit-trail-clean          - Clean audit trail build artifacts"
	@echo ""
	@echo "🔧 Setup:"
	@echo "  make audit-trail-setup          - Make audit trail scripts executable"
	@echo ""
	@echo "💡 Complete setup workflow:"
	@echo "  1. make install-rust             # Install Rust/Cargo (if needed)"
	@echo "  2. make install-iota-cli         # Install IOTA CLI"
	@echo "  3. make check-dependencies       # Verify installation"
	@echo "  4. make create-account           # Create and fund account"
	@echo "  5. make audit-trail-build        # Build contract"
	@echo "  6. make audit-trail-publish      # Deploy contract"
	@echo "  7. make audit-trail-create-product # Create shared Product"
	@echo "  8. export PRODUCT_ID=<id>        # Set product ID from step 7"
	@echo "  9. make audit-trail-add-trail    # Add owned ProductEntry"

# === Prerequisites and Setup Commands ===

# Install or update Rust and Cargo
install-rust:
	@echo "🦀 Installing/Updating Rust and Cargo..."
	@if command -v rustup >/dev/null 2>&1; then \
		echo "🔄 Rust already installed, updating..."; \
		rustup update; \
	else \
		echo "📥 Installing Rust via rustup..."; \
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; \
		echo "📝 Please run: source $$HOME/.cargo/env"; \
		echo "📝 Or restart your terminal to use Rust commands"; \
	fi
	@echo "✅ Rust installation/update completed!"

# Install IOTA CLI from source
install-iota-cli:
	@echo "📦 Installing IOTA CLI..."
	@if ! command -v cargo >/dev/null 2>&1; then \
		echo "❌ Cargo not found. Please install Rust first with: make install-rust"; \
		exit 1; \
	fi
	@echo "🔧 Installing IOTA CLI v1.6.1 with tracing features..."
	@echo "⏳ This may take several minutes to compile..."
	cargo install --locked --git https://github.com/iotaledger/iota.git --tag v1.6.1 --features tracing iota
	@echo "✅ IOTA CLI installation completed!"
	@echo "💡 You can now use 'iota' commands"

# Check if all dependencies are installed
check-dependencies:
	@echo "🔍 Checking dependencies..."
	@echo ""
	@echo "Checking Rust and Cargo:"
	@if command -v rustc >/dev/null 2>&1; then \
		echo "✅ Rust: $$(rustc --version)"; \
	else \
		echo "❌ Rust not found. Run: make install-rust"; \
	fi
	@if command -v cargo >/dev/null 2>&1; then \
		echo "✅ Cargo: $$(cargo --version)"; \
	else \
		echo "❌ Cargo not found. Run: make install-rust"; \
	fi
	@echo ""
	@echo "Checking IOTA CLI:"
	@if command -v iota >/dev/null 2>&1; then \
		echo "✅ IOTA CLI: $$(iota --version)"; \
	else \
		echo "❌ IOTA CLI not found. Run: make install-iota-cli"; \
	fi
	@echo ""
	@if command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1 && command -v iota >/dev/null 2>&1; then \
		echo "🎉 All dependencies are installed and ready!"; \
		echo "💡 You can now proceed with: make create-account"; \
	else \
		echo "⚠️  Some dependencies are missing. Please install them first."; \
	fi

# === Account Management Commands (Global) ===

# Create a new account with optional alias (default: test)
create-account:
	@echo "👤 Creating new IOTA account..."
	@chmod +x $(SCRIPTS_DIR)/setup_account.sh
	@$(SCRIPTS_DIR)/setup_account.sh $(ALIAS)

# List all accounts and show active account
list-accounts:
	@echo "📋 Listing IOTA accounts..."
	iota client addresses

# Request tokens from faucet for current account
faucet:
	@echo "💧 Requesting tokens from faucet..."
	iota client faucet

# Check balance of current account
balance:
	@echo "💰 Current account balance:"
	@iota client balance

# Switch to a specific account (requires ALIAS parameter)
switch-account:
ifndef ALIAS
	@echo "❌ Error: ALIAS parameter is required"
	@echo "💡 Usage: make switch-account ALIAS=your_alias_name"
	@exit 1
endif
	@echo "🔄 Switching to account: $(ALIAS)"
	@iota client switch --address "$(ALIAS)"
	@echo "✅ Switched to: $(ALIAS)"
	@echo "💰 New balance:"
	@iota client balance

# === Audit Trail Example Commands ===

# Show audit trail specific help
audit-trail-help:
	@echo "🔧 Audit Trail Example - Detailed Commands"
	@echo ""
	@echo "📦 Build and Deploy:"
	@echo "  make audit-trail-build     - Build the Move smart contract"
	@echo "  make audit-trail-publish   - Publish contract to network"
	@echo "  make audit-trail-setup     - Make scripts executable"
	@echo ""
	@echo "🏭 Contract Operations:"
	@echo "  make audit-trail-create-product - Create new product (shared object)"
	@echo "  make audit-trail-add-trail      - Add trail record (owned object + NFT)"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  make audit-trail-clean     - Clean build artifacts"
	@echo ""
	@echo "📝 Required Environment Variables ($(AUDIT_TRAIL_DIR)/.env):"
	@echo "  AUDIT_TRAIL_PKG     - Published package ID"
	@echo "  CLOCK_ID            - System clock object ID (usually 0x6)"
	@echo "  PRODUCT_ID          - Product ID (set after creating a product)"
	@echo ""
	@echo "🎯 This example demonstrates:"
	@echo "  • Shared Objects: Product accessible by anyone"
	@echo "  • Owned Objects: ProductEntry owned by specific Product"
	@echo "  • Automatic NFT rewards for trail entries"

# Build the audit trail Move contract
audit-trail-build:
	@echo "🔨 Building audit trail Move contract..."
	@cd $(AUDIT_TRAIL_DIR) && iota move build
	@echo "✅ Build completed!"

# Publish the audit trail contract to the network
audit-trail-publish:
	@echo "📤 Publishing audit trail contract..."
	@echo "💡 After publishing, update $(AUDIT_TRAIL_DIR)/.env with the package ID"
	@cd $(AUDIT_TRAIL_DIR) && iota client publish . --gas-budget 500000000

# Make audit trail scripts executable
audit-trail-setup:
	@echo "🔧 Setting up audit trail scripts..."
	@chmod +x $(SCRIPTS_DIR)/*.sh
	@echo "✅ Scripts are now executable!"

# Create a new product (demonstrates shared objects)
audit-trail-create-product: audit-trail-setup
	@echo "🏭 Creating new product..."
	@echo "📝 This will create a shared Product object that anyone can interact with"
	@cd $(AUDIT_TRAIL_DIR) && ../scripts/create_product.sh

# Add a trail record to an existing product (demonstrates owned objects)
audit-trail-add-trail: audit-trail-setup
	@echo "📝 Adding trail record..."
	@echo "📦 This will create a ProductEntry object owned by the Product"
	@echo "🎁 An NFT reward will be minted to your address"
	@cd $(AUDIT_TRAIL_DIR) && ../scripts/add_trail_record.sh

# Clean audit trail build artifacts
audit-trail-clean:
	@echo "🧹 Cleaning audit trail build artifacts..."
	@cd $(AUDIT_TRAIL_DIR) && rm -rf build/
	@echo "✅ Clean completed!"

# Development workflow - build and publish audit trail in one step
audit-trail-deploy: audit-trail-build audit-trail-publish
	@echo "🚀 Audit trail contract deployed! Don't forget to:"
	@echo "1. Update AUDIT_TRAIL_PKG in $(AUDIT_TRAIL_DIR)/.env file"
	@echo "2. Run 'make audit-trail-create-product' to create your first product"

# === Future Examples Placeholder ===
# Add more example commands here as new examples are created
# Example structure:
# other-example-build:
# other-example-publish:
# etc.