{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    jsonnet
    kubecfg
    kubectl
    terraform_0_15
  ];
  shellHook = "alias k=kubectl";
}

