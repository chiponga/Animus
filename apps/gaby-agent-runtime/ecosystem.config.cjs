module.exports = {
  apps: [
    {
      name: "gaby-agent-runtime",
      script: "bun",
      args: "src/index.ts",
      cwd: __dirname,
      env: {
        NODE_ENV: "production"
      },
      max_restarts: 10,
      restart_delay: 3000
    }
  ]
};
