class NoHardhatImports {
  constructor(reporter, config) {
    this.ruleId = 'no-hardhat-imports';
    this.reporter = reporter;
    this.config = config;
  }

  ImportDirective(ctx) {
    const { path } = ctx;
    if (path.startsWith('hardhat')) {
      this.reporter.error(ctx, this.ruleId, `Hardhat import ${path} not allowed`);
    }
  }
}

module.exports = NoHardhatImports;
