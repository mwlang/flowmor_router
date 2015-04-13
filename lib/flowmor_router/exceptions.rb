module FlowmorRouter
  class UnroutableRecord < RuntimeError; end
  class UnroutedRecord < RuntimeError; end
  class DuplicateRouterActors < RuntimeError; end
end