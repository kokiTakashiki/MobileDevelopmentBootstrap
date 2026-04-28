.PHONY: help setup setup-brew setup-manual setup-nix verify

help:
	@echo "新しいMacのセットアップ手順"
	@echo ""
	@echo "推奨手順: make setup を実行"
	@echo ""
	@echo "個別ターゲット:"
	@echo "  make setup-brew    - HomebrewとBrewfileの内容を導入"
	@echo "  make setup-manual  - 手作業項目の手順を表示"
	@echo "  make setup-nix     - Nix環境の動作確認"
	@echo "  make verify        - 全体の動作検証"
	@echo ""

setup: setup-brew setup-manual setup-nix verify
	@echo ""
	@echo "✓ セットアップ完了"

setup-brew:
	@echo "==> Homebrewのインストール確認"
	@which brew > /dev/null 2>&1 || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@echo "==> brew bundle 実行"
	brew bundle --file=$(HOME)/Brewfile
	@echo "✓ Brewfile適用完了"

setup-manual:
	@echo ""
	@echo "==> 以下は手作業が必要です。完了したらEnterを押してください"
	@echo ""
	@echo "  [ ] 1. Apple IDでXcodeにサインイン"
	@echo "         Xcodeを起動 → Settings → Accounts → +"
	@echo ""
	@echo "  [ ] 2. Xcode Command Line Toolsの同意"
	@echo "         初回起動時にダイアログが出る"
	@echo ""
	@echo "  [ ] 3. 証明書とProvisioning Profileをインポート"
	@echo "         Xcode → Settings → Accounts → Manage Certificates"
	@echo ""
	@echo "  [ ] 4. Android Studioを起動してSDKをインストール"
	@echo "         Tools → SDK Manager → API 34, 35 をチェック"
	@echo "         Build-Tools 34.0.0, 35.0.0 をチェック"
	@echo ""
	@echo "  [ ] 5. VSCodeにDart/Flutter拡張をインストール"
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
	@echo "Xcode:    $$(xcodebuild -version 2>/dev/null | head -1 || echo 'Not configured')"
	@echo "Android:  $$([ -d $(HOME)/Library/Android/sdk ] && echo 'SDK found' || echo 'SDK not configured')"
