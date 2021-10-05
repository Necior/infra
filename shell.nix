{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    jsonnet
    kubecfg
    kubectl
  ];
  shellHook = "alias k=kubectl";
}

