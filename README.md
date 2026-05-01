# Mobile Development Bootstrap

macOS（Apple Silicon）で iOS / Android / Flutter の開発環境を**宣言的・再現可能**に構築します。Brewfile・Makefile・Nix flake の最小構成で、新しい Mac を最短手順で復元できます。

## 機能

- **`make setup`**: 新しい Mac を 1 コマンドで開発可能にする起動スクリプト
  - Homebrew のインストール（未導入時）
  - Brewfile で GUI / CLI アプリを一括導入（Android Studio / JetBrains Toolbox / VSCode / direnv / xcodes / git / gh / checkmake）
  - Determinate Systems 公式インストーラで Nix を導入（Homebrew formula は 2024 年に削除）
  - `xcodes install --latest` で最新 Xcode を取得し、ライセンス同意（Apple ID / sudo 認証は対話）
  - 手作業項目（証明書・IntelliJ 等・Android SDK・VSCode 拡張）の対話ガイド
  - Nix / direnv の動作確認と環境サマリの表示
- **Xcode は xcodes-cli で管理**: [xcodes-cli](https://github.com/XcodesOrg/xcodes) で developer.apple.com から取得。複数バージョンを並存させ `xcodes select` で切り替え可能
- **プラットフォーム別 Nix flake**: iOS / Android / Flutter の各ディレクトリへ `cd` するだけで、必要な CLI ツールが PATH に通る
  - **iOS**: SwiftLint / SwiftFormat / xcbeautify / fastlane
  - **Android**: JDK 17 / Gradle / Kotlin / ktlint / detekt / fastlane
  - **Flutter**: flutter / dart / JDK 17 / cocoapods（shellHook で iOS の SDK unset と Android SDK パスを併設）
- **Xcode SDK 衝突回避**: iOS / Flutter flake で `SDKROOT` / `DEVELOPER_DIR` を unset し、Nix と Xcode の SDK 干渉を防ぐ

## 必要な環境

- macOS 14.0（Sonoma）以降
- Apple Silicon（M1 / M2 / M3 / M4）— Intel Mac は対象外
- `/usr/bin/git`（Xcode Command Line Tools に同梱。初回呼び出し時に案内が出る）

## セットアップ

```bash
# 1. リポジトリを任意のディレクトリに clone（例: ~/MobileDeveloper / ~/Developer / ~/dev）
git clone https://github.com/kokiTakashiki/MobileDevelopmentBootstrap.git <任意のディレクトリのパス>

# 2. 一括セットアップ
cd <任意のディレクトリのパス>
make setup
```

`~/Brewfile` のシンボリックリンクは `setup-brew` が自動作成します。Makefile は自身の位置から Brewfile の絶対パスを解決するため、clone 先のディレクトリ名に依存しません。

`make setup` は 6 段階で進みます：

| ステップ | 内容 | 自動 / 手動 |
|---|---|---|
| `setup-brew` | Homebrew + Brewfile 適用 | 自動 |
| `setup-nix-install` | Determinate Systems 公式インストーラで Nix を導入 | 半自動（sudo 認証あり） |
| `setup-xcode` | `xcodes install --latest` で最新 Xcode を取得しライセンス同意 | 半自動（Apple ID / sudo 認証あり） |
| `setup-manual` | 証明書 / IntelliJ 等（任意）/ Android SDK / VSCode 拡張の案内 | 手動（対話停止） |
| `setup-nix` | Nix と direnv の疎通確認 | 自動 |
| `verify` | 各ツールのバージョン表示 | 自動 |

個別実行も可能です（例: `make setup-xcode`、`make verify`）。

`flake.lock` を回したい場合は `make flake-update`（最新 nixpkgs に追従）／ 初回生成は `make flake-lock`。生成された `flake.lock` は **必ずコミット** してください — これが無いと再現性は保証されません。

## Makefile の品質維持

このリポジトリの **要は `Makefile`** なので、記述揺らぎを抑える仕組みを 2 段で入れています：

- **`.editorconfig`**: 行末スペース / 改行 / 文字コード / `Makefile` の TAB インデントを宣言。エディタが対応していれば編集時点で揃います。
- **`make lint`**: [checkmake](https://github.com/checkmake/checkmake) で `Makefile` を静的検査（`.PHONY` 漏れ・行長など）。Brewfile に同梱しているので `make setup-brew` 後に利用可能。

PR 作成時は GitHub Actions（`.github/workflows/lint.yml`）で `make lint` が走り、警告があれば [Danger](https://danger.systems/js/) が PR にコメントを残します。**警告はブロッカー扱いではなく**、別途修正する運用です。

## 使用方法

各プラットフォームディレクトリ（`<repo>/iOS` 等）に実プロジェクトを clone して開発します。以下の例の `~/Developer/` は任意のパスに置き換えてください。

```bash
# 例: iOS プロジェクトを iOS/ 配下に clone
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

direnv は親ディレクトリの `.envrc` を自動探索します。`~/Developer/iOS/` 直下に `.envrc` を置けば、配下の全プロジェクトで同じツールチェーンが有効になります。

## 技術スタック

- **Homebrew** (Brewfile) — GUI / CLI アプリのマシン単位管理
- **[Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)** — Nix 本体のインストール（Homebrew formula は削除済み）
- **[xcodes-cli](https://github.com/XcodesOrg/xcodes)** — Xcode 複数バージョンの CLI 管理。`xcodes select` で切替
- **Nix (flake)** — プロジェクト単位の CLI ツールチェーン管理（`aarch64-darwin`、nixpkgs unstable）
- **direnv** — ディレクトリ進入時の環境切り替え
- **GNU Make** — 起動と手作業案内の統合

## プロジェクト構造

```
<お好きなパス>/               # このリポジトリのルート（例: ~/Developer / ~/MobileDeveloper）
├── README.md
├── LICENSE
├── .gitignore                # secrets / build成果物 / プロジェクトソースを除外
├── .editorconfig             # 行末・インデントの揺らぎ防止
├── .github/workflows/lint.yml # PR で make lint を実行し Danger でコメント
├── checkmake.ini             # checkmake のルール調整
├── dangerfile.js             # checkmake の出力を PR コメントに変換
├── Brewfile                  # マシン単位の GUI / CLI アプリ宣言
├── Makefile                  # 起動装置（自動 + 手動指示）
├── iOS/
│   ├── flake.nix             # iOS 用 Nix 環境（SDKROOT unset 入り）
│   ├── flake.lock            # nixpkgs リビジョンの固定（要コミット）
│   └── .envrc                # direnv: use flake
├── Android/
│   ├── flake.nix             # Android 用 Nix 環境（androidenv 不使用）
│   ├── flake.lock
│   └── .envrc
└── Flutter/
    ├── flake.nix             # Flutter 用 Nix 環境（iOS + Android 統合）
    ├── flake.lock
    └── .envrc
```

`iOS/` `Android/` `Flutter/` 配下にプロジェクトを clone する想定です。サブディレクトリは `.gitignore` で除外しており、このリポジトリには flake.nix と .envrc のみが含まれます。

## 設計

### レイヤ図

上層ほどプロジェクト単位、下層ほどマシン単位で共有されます。Makefile は L3〜L5 を横断する**起動装置**として機能します。図には含めず、直後の表で役割を示します。

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
      xcbeautify / fastlane
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
    <td align="center" width="33%">JetBrains Toolbox<br>VSCode<br>(cask)</td>
    <td align="center" width="34%">direnv / git / gh<br>xcodes<br>(Nix は別インストーラ)</td>
  </tr>
</table>

<table width="100%">
  <tr><td align="center" colspan="5">🟥 <b>L5 ／ Brewfile 管轄外（手作業必須） ─ Makefile が手順を表示</b></td></tr>
  <tr>
    <td align="center" width="20%">Xcode インストール<br>(xcodes / Apple ID)</td>
    <td align="center" width="20%">証明書 /<br>Provisioning Profile</td>
    <td align="center" width="20%">IntelliJ 等<br>(Toolbox 経由 / 任意)</td>
    <td align="center" width="20%">Android SDK<br>(GUI 設定)</td>
    <td align="center" width="20%">VSCode 拡張</td>
  </tr>
</table>

<table width="100%">
  <tr><td align="center">⬜ <b>L6 ／ OS ／ Hardware</b></td></tr>
  <tr><td align="center">macOS + Apple Silicon</td></tr>
</table>

### Makefile の役割（層を横断する起動装置）

Makefile はレイヤ図に含まれませんが、L3〜L5 を以下のように制御します。

| ターゲット | 対象層 | 性質 |
|---|---|---|
| `make setup-brew` | L4（Brewfile） | 自動：`brew bundle` で一括適用 |
| `make setup-nix-install` | L4（Nix 本体） | 半自動：Determinate Systems インストーラ実行（sudo 認証あり） |
| `make setup-xcode` | L4 / L5 跨り | 半自動：`xcodes install --latest` ＋ `xcodebuild -license accept`（Apple ID / sudo 認証あり） |
| `make setup-manual` | L5（手作業層） | 指示：チェックリスト表示で対話停止 |
| `make setup-nix` | L3（Nix flake） | 確認：`nix` / `direnv` の疎通検査 |
| `make setup` | L3 + L4 + L5 | 上記 5 つを順序付きで実行 |
| `make verify` | 全層 | 各ツールのバージョンを表示 |

### 設計のポイント

- **再現性のグラデーション**: Nix flake 層は `flake.lock` をコミットすれば hash レベルで 100% 再現（ロック未コミット時は `nixos-unstable` の都度参照になり保証は無い）。Brewfile 層は概ね 95%（バージョンに揺れあり）。手作業層は 0%。完全自動化は構造的に不可能と認め、Makefile が**手作業の範囲を明示**する。
- **Xcode との分業**: iOS / Flutter の flake.nix では `SDKROOT` と `DEVELOPER_DIR` を必ず unset する。これがないと Nix と Xcode の SDK が衝突し、`UIKit/UIKit.h not found` 等のビルドエラーが出る。
- **Android SDK は手動管理**: Apple Silicon では Nix の `androidenv` が非対応。Android Studio 経由で `~/Library/Android/sdk` に配置し、flake.nix はパス参照のみとする。
- **Xcode は xcodes-cli 経由**: Apple EULA により Nix での再配布は不可。Brewfile で `xcodes` のみ導入し、`xcodes install` で取得。`xcodes select` で複数バージョンの切替に対応。

### 4 ファイルの役割

| ファイル | 性質 | 管理対象 | スコープ |
|---|---|---|---|
| `flake.nix` | データ層 | CLI ツールチェーン | プロジェクト箱単位 |
| `.envrc` | データ層 | direnv 起動設定 | プロジェクト箱単位 |
| `Brewfile` | データ層 | GUI アプリとシステム CLI | マシン単位 |
| `Makefile` | 制御層 | 起動順序・人間への指示 | マシン単位 |

## トラブルシューティング

### `direnv: error .envrc is blocked. Run direnv allow.`

各プラットフォームディレクトリで初回のみ `direnv allow` を実行してください。

```bash
cd ~/Developer/iOS && direnv allow
cd ~/Developer/Android && direnv allow
cd ~/Developer/Flutter && direnv allow
```

### iOS ビルドで `UIKit/UIKit.h not found` 等の SDK エラー

flake.nix の shellHook に `unset SDKROOT` と `unset DEVELOPER_DIR` があるか確認してください。Nix と Xcode の SDK が衝突しています。

### `androidenv` を flake に追加するとビルドが失敗する

Apple Silicon では `androidenv.composeAndroidPackages` が非対応です（[nixpkgs#303968](https://github.com/NixOS/nixpkgs/issues/303968)）。Android SDK は Android Studio の SDK Manager 経由で `~/Library/Android/sdk` に配置してください。

### `nix develop` の初回が遅い

flake のパッケージを全てダウンロード / ビルドするため、初回は数分〜十数分かかります。2 回目以降はキャッシュで高速になります。短縮したい場合は [Cachix](https://www.cachix.org/) の導入を検討してください。

### `make setup-brew` で `~/Brewfile` の作成に失敗する

`~/Brewfile` が実体ファイルとして既に存在する場合、`setup-brew` は安全のため中止します。手動で退避してから再実行してください：

```bash
mv ~/Brewfile ~/Brewfile.bak
make setup-brew
```

## 既知の制約

- **Android SDK の再現性が低い**: GUI 設定のため、別 Mac で同じ状態を作るのが難しい。将来的に `sdkmanager` CLI でのスクリプト化を検討。
- **Intel Mac 非対応**: flake は `aarch64-darwin` 固定。Intel Mac で使う場合は `x86_64-darwin` への置き換えが必要。

## ライセンス

[MIT License](./LICENSE)

## 謝辞

- [Nix / Nixpkgs](https://nixos.org/) — 宣言的なツールチェーン管理の基盤
- [Homebrew](https://brew.sh/) — macOS の標準的なパッケージマネージャ
- [direnv](https://direnv.net/) — ディレクトリ単位の環境変数切り替え
- [Ghostty](https://github.com/ghostty-org/ghostty) — iOS flake の `unset SDKROOT` 設計を参考
