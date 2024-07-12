{
  lib,
  config',
  ...
}: {
  vim = lib.mkIf (!config'.enableNvfDefaultKeybinds) {
    telescope.mappings = {
      findFiles = null;
      liveGrep = null;
      buffers = null;
      helpTags = null;
      open = null;
      resume = null;

      gitCommits = null;
      gitBufferCommits = null;
      gitBranches = null;
      gitStatus = null;
      gitStash = null;

      lspDocumentSymbols = null;
      lspWorkspaceSymbols = null;
      lspReferences = lib.mkForce null;
      lspImplementations = null;
      lspDefinitions = null;
      lspTypeDefinitions = null;
      diagnostics = null;

      treesitter = null;
      findProjects = null;
    };
    git = {
      gitsigns.mappings = {
        blameLine = null;
        diffProject = null;
        diffThis = null;
        nextHunk = null;
        previewHunk = null;
        previousHunk = null;
        resetBuffer = null;
        resetHunk = null;
        stageBuffer = null;
        stageHunk = null;
        toggleBlame = null;
        toggleDeleted = null;
        undoStageHunk = null;
      };
      git-conflict.mappings = {
        both = null;
        nextConflict = null;
        none = null;
        ours = null;
        prevConflict = null;
        theirs = null;
      };
    };
    debugger.nvim-dap.mappings = {
      restart = null;
      runLast = null;
      runToCursor = null;
      stepBack = null;
      stepInto = null;
      stepOut = null;
      stepOver = null;
      terminate = null;
      toggleBreakpoint = null;
      toggleDapUI = null;
      toggleRepl = null;
    };
    lsp.trouble.mappings = {
      locList = null;
      documentDiagnostics = null;
      lspReferences = null;
      quickfix = null;
      symbols = null;
      workspaceDiagnostics = null;
    };
    binds.whichKey.register = {
      # Thanks...
      "<leader>f" = lib.mkForce "+Telescope";
      "<leader>fl" = lib.mkForce null;
      "<leader>fm" = lib.mkForce null;
      "<leader>fv" = lib.mkForce null;
      "<leader>fvc" = lib.mkForce null;
      "<leader>x" = lib.mkForce null;
      "<leader><" = "+Movement";
    };
  };
}
