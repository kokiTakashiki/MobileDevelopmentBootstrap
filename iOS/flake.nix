{
  description = "iOS development environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in {
      devShells.aarch64-darwin.default = pkgs.mkShell {
        packages = with pkgs; [
          swiftlint
          swiftformat
          xcbeautify

          fastlane
          cocoapods

          ruby_3_3
          bundler

          mise
        ];

        shellHook = ''
          # XcodeのSDKを優先（NixのSDKと衝突防止）
          unset SDKROOT
          unset DEVELOPER_DIR
          export LANG=en_US.UTF-8
          echo "iOS dev shell ready"
        '';
      };
    };
}
