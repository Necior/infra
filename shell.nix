{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    jsonnet
    kubecfg
    kubectl
    kind
  ];
  shellHook = "alias k=kubectl";
}

