PREFIX   ?= /usr/local
BINDIR    = $(PREFIX)/bin
DATADIR   = $(PREFIX)/share/dlog

CUBE_FILES = $(wildcard *.cube)

.PHONY: help install install-user uninstall uninstall-user

help:
	@echo "dlog — DJI D-Log 视频色彩转换工具"
	@echo ""
	@echo "  make install           安装到 $(PREFIX) (可能需要 sudo)"
	@echo "  make install-user      安装到 ~/.local (无需 sudo)"
	@echo "  make uninstall         卸载"
	@echo "  make uninstall-user    卸载用户安装"
	@echo ""
	@echo "安装前请将官方 .cube LUT 文件放到本目录"
	@echo "下载地址: https://www.dji.com/lut"

install: dlog
	@echo "安装 dlog → $(BINDIR)/dlog"
	install -d $(BINDIR)
	install -d $(DATADIR)
	install -m 755 dlog $(BINDIR)/dlog
	@echo "安装 LUT 文件 → $(DATADIR)/"
	@find . -maxdepth 1 -name '*.cube' -exec sh -c ' \
		for f; do \
			base=$$(basename "$$f"); \
			echo "  $$base"; \
			install -m 644 "$$f" "$(DATADIR)/$$base"; \
		done' _ {} +
	@echo ""
	@echo "✓ 安装完成！可直接使用: dlog"
	@echo "  LUT 目录: $(DATADIR)/"

install-user: dlog
	@$(MAKE) install PREFIX=$$HOME/.local
	@echo ""
	@if ! echo "$$PATH" | tr ':' '\n' | grep -qx "$$HOME/.local/bin"; then \
		echo "⚠ 请将 ~/.local/bin 加入 PATH:"; \
		echo "  echo 'export PATH=\"\$$HOME/.local/bin:\$$PATH\"' >> ~/.zshrc"; \
		echo "  source ~/.zshrc"; \
	fi

uninstall:
	@echo "卸载 dlog..."
	rm -f $(BINDIR)/dlog
	rm -rf $(DATADIR)
	@echo "✓ 已卸载"

uninstall-user:
	@$(MAKE) uninstall PREFIX=$$HOME/.local
