const { exec } = require('child_process');

module.exports = {
  name: 'grep',
  description: 'Run grep and return the output',
  async run({ command }) {
    return new Promise((resolve, reject) => {
      exec(command, (err, stdout, stderr) => {
        if (err) return reject(stderr);
        resolve(stdout.trim() || 'No results');
      });
    });
  }
};