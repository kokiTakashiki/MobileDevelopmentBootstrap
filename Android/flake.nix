{
  description = "Android development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in {
      devShells.aarch64-darwin.default = pkgs.mkShell {
        packages = with pkgs; [
          jdk17
          gradle
          kotlin

          ktlint
          detekt

          fastlane
        ];

        shellHook = ''
          # Android SDKはホスト側のAndroid Studio経由で配置
          export ANDROID_HOME="$HOME/Library/Android/sdk"
          export ANDROID_SDK_ROOT="$ANDROID_HOME"
          export PATH="$ANDROID_HOME/platform-tools:$PATH"
          export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
          echo "Android dev shell ready"
        '';
      };
    };
}
