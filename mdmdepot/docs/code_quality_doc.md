# Code Quality Process Documentation 
## Jobs

### flake8 

flake8 is used to check the style and quality of the python code. 

Following steps are performed in this job: 
* Disable caching for this job 
* Uses [needs](https://docs.gitlab.com/ee/ci/yaml/#needs) directive to invoke this job immediately after Prerequisite Check and Commit Lint jobs finish running successfully  
* Install flake8, dlint and flake8-bandit packages 
    * flake8 - used to check the style and quality of python code. 
    * dlint - used to ensure that python code is secure 
    * flake8-bandit – used to provide automated security checks to ensure that secure python code is written 
* Uses flake8 to check the style and quality of the entire mdm project repo 
Following options are used: 
    * --max-line-length: To set maximum allowed line length 
    * --ignore: To ignore the following errors 
        * E203 - Colons should not have any space before them. 
        * W503 - Line break occurred before a binary operator  
        * S101 - Use of assert detected.  

This job will be executed only when there is an open merge request on the branch


### mypy 

mypy is a static type checker that has a powerful type system with features such as type inference, gradual typing, generics and union types 
 
Following steps are performed in this job: 
* Use this package to type-check the statically typed parts of mdm repo 
* The cache policy specified is pull which only downloads the cache when the job starts, but any changes done in that job are not uploaded when the job finishes 

This job will be executed only when there is an open merge request on the branch


### pylint 
Pylint is a static code analyzer tool that checks for errors, enforces a coding standard, looks for code smells, and also make suggestions about how the code could be refactored 

Following steps are performed in this job: 
* Use pylint to analyze the code of the mdm directory  
Following options are used: 
    * -d: To disable the following errors  
        * C0411 - Used when PEP8 import order is not respected (standard imports first, then third-party libraries, then local imports) 
        * W0511 - Used when a warning note as FIXME or XXX is detected 
        * C0209 - Used when a string that is being formatted with format() or % which could potentially be a f-string is detected.  
    * --ignore: To ignore the specified files or directories 
 
* The cache policy specified is pull which only downloads the cache when the job starts, but any changes done in that job are not uploaded when the job finishes 

This job will be executed only when there is an open merge request on the branch

 






