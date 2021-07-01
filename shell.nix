{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    google-cloud-sdk
    jsonnet
    kubecfg
    kubectl
  ];
  shellHook = "alias k=kubectl";
}

