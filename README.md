# Mobile Development Bootstrap

macOS（Apple Silicon）上で iOS / Android / Flutter 開発環境を**宣言的・再現可能**に構築するためのセットアップリポジトリです。Brewfile・Makefile・Nix flake の最小構成で、新しい Mac を最短手順で復元できます。

## 機能

- **`make setup`**: 新 Mac を 1 コマンドで開発可能な状態まで持っていく起動装置
  - Homebrew のインストール（未導入時）
  - Brewfile による GUI / CLI アプリの一括導入（Android Studio / VSCode / IntelliJ / Nix / direnv / xcodes / git / gh）
  - 手作業項目（`xcodes` による Xcode インストール・証明書・Android SDK・VSCode 拡張）の対話的ガイド
  - Nix と direnv の動作確認、最後に環境のサマリ表示
- **Xcode は xcodes-cli で管理**: Mac App Store ではなく [xcodes-cli](https://github.com/XcodesOrg/xcodes) 経由で developer.apple.com から取得。複数バージョンの並存と切り替え（`xcodes select`）が可能
- **プラットフォーム別 Nix flake**: iOS / Android / Flutter の各箱で `cd` するだけで、必要な CLI ツール群が PATH に揃う
  - **iOS**: SwiftLint / SwiftFormat / xcbeautify / fastlane / cocoapods / Ruby / mise
  - **Android**: JDK 17 / Gradle / Kotlin / ktlint / detekt / fastlane
  - **Flutter**: flutter / dart / JDK 17 / cocoapods（iOS と Android 両方の shellHook を併記）
- **Xcode SDK 衝突回避**: iOS / Flutter flake で `unset SDKROOT / DEVELOPER_DIR` し、Nix の SDK と Xcode の SDK を干渉させない

## 必要な環境

- macOS 14.0（Sonoma）以降
- Apple Silicon（M1 / M2 / M3 / M4）— Intel Mac は対象外
- `/usr/bin/git`（Xcode Command Line Tools に標準同梱、初回呼び出し時にインストール案内が出る）

## セットアップ

```bash
# 1. リポジトリを ~/Developer として展開
git clone https://github.com/kokiTakashiki/MobileDevelopmentBootstrap.git ~/Developer

# 2. Brewfile をホーム直下にシンボリックリンク
ln -s ~/Developer/Setup/Brewfile ~/Brewfile

# 3. 一括セットアップ
cd ~/Developer/Setup
make setup
```

`make setup` は 4 段階で進みます：

| ステップ | 内容 | 自動 / 手動 |
|---|---|---|
| `setup-brew` | Homebrew + Brewfile 適用 | 自動 |
| `setup-manual` | xcodes による Xcode インストール / 証明書 / Android SDK / VSCode 拡張の案内 | 手動（対話停止） |
| `setup-nix` | Nix と direnv の疎通確認 | 自動 |
| `verify` | 各ツールのバージョン表示 | 自動 |

個別実行も可能（例: `make setup-brew` のみ、`make verify` のみ）。

## 使用方法

各プラットフォーム箱（`~/Developer/iOS` 等）に実プロジェクトを clone して開発します。

```bash
# 例: iOS プロジェクトを iOS 箱に clone
cd ~/Developer/iOS
git clone <iOS-project-repo> MyApp

# 初回のみ direnv 承認（親ディレクトリの .envrc を読む）
cd MyApp
direnv allow
# → "iOS dev shell ready" が表示されれば成功
# → swiftlint, fastlane などが PATH に通る

# 通常開発
swiftlint --version
open MyApp.xcodeproj
```

direnv は親ディレクトリの `.envrc` を自動的に発見します。`~/Developer/iOS/` 直下に `.envrc` を置いているため、その配下のすべてのプロジェクトで同じツールチェーンが有効になります。

## 技術スタック

- **Homebrew** (Brewfile) — マシン単位の GUI / CLI アプリ管理
- **[xcodes-cli](https://github.com/XcodesOrg/xcodes)** — Xcode 複数バージョンの CLI 管理（developer.apple.com から直接取得、`xcodes select` で切替）
- **Nix (flake)** — プロジェクト単位の CLI ツールチェーン管理（`aarch64-darwin`、nixpkgs unstable）
- **direnv** — プロジェクトディレクトリ進入時の自動環境切り替え
- **GNU Make** — 起動装置 / 手作業案内の統合

## プロジェクト構造

```
~/Developer/                  # このリポジトリのルート
├── README.md
├── .gitignore                # secrets / build成果物 / プロジェクトソースを除外
├── Setup/
│   ├── Brewfile              # マシン単位の GUI / CLI アプリ宣言
│   └── Makefile              # 起動装置（自動 + 手動指示）
├── iOS/
│   ├── flake.nix             # iOS 用 Nix 環境（SDKROOT unset 入り）
│   └── .envrc                # direnv: use flake
├── Android/
│   ├── flake.nix             # Android 用 Nix 環境（androidenv 不使用）
│   └── .envrc
└── Flutter/
    ├── flake.nix             # Flutter 用 Nix 環境（iOS + Android 統合）
    └── .envrc
```

`iOS/` `Android/` `Flutter/` 配下にプロジェクトリポジトリを clone する想定で、サブディレクトリは `.gitignore` で除外されています（このリポジトリ自体には flake.nix と .envrc のみ含まれる）。

## 設計

### レイヤ図

上層ほどプロジェクト単位で個別化され、下層ほどマシン全体で共有されます。各層は HTML テーブル 1 つで表現し、すべて横幅 100% に揃えています。Makefile は L3〜L5 を横断する**起動装置**として機能しますが、図には含めず直後の表で説明します。

<table width="100%">
  <tr><td align="center" colspan="4">🟪 <b>L1 ／ プロジェクトソースコード（個別リポジトリ）</b></td></tr>
  <tr><td align="center" colspan="4">iOS / Android / Flutter の各プロジェクトリポジトリ</td></tr>
</table>

<table width="100%">
  <tr><td align="center" colspan="3">🟩 <b>L2 ／ プロジェクト固有ツール群（プロジェクト箱単位）</b></td></tr>
  <tr>
    <td align="center" width="33%">
      <b>iOS 用</b><br>
      swiftlint / swiftformat<br>
      xcbeautify / fastlane<br>
      cocoapods / ruby / mise
    </td>
    <td align="center" width="33%">
      <b>Android 用</b><br>
      JDK 17 / Gradle / Kotlin<br>
      ktlint / detekt / fastlane
    </td>
    <td align="center" width="34%">
      <b>Flutter 用</b><br>
      flutter / dart<br>
      JDK 17 / cocoapods
    </td>
  </tr>
</table>

<table width="100%">
  <tr><td align="center">🟦 <b>L3 ／ Nix flake + direnv（プロジェクト箱単位）</b></td></tr>
  <tr><td align="center">flake.nix と .envrc ／ cd で自動切替</td></tr>
</table>

<table width="100%">
  <tr><td align="center" colspan="3">🟧 <b>L4 ／ Brewfile（マシン単位） ─ brew bundle で適用</b></td></tr>
  <tr>
    <td align="center" width="33%">Android Studio<br>(cask)</td>
    <td align="center" width="33%">VSCode<br>IntelliJ CE<br>(cask)</td>
    <td align="center" width="34%">Nix / direnv<br>git / gh<br>xcodes</td>
  </tr>
</table>

<table width="100%">
  <tr><td align="center" colspan="4">🟥 <b>L5 ／ Brewfile 管轄外（手作業必須） ─ Makefile が手順を表示</b></td></tr>
  <tr>
    <td align="center" width="25%">Xcode インストール<br>(xcodes / Apple ID)</td>
    <td align="center" width="25%">証明書 /<br>Provisioning Profile</td>
    <td align="center" width="25%">Android SDK<br>(GUI 設定)</td>
    <td align="center" width="25%">VSCode 拡張</td>
  </tr>
</table>

<table width="100%">
  <tr><td align="center">⬜ <b>L6 ／ OS ／ Hardware</b></td></tr>
  <tr><td align="center">macOS + Apple Silicon</td></tr>
</table>

### Makefile の役割（層を横断する起動装置）

Makefile はレイヤ図には現れませんが、L3〜L5 を以下のように制御します。

| ターゲット | 対象層 | 性質 |
|---|---|---|
| `make setup-brew` | L4（Brewfile） | 自動：`brew bundle` で一括適用 |
| `make setup-manual` | L5（手作業層） | 指示：チェックリスト表示で対話停止 |
| `make setup-nix` | L3（Nix flake） | 確認：`nix` / `direnv` の疎通検査 |
| `make setup` | L3 + L4 + L5 | 上記 3 つを順序付きで実行 |
| `make verify` | 全層 | 各ツールのバージョンを表示 |

### 設計のポイント

- **再現性のグラデーション**: Nix flake 層は hash レベルで 100% 再現、Brewfile 層は概ね 95%（バージョンに揺れあり）、手作業層は 0%。完全自動化は構造的に不可能と認め、Makefile が**手作業の島を明示する**。
- **Xcode との分業**: iOS と Flutter の flake.nix では `unset SDKROOT / DEVELOPER_DIR` を必ず入れる。これがないと Nix が提供する SDK と Xcode の SDK が衝突し、`UIKit/UIKit.h not found` などのビルドエラーが発生する。
- **Android SDK は手動管理**: Apple Silicon では Nix の `androidenv` が非対応のため、Android Studio 経由で `~/Library/Android/sdk` に配置する前提。flake.nix からはパス参照のみ。
- **Xcode は xcodes-cli 経由**: Apple EULA 上 Nix での再配布が不可能。Brewfile では `xcodes` のみ導入し、`xcodes install` で developer.apple.com から取得。複数バージョンの並存・切替（`xcodes select`）に対応。

### 4 ファイルの役割

| ファイル | 性質 | 管理対象 | スコープ |
|---|---|---|---|
| `flake.nix` | データ層 | CLI ツールチェーン | プロジェクト箱単位 |
| `.envrc` | データ層 | direnv 起動設定 | プロジェクト箱単位 |
| `Brewfile` | データ層 | GUI アプリとシステム CLI | マシン単位 |
| `Makefile` | 制御層 | 起動順序・人間への指示 | マシン単位 |

## トラブルシューティング

### `direnv: error .envrc is blocked. Run direnv allow.`

各プラットフォーム箱で初回のみ `direnv allow` を実行してください。

```bash
cd ~/Developer/iOS && direnv allow
cd ~/Developer/Android && direnv allow
cd ~/Developer/Flutter && direnv allow
```

### iOS ビルドで `UIKit/UIKit.h not found` 等の SDK エラー

flake.nix の shellHook に `unset SDKROOT` `unset DEVELOPER_DIR` が入っているか確認してください。Nix が提供する SDK と Xcode の SDK が衝突しています。

### `androidenv` を flake に追加するとビルドが失敗する

Apple Silicon では `androidenv.composeAndroidPackages` が非対応です（[nixpkgs#303968](https://github.com/NixOS/nixpkgs/issues/303968)）。Android SDK は Android Studio の SDK Manager 経由で `~/Library/Android/sdk` に配置してください。

### `nix develop` の初回が遅い

flake で指定したパッケージをすべてビルド / ダウンロードするため、初回のみ数分〜十数分かかります。2 回目以降はキャッシュにより高速。短縮したい場合は [Cachix](https://www.cachix.org/) の導入を検討してください。

### `make setup` で `brew bundle` が `~/Brewfile` を見つけられない

`ln -s ~/Developer/Setup/Brewfile ~/Brewfile` のシンボリックリンクが必要です。Makefile は `$HOME/Brewfile` を参照しています。

## 既知の制約

- **Android SDK の再現性が低い**: GUI 設定のため、別 Mac で完全に同じ状態にするのが難しい。将来的に `sdkmanager` CLI でのスクリプト化を検討。
- **Intel Mac 非対応**: flake は `aarch64-darwin` 固定。Intel Mac で使う場合は `x86_64-darwin` への置き換えが必要。

## ライセンス

[MIT License](./LICENSE)

## 謝辞

- [Nix / Nixpkgs](https://nixos.org/) — 宣言的なツールチェーン管理の基盤
- [Homebrew](https://brew.sh/) — macOS の de facto パッケージマネージャ
- [direnv](https://direnv.net/) — ディレクトリスコープの環境変数自動切り替え
- [Ghostty](https://github.com/ghostty-org/ghostty) — iOS Nix flake における `unset SDKROOT` の設計を参考
