{ pkgs, ... }: {
  channel = "stable-23.11";
  packages = [
    pkgs.jdk17
    pkgs.flutter
    pkgs.dart
    pkgs.cmake
    pkgs.ninja
  ];
  idx = {
    extensions = [ "Dart-Code.flutter" "Dart-Code.dart" ];
    previews = {
      enable = true;
      previews = {
        web = {
          command = [ "flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT" ];
          manager = "flutter";
        };
        android = {
          manager = "flutter";
        };
      };
    };
  };
}