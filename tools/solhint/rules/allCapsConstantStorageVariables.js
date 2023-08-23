class AllCapsConstantStorageVariables {
  constructor(reporter, config) {
    this.ruleId = 'all-caps-constant-storage-variables';
    this.reporter = reporter;
    this.config = config;
  }

  ContractDefinition(ctx) {
    const { subNodes } = ctx;
    for (let subNode of subNodes) {
      const { type } = subNode;
      if (type === 'StateVariableDeclaration') {
        for (let variable of subNode.variables) {
          const { type, isDeclaredConst, name } = variable;
          if (type === 'VariableDeclaration' && isDeclaredConst && name.toUpperCase() !== name) {
            this.reporter.error(
              variable,
              this.ruleId,
              `Constant variable ${name} is not in all caps, it should be ${name.toUpperCase()}`,
            );
          }
        }
      }
    }
  }
}

module.exports = AllCapsConstantStorageVariables;
