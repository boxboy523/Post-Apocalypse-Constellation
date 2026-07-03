{
  description = "Godot 4 Development Environment on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        godotLauncher = pkgs.writeShellScriptBin "g" ''
          PROJ_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
          export PATH="${pkgs.jq}/bin:$PATH"

          TERM_INFO=$(hyprctl activewindow -j)
          TERM_ADDR=$(echo "$TERM_INFO" | jq -r '.address')
          ORIGIN_WS=$(echo "$TERM_INFO" | jq -r '.workspace.name')

          # 터미널 숨기기 (Special Workspace로 이동)
          hyprctl dispatch movetoworkspacesilent "special:hidden,address:$TERM_ADDR"

          # Godot 에디터 실행 (백그라운드가 아니라 포그라운드에서 실행해 종료 대기)
          godot4 -e --path "$PROJ_ROOT/godot"

          # Godot 종료 후 터미널 복구
          hyprctl dispatch movetoworkspace "$ORIGIN_WS,address:$TERM_ADDR"
          hyprctl dispatch focuswindow "address:$TERM_ADDR"
        '';

        # Godot 및 런타임에 필요한 라이브러리들
        buildInputs = with pkgs; [
          godot_4          # Godot 4 에디터

          # 빌드 도구
          pkg-config
          openssl
          jq
          llvmPackages.libclang
          clang
          fontconfig
          freetype

          godotLauncher

          # 그래픽스 및 윈도우 시스템 (Vulkan, Wayland/X11)
          vulkan-loader
          vulkan-validation-layers
          libxkbcommon
          wayland
          libx11
          libxcursor
          libxrandr
          libxi
          libglvnd
          libGL
          vulkan-headers
        ];

      in
      {
        devShells.default = pkgs.mkShell {
          inherit buildInputs;

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
          VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
          VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

          shellHook = ''
            echo "Godot + Rust DevShell Activated!"
            echo "Godot Version: $(godot4 --version)"
          '';
        };
      }
    );
}
