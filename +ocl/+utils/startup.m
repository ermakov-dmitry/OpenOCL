% Copyright 2019 Jonas Koenemann, Moritz Diehl, University of Freiburg
% Redistribution is permitted under the 3-Clause BSD License terms. Please
% ensure the above copyright notice is visible in any derived work.
%
function startup(in)
  % ocl.utils.startup(workingDirLocation)
  %
  % Startup script for OpenOCL
  % Adds required directories to the path. Sets up a folder for the results
  % of tests and a folder for autogenerated code.
  %
  % inputs:
  %   workingDirLocation - path to location where the working directory
  %                        should be created.

  ocl_dir  = fileparts(which('ocl'));

  if isempty(ocl_dir)
    ocl.utils.error('Can not find OpenOCL. Add root directory of OpenOCL to the path.')
  end

  workspaceLocation = fullfile(ocl_dir, 'Workspace');

  if nargin == 1 && ischar(in)
    workspaceLocation = in;
  elseif nargin == 1
    ocl.utils.error('Invalid argument.')
  end
  
  % create folders for tests and autogenerated code
  testDir     = fullfile(workspaceLocation,'test');
  exportDir   = fullfile(workspaceLocation,'export');
  [~,~] = mkdir(testDir);
  [~,~] = mkdir(exportDir);

  % set environment variables for directories
  setenv('OPENOCL_PATH', ocl_dir)
  setenv('OPENOCL_TEST', testDir)
  setenv('OPENOCL_EXPORT', exportDir)
  setenv('OPENOCL_WORK', workspaceLocation)

  % setup directories
  addpath(ocl_dir)
  addpath(exportDir)
  
  addpath(fullfile(ocl_dir,'doc'))
  
  if ~exist(fullfile(ocl_dir,'Lib','casadi'), 'dir')
    r = mkdir(fullfile(ocl_dir,'Lib','casadi'));
    ocl.utils.assert(r, 'Could not create directory in Lib/casadi');
    casadiFound = false;
  else
    % check if casadi is already installed
    addpath(fullfile(ocl_dir,'Lib'))
    addpath(fullfile(ocl_dir,'Lib','casadi'))
    casadiFound = checkCasadi(fullfile(ocl_dir,'Lib','casadi'));
  end

  % install casadi into Lib folder
  if ~casadiFound 
    
    if ispc && verAtLeast('matlab','9.0')
      % Windows, >=Matlab 2016a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-windows-matlabR2016a-v3.4.5.zip';
      downloadCasadi(ocl_dir, path, filename, fullfile(ocl_dir,'Lib','casadi'));
    elseif ispc && verAtLeast('matlab','8.4')
      % Windows, >=Matlab 2014b
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-windows-matlabR2014b-v3.4.5.zip';
      downloadCasadi(ocl_dir, path, filename, fullfile(ocl_dir,'Lib','casadi'));
    elseif ispc && verAtLeast('matlab','8.3')
      % Windows, >=Matlab 2014a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-windows-matlabR2014a-v3.4.5.zip';
      downloadCasadi(ocl_dir, path, filename, fullfile(ocl_dir,'Lib','casadi'));
    elseif ispc && verAtLeast('matlab','8.1')
      % Windows, >=Matlab 2013a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-windows-matlabR2013a-v3.4.5.zip';
      downloadCasadi(ocl_dir, path, filename, fullfile(ocl_dir,'Lib','casadi'));
    
    elseif isunix && ~ismac && verAtLeast('matlab','8.4')
      % Linux, >=Matlab 2014b
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-linux-matlabR2014b-v3.4.5.tar.gz';
      downloadCasadi(ocl_dir, path, filename, fullfile(ocl_dir,'Lib','casadi'));
    elseif isunix && ~ismac && verAtLeast('matlab','8.3')
      % Linux, >=Matlab 2014a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-linux-matlabR2014a-v3.4.5.tar.gz';
      downloadCasadi(ocl_dir, path, filename, fullfile(ocl_dir,'Lib','casadi'));
    
    elseif ismac && verAtLeast('matlab','8.5')
      % Mac, >=Matlab 2015a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-osx-matlabR2015a-v3.4.5.tar.gz';
      downloadCasadi(ocl_dir, path, filename, fullfile(ocl_dir,'Lib','casadi'));
    elseif ismac && verAtLeast('matlab','8.4')
      % Mac, >=Matlab 2015a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-osx-matlabR2014b-v3.4.5.tar.gz';
      downloadCasadi(ocl_dir, path, filename, fullfile(ocl_dir,'Lib','casadi'));
    elseif ismac && verAtLeast('matlab','8.3')
      % Mac, >=Matlab 2015a
      path = 'https://github.com/casadi/casadi/releases/download/3.4.5/';
      filename = 'casadi-osx-matlabR2014a-v3.4.5.tar.gz';
      downloadCasadi(ocl_dir, path, filename, fullfile(ocl_dir,'Lib','casadi'));
    else
      ocl.utils.info(['Could not set up CasADi for you system.', ...
               'You need to install CasADi yourself and add it to your path.'])
    end
    % add Lib and Lib/casadi to path
    addpath(fullfile(ocl_dir,'Lib'))
    addpath(fullfile(ocl_dir,'Lib','casadi'))
  end
  
  casadiFound = checkCasadiWorking();
  if casadiFound
    ocl.utils.info('CasADi is up and running!')
  else
    ocl.utils.error('Go to https://web.casadi.org/get/ and setup CasADi.');
  end

  ocl.utils.info('OpenOCL startup procedure finished successfully.')
  
