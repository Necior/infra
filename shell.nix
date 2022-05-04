{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    jsonnet
    kubecfg
    kubectl
  ];
  shellHook = ''
    alias k=kubectl
    source <(kubectl completion bash)
    complete -F __start_kubectl k
  '';
}

