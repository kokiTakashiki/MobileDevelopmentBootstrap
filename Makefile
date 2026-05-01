.PHONY: help setup setup-brew setup-nix-install setup-xcode setup-manual setup-nix verify flake-lock flake-update

# Makefile 自身の位置から各種パスを解決（clone 先のディレクトリ名に依存しない）
ROOT     := $(dir $(lastword $(MAKEFILE_LIST)))
BREWFILE := $(abspath $(ROOT)/Brewfile)
FLAKES   := $(abspath $(ROOT)/iOS) $(abspath $(ROOT)/Android) $(abspath $(ROOT)/Flutter)

help:
	@echo "新しいMacのセットアップ手順"
	@echo ""
	@echo "推奨手順: make setup を実行"
	@echo ""
	@echo "個別ターゲット:"
	@echo "  make setup-brew         - HomebrewとBrewfileの内容を導入"
	@echo "  make setup-nix-install  - 公式インストーラで Nix を導入（sudo パスワードあり）"
	@echo "  make setup-xcode        - xcodesで最新Xcodeをインストール（Apple ID認証あり）"
	@echo "  make setup-manual       - 残りの手作業項目の手順を表示"
	@echo "  make setup-nix          - Nix環境の動作確認"
	@echo "  make verify             - 全体の動作検証"
	@echo ""
	@echo "  make flake-lock         - 各 flake の flake.lock を初回生成（未コミット時）"
	@echo "  make flake-update       - 各 flake の flake.lock を最新 nixpkgs に更新"
	@echo ""

setup: setup-brew setup-nix-install setup-xcode setup-manual setup-nix verify
	@echo ""
	@echo "✓ セットアップ完了"

setup-brew:
	@echo "==> Homebrewのインストール確認"
	@which brew > /dev/null 2>&1 || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@if [ ! -L "$(HOME)/Brewfile" ] && [ -e "$(HOME)/Brewfile" ]; then \
		echo "Error: $(HOME)/Brewfile が既に存在し、シンボリックリンクではありません。手動で退避してください。" && exit 1; \
	fi
	@echo "==> $(HOME)/Brewfile → $(BREWFILE) のシンボリックリンクを作成"
	@ln -sfn "$(BREWFILE)" "$(HOME)/Brewfile"
	@echo "==> brew bundle 実行"
	brew bundle --file=$(HOME)/Brewfile
	@echo "✓ Brewfile適用完了"

setup-nix-install:
	@if command -v nix > /dev/null 2>&1; then \
		echo "==> Nix は既にインストール済み: $$(nix --version)"; \
	elif [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then \
		echo "==> Nix は既にインストール済み（PATH 未通過）"; \
		echo "    新しいシェルを開くか、以下を source してください："; \
		echo "    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"; \
	else \
		echo "==> Nix を Determinate Systems インストーラで導入"; \
		echo "    sudo パスワードが要求されます"; \
		curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm; \
		echo "✓ Nix インストール完了。新しいシェルで PATH が反映されます"; \
	fi

setup-xcode:
	@which xcodes > /dev/null 2>&1 || (echo "xcodes が入っていません。make setup-brew を先に実行してください" && exit 1)
	@echo "==> 最新Xcodeのインストール"
	@echo "    Apple ID と App-Specific Password が要求されます"
	@echo "    ダウンロードは数十分〜数時間かかります"
	xcodes install --latest
	@echo "==> 有効な Developer Directory を Xcode に切り替え（sudo パスワードが要求されます）"
	@XCODE_APP=$$(ls -td /Applications/Xcode-*.app /Applications/Xcode.app 2>/dev/null | head -1); \
	if [ -z "$$XCODE_APP" ]; then \
		echo "Error: /Applications 配下に Xcode が見つかりません" && exit 1; \
	fi; \
	echo "    select: $$XCODE_APP"; \
	sudo xcode-select -s "$$XCODE_APP/Contents/Developer"
	@echo "==> Xcodeライセンス同意（sudo パスワードが要求されます）"
	sudo xcodebuild -license accept
	@echo "✓ Xcodeセットアップ完了"

setup-manual:
	@echo ""
	@echo "==> 以下は手作業が必要です。完了したらEnterを押してください"
	@echo ""
	@echo "  [ ] 1. Apple Developer アカウントを Xcode に追加"
	@echo "         Xcode → Settings → Accounts → + でサインイン"
	@echo ""
	@echo "  [ ] 2. 証明書と Provisioning Profile をインポート"
	@echo "         Xcode → Settings → Accounts → Manage Certificates"
	@echo ""
	@echo "  [ ] 3. JetBrains Toolbox から IDE をインストール（任意）"
	@echo "         必要に応じて IntelliJ IDEA CE / AppCode 等を追加"
	@echo "         （Android Studio は cask で導入済み）"
	@echo ""
	@echo "  [ ] 4. Android Studio を起動して SDK をインストール"
	@echo "         Tools → SDK Manager → API 34, 35 をチェック"
	@echo "         Build-Tools 34.0.0, 35.0.0 をチェック"
	@echo ""
	@echo "  [ ] 5. VSCode に Dart / Flutter 拡張をインストール"
	@echo "         Extensions → 'Dart' / 'Flutter' を検索してインストール"
	@echo ""
	@read -p "完了したらEnter: " dummy

setup-nix:
	@echo "==> Nix動作確認"
	@if ! command -v nix > /dev/null 2>&1; then \
		if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then \
			echo "  Nix はインストール済みですが、現在のシェルの PATH に未反映です"; \
			echo "  新しいターミナルを開くか、以下を source してください："; \
			echo "    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"; \
		else \
			echo "Nix が入っていません。make setup-nix-install を先に実行してください" && exit 1; \
		fi; \
	fi
	@which direnv > /dev/null || (echo "direnvが入っていません" && exit 1)
	@echo "✓ Nix / direnv 確認完了"
	@echo ""
	@echo "プロジェクトディレクトリでは direnv allow を実行してください"

verify:
	@echo "==> 全体検証"
	@echo "Homebrew: $$(brew --version | head -1)"
	@echo "Nix:      $$(nix --version 2>/dev/null || ([ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && echo 'Installed (要新規シェル)') || echo 'Not installed')"
	@echo "direnv:   $$(direnv --version 2>/dev/null || echo 'Not installed')"
	@echo "xcodes:   $$(xcodes version 2>/dev/null || echo 'Not installed')"
	@echo "Xcode:    $$(xcodebuild -version 2>/dev/null | head -1 || echo 'Not configured')"
	@echo "Android:  $$([ -d $(HOME)/Library/Android/sdk ] && echo 'SDK found' || echo 'SDK not configured')"

flake-lock:
	@command -v nix > /dev/null 2>&1 || (echo "Nix が入っていません。make setup-nix-install を先に実行してください" && exit 1)
	@for d in $(FLAKES); do \
		echo "==> $$d の flake.lock を生成"; \
		(cd "$$d" && nix --extra-experimental-features 'nix-command flakes' flake lock); \
	done
	@echo "✓ flake.lock 生成完了。git add してコミットしてください"

flake-update:
	@command -v nix > /dev/null 2>&1 || (echo "Nix が入っていません。make setup-nix-install を先に実行してください" && exit 1)
	@for d in $(FLAKES); do \
		echo "==> $$d の flake.lock を更新"; \
		(cd "$$d" && nix --extra-experimental-features 'nix-command flakes' flake update); \
	done
	@echo "✓ flake.lock 更新完了"