end

function downloadCasadi(ocl_dir, path, filename, dest)

  if exist(fullfile(dest, 'CUSTOM_CASADI'), 'file') > 0
    fprintf(['You chose to your use your custom CasADi installation. If you changed \n', ...
            'your mind delete the CUSTOM_CASADI file in %s\n'], dest);
    return;
  end
  
  fprintf(2,'\nYour input is required! Please read below:\n')
  
  confirmation = [ '\n', 'Dear User, if you continue, CasADi will be downloaded from \n', ...
                   path, filename, ' \n', ...
                   'and saved to the Workspace folder. The archive will be extracted \n', ...
                   'to the Lib folder. This will take a few minutes. \n\n', ...
                   'Hit [enter] to continue! \n\n', ...
                   'Advanced users: \n', ...
                   'If you have set-up your own CasADi version and you want to use that, you \n', ...
                   'can type `n` and hit [enter]. We will then perform some basic checks if \n', ...
                   'your version is campatible. We strongly recommend you to let OpenOCL install \n', ...
                   'the required version (if you do not save the path, the CasADi version of OpenOCL \n', ...
                   'will not be on your path at startup, and not conflict with you current CasADi \n', ...
                   'installation): '];
  m = input(confirmation,'s');
  
  if strcmp(m, 'n') || strcmp(m, 'no')
    try 
      ocl.tests.variable;
      fid = fopen(fullfile(dest, 'CUSTOM_CASADI'),'w');
      fclose(fid);
      return;
    catch e
      warning(e.message)
      ocl.utils.error('You did not agree to download CasADi and your version is not compatible. Either run again or set-up a compatible CasADi version manually.');
    end
  end
  
  archive_destination = fullfile(ocl_dir, 'Workspace', filename);

  if ~exist(archive_destination, 'file')
    ocl.utils.info('Downloading...')
    websave(archive_destination, [path,filename]);
  end
  ocl.utils.info('Extracting...')
  [~,~,ending] = fileparts(archive_destination);
  if strcmp(ending, '.zip')
    unzip(archive_destination, dest)
  else
    untar(archive_destination, dest)
  end
end

function r = checkCasadi(path)

  cur_path = pwd;
  cd(path)
  
  if ~exist(fullfile(path,'+casadi','SX.m'),'file') > 0
    r = false;
  else
    try
      casadi.SX.sym('x');
      r = true;
    catch e
      cd(cur_path)
      oclInfo(e);
      casadiNotWorkingError();
    end
  end
  cd(cur_path)
end

function r = checkCasadiWorking()
  try
    casadi.SX.sym('x');
    r = true;
  catch e
    ocl.utils.warning(e.message);
    casadiNotWorkingError();
  end
end

function r = verAtLeast(software, version_number)
  r = ~verLessThan(software,version_number);
end

function casadiNotWorkingError
  ocl.utils.error(['Casadi installation not found or it does not ', ...
            'work properly. Try restarting Matlab. Remove all ', ...
            'casadi installations from your path. Run ocl.utils.clean. OpenOCL will ', ...
            'then install the correct casadi version for you.']);
end
