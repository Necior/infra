{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    jsonnet
    k9s
    kubecfg
    kubectl
  ];
  shellHook = ''
    alias k=kubectl
    alias k9s='k9s --readonly'
    source <(kubectl completion bash)
    complete -F __start_kubectl k
  '';
}

