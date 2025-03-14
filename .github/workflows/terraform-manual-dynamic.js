const fs = require('fs');
const path = require('path');
const core = require('@actions/core');

// This script reads the terraform-modules/modules.json file and outputs
// appropriate directory options for the GitHub Actions workflow.
// 
// The modules.json file contains branches and their respective Terraform modules
// in the format:
// {
//   "branch1": ["module1", "module2"],
//   "branch2": ["module1"]
// }

try {
  // Define path to modules.json
  const configPath = path.join('.github', 'terraform-modules', 'modules.json');
  
  console.log(`Looking for configuration at: ${configPath}`);
  
  let dirOptions = ['terraform/ec2']; // Default fallback option
  
  // Read and parse modules.json if it exists
  if (fs.existsSync(configPath)) {
    const configData = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    console.log('Found configuration file');
    
    // Extract all unique modules from all branches
    dirOptions = [];
    Object.entries(configData).forEach(([branch, modules]) => {
      modules.forEach(module => {
        const dirOption = `terraform/${module}`;
        if (!dirOptions.includes(dirOption)) {
          dirOptions.push(dirOption);
        }
      });
    });
    
    console.log(`Generated options: ${JSON.stringify(dirOptions)}`);
  } else {
    console.log('Configuration file not found, using default options');
  }
  
  // Set outputs for the GitHub Action
  core.setOutput('directory_options', JSON.stringify(dirOptions));
  core.setOutput('default_directory', dirOptions[0] || 'terraform/ec2');
  
} catch (error) {
  console.error(`Error processing configuration: ${error.message}`);
  // Set default outputs even in case of error to prevent workflow failure
  core.setOutput('directory_options', JSON.stringify(['terraform/ec2']));
  core.setOutput('default_directory', 'terraform/ec2');
}
