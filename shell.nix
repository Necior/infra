{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    google-cloud-sdk
    kubecfg
    kubectl
  ];
  shellHook = "alias k=kubectl";
}

