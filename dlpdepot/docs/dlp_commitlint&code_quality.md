# Project Management 

## Jobs: 

### Commit Lint 


 commitlint checks if your commit messages meet the conventional commit format.The pattern mostly looks like this: 

    -  type(scope?): subject 

 - This job will run only when there is an open merge request on branch. 

 - It uses node as base image. 

 - Using npm config set  hex as scope  registry followed by the url and authenticate using the ${GITLAB_TOKEN}.Then any npm install for a        package with that scope will request packages from that registry. 

 - Install commitlint-cli,commitlint-config-conventional using npm. 

 - Set  body.subject,footer and header length rules in the “commitlint.config.js”  file 

 - Then write a script with condition,if there is no MR diff then exit 0. 

 -  Else run the  commitlint to ensure commit title and commit description follow the commit convention. 

 
 

# CODE QUALITY 

## Jobs: 

 - flake8 

 - pylint 

 - mypy 

 These jobs will run only when the instance-level ID of the merge request  is present 

### flake8: 

  It is a tool that checks if your code complies with the PEP8 style, programming errors such as libraries or unused variables, and the     complexity of the implemented functions. flake is a popular lint wrapper for python. Under the hood, it runs three other tools and combines their results: 

    - pep8 for chekcing style 

    - pyflakes for checking syntax 

    - mccabe for checking complexity 

flake8 runs all the tools by launching the single flake8 command.Basically it checks for the spaces in the code like white spaces between or after the parenthesis or operators etc.It  gives output as error code followed by error.

     Example:        
          E231 missing whitespace after ',' 

#### Plugins:  

To provide additional functions or to handle complex situations we use plugins along with flake8.  

 

- Dlint: 

  DLint uses dynamic analysis (by analysing runtime behavior) to do the detection.It is capable of capturing violations of coding practices missed by those static analysis tools. 

- flake8-print: 

  Check for Print statements in python files. 

- flake8-bandit: 

  It is a tool designed to find common security issues in Python code 

Certain env variables are set in flake8 job template as below: 

    variables: 
      plugins: "" 
      target_dir: "" 
      exclude_files: tests 
      exclude_rules: E203, W503 

 
These values can be overridden while extending the template to get a custom behaviour. Here we need to provide plugins names to be added, directory where the flake should run, excluding any files and excluding any rules.


Install flake8 and all other plugins needed using pip install

  ``` sh 
  pip install flake8 ${plugins//, /} --index-url https://$PYPI_USERNAME:$GITLAB_PYPI_TOKEN@${CI_SERVER_HOST}/api/v4/projects/164/packages/pypi/simple 
```

In the script, check whether the $target_dir is empty or not, if empty, provide the repository name as $target_dir. Then run flake8 on the $target_dir using the below command:

 
```sh
flake8 --max-line-length=88 --exclude=${exclude_files} --ignore=${exclude_rules} ${target_dir} 
 ```

### pylint: 

  Pylint analyses your code without actually running it. It checks for errors, enforces a coding standard, looks for code smells, and can make suggestions about how the code could be refactored. 


  Certain env variables are set in pylint job template as below: 

      variables: 

        target_dir: "" 
        exclude_files: tests 
        exclude_rules: E203, W503 

These values can be overridden while extending the template to get a custom behaviour. Here we need to provide directory where the pylint should run, excluding any files and excluding any rules.


 
Before the script,setup a virtual environment and  install poetry using pip. Then iterates into each app folder and run poetry install to install all project dependency packages from pyproject.toml file of corresponding app.

In the script, check whether the $target_dir is empty or not, if empty, provide the repository name as $target_dir. Then run pylint on the $target_dir using the below command:

```sh
pylint -d ${exclude_rules} ${target_dir} --ignore=${exclude_files} 
```
 
### mypy:  

  It is a static type checker for Python which checks whether the implementation of modules are defined & all the arithmetic operations are in between the same data types.

 
Need to provide  $target_dir  value  as argument. Before the script,setup a virtual environment and  install poetry  using pip.Then run poetry install to install all project dependency packages from pyproject.toml file of corresponding app.

The target directories are given in target_dir variable as comma separated.And in the script, check whether the $target_dir is empty or not, if empty, provide the repository name as $target_dir.


Run mypy : 
```sh
  mypy ${target_dir} 
```
 

 

 

 
