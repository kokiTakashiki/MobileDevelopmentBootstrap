.PHONY: help setup setup-brew setup-xcode setup-manual setup-nix verify

# Brewfile の絶対パスを Makefile 自身の位置から解決（clone 先のディレクトリ名に依存しない）
BREWFILE := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/Brewfile)

help:
	@echo "新しいMacのセットアップ手順"
	@echo ""
	@echo "推奨手順: make setup を実行"
	@echo ""
	@echo "個別ターゲット:"
	@echo "  make setup-brew    - HomebrewとBrewfileの内容を導入"
	@echo "  make setup-xcode   - xcodesで最新Xcodeをインストール（Apple ID認証あり）"
	@echo "  make setup-manual  - 残りの手作業項目の手順を表示"
	@echo "  make setup-nix     - Nix環境の動作確認"
	@echo "  make verify        - 全体の動作検証"
	@echo ""

setup: setup-brew setup-xcode setup-manual setup-nix verify
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

setup-xcode:
	@which xcodes > /dev/null 2>&1 || (echo "xcodes が入っていません。make setup-brew を先に実行してください" && exit 1)
	@echo "==> 最新Xcodeのインストール"
	@echo "    Apple ID と App-Specific Password が要求されます"
	@echo "    ダウンロードは数十分〜数時間かかります"
	xcodes install --latest
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
	@which nix > /dev/null || (echo "Nixが入っていません。setup-brewを先に実行してください" && exit 1)
	@which direnv > /dev/null || (echo "direnvが入っていません" && exit 1)
	@echo "✓ Nix / direnv 確認完了"
	@echo ""
	@echo "プロジェクトディレクトリでは direnv allow を実行してください"

verify:
	@echo "==> 全体検証"
	@echo "Homebrew: $$(brew --version | head -1)"
	@echo "Nix:      $$(nix --version)"
	@echo "direnv:   $$(direnv --version)"
	@echo "xcodes:   $$(xcodes version 2>/dev/null || echo 'Not installed')"
	@echo "Xcode:    $$(xcodebuild -version 2>/dev/null | head -1 || echo 'Not configured')"
	@echo "Android:  $$([ -d $(HOME)/Library/Android/sdk ] && echo 'SDK found' || echo 'SDK not configured')"
