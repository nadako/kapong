var project = new Project('New Project');
project.windowOptions.width = 500;
project.windowOptions.height = 500;
project.addAssets('Assets/**');
project.addSources('Sources');
return project;
