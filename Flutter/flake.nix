{
  description = "Flutter development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in {
      devShells.aarch64-darwin.default = pkgs.mkShell {
        packages = with pkgs; [
          flutter
          dart

          jdk17

          cocoapods
        ];

        shellHook = ''
          # Android: ホスト側Android Studio経由
          export ANDROID_HOME="$HOME/Library/Android/sdk"
          export ANDROID_SDK_ROOT="$ANDROID_HOME"
          export PATH="$ANDROID_HOME/platform-tools:$PATH"

          # iOS: NixのSDKを退避させてXcodeのSDKに任せる
          unset SDKROOT
          unset DEVELOPER_DIR
          export LANG=en_US.UTF-8

          echo "Flutter dev shell ready"
        '';
      };
    };
}
