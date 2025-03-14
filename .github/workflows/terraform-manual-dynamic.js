// terraform-manual-dynamic.js
// 用于动态加载Terraform目录选项
const fs = require('fs');
const yaml = require('js-yaml');
const core = require('@actions/core');

try {
  // 配置文件路径
  const configPath = '.github/terraform-options/directories.yml';
  
  // 检查配置文件是否存在
  if (fs.existsSync(configPath)) {
    console.log(`配置文件存在: ${configPath}`);
    
    // 读取配置文件
    const configContent = fs.readFileSync(configPath, 'utf8');
    const config = yaml.load(configContent);
    
    if (config && config.target_directory) {
      const directoryConfig = config.target_directory;
      
      // 设置输出变量
      if (directoryConfig.options && Array.isArray(directoryConfig.options)) {
        // 将选项转换为字符串以便在GitHub Actions中使用
        const optionsString = JSON.stringify(directoryConfig.options);
        core.setOutput('directory_options', optionsString);
        
        // 针对GitHub Actions输出格式要求
        console.log(`::set-output name=directory_options::${optionsString}`);
        console.log(`找到 ${directoryConfig.options.length} 个目录选项`);
        console.log(`选项: ${optionsString}`);
      }
      
      if (directoryConfig.default) {
        core.setOutput('default_directory', directoryConfig.default);
        console.log(`::set-output name=default_directory::${directoryConfig.default}`);
        console.log(`默认目录: ${directoryConfig.default}`);
      }
    } else {
      console.log('配置文件格式不正确或缺少target_directory部分');
    }
  } else {
    console.log(`配置文件不存在: ${configPath}`);
    // 使用默认目录
    const defaultOptions = ['terraform/ec2'];
    const defaultOptionsString = JSON.stringify(defaultOptions);
    core.setOutput('directory_options', defaultOptionsString);
    core.setOutput('default_directory', 'terraform/ec2');
    
    // 针对GitHub Actions输出格式要求
    console.log(`::set-output name=directory_options::${defaultOptionsString}`);
    console.log(`::set-output name=default_directory::terraform/ec2`);
  }
} catch (error) {
  console.error(`发生错误: ${error.message}`);
  core.setFailed(error.message);
}
