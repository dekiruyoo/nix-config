# There is nothing relevant here FOR agents specifically, this file is just for running open-weight LLMs locally.
{ pkgs }:

{
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-vulkan;
    modelsPreset = {
      "gemma-4-E2B-it" = {
        hf-repo = "unsloth/gemma-4-E2B-it-GGUF";

        hf-file = "gemma-4-E2B-it-UD-Q4_K_XL.gguf";

        alias = "unsloth/gemma-4-E2B-it-GGUF";
      };
      # Future model goes here
    };
  };
} 
