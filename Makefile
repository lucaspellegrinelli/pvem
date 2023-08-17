INSTALL_PATH ?= $(HOME)/.pvem

install:
	@read -p "Enter installation path [$(INSTALL_PATH)]: " user_path; \
	if [ -n "$$user_path" ]; then \
		INSTALL_PATH=$$user_path; \
	fi; \
	mkdir -p $(INSTALL_PATH); \
	cp pvem.sh $(INSTALL_PATH)/pvem.sh; \
	echo "pvem.sh has been installed to $(INSTALL_PATH)"; \
	echo "Please add the following line to your .bashrc or .zshrc:"; \
	echo "source $(INSTALL_PATH)/pvem.sh"
