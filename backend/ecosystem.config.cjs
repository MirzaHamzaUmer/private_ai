module.exports = {
  apps: [
    {
      name: 'Private AI App - Backend',
      script: './start.sh',
      interpreter: '/bin/bash', // Runs the shell script
      watch: true, // Optional: to restart on file changes
    },
  ],
};
