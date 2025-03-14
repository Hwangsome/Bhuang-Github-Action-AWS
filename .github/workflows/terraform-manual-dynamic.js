const fs = require('fs');
const path = require('path');
const core = require('@actions/core');

try {
  // 打印当前工作目录以便调试
  console.log(`Current working directory: ${process.cwd()}`);
  
  // 尝试多种可能的配置路径
  const possiblePaths = [
    path.join('.github', 'terraform-modules', 'modules.json'),
    path.join(process.cwd(), '.github', 'terraform-modules', 'modules.json'),
    path.join('..', '.github', 'terraform-modules', 'modules.json')
  ];
  
  let configPath = null;
  let configData = null;
  
  // 尝试每一个可能的路径
  for (const p of possiblePaths) {
    console.log(`Checking for configuration at: ${p}`);
    if (fs.existsSync(p)) {
      configPath = p;
      console.log(`Found configuration at: ${configPath}`);
      try {
        configData = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        console.log('Successfully parsed configuration file');
        break;
      } catch (parseError) {
        console.log(`Error parsing configuration at ${p}: ${parseError.message}`);
      }
    }
  }
  
  // 如果找到并解析了配置文件，使用它
  let dirOptions = ['terraform/ec2']; // 默认选项
  
  if (configData) {
    console.log('Using configuration from file');
    
    // 提取所有分支中的所有唯一模块
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
    console.log('Configuration file not found or invalid, using default options');
  }
  
  // 输出给 GitHub Action
  core.setOutput('directory_options', JSON.stringify(dirOptions));
  core.setOutput('default_directory', dirOptions[0] || 'terraform/ec2');
  
} catch (error) {
  console.error(`Error processing configuration: ${error.message}`);
  // 即使发生错误，也设置默认输出，防止工作流失败
  core.setOutput('directory_options', JSON.stringify(['terraform/ec2']));
  core.setOutput('default_directory', 'terraform/ec2');
}
