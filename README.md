Laravel
=======

Laravel set up in a CentOS docker contiainor

The Laravel containor is set up to be linked to a sql ( Mysql, MariDB, SQlite, etc.. ) database containor. If the database has an environment variable set for "DBNAME" Laravel will use that name allong with the connection variables from the database containor to automatically set the connection parameters in Laravel's database.php configuration file.

Laravel will search its /var/www directory ( which can be connected to a volume or host directory outside the containor ) for a directory called laravel, in this directory it looks for any directory containing a ".proj" extension, if found, the laravel containor will recognize this directory as an existing laravel project and use it to set up the project. If nothing is found in the laravel directory it will create and install a new laravel project in all directories found within the laravel directory, and name those projects after thier parent directories. 

For example, if you have a laravel directory and create an empty directory called 'myproject' inside of it, when you start the laravel container, laravel will create a laravel project in 'myproject' called 'myproject.proj', so the file structure would be:

var/www/path/to/laravel/myproject/myproject.proj

This way if you have multiple projects you can hold them in a directory or directories called laravel anywhere in the volume or mounted directory and the laravel docker containor will find and install or set up the projects found in that directory.

The laravel containor will also run Artisan commands that can be stringed together with the '-e' or '--env' tags in the Docker RUN command. 

example:                                           
Docker RUN -e INSTALL_LARAVEL=4.2.* repo/name:tag  

In the above example the container would install laravel with the specified version, there are several environment variables that can be set:

'INSTALL_LARAVEL'
----------------
will install whatever laravel version you specify on the right side of the environment varibale, if you want to install the developement version for exampele you would set the variable to 'INSTALL_LARAVEL=dev-develop' and this can be done for all retrievable versions of laravel.

'CONNECT'
--------
will cause laravel to find and automatically set the database connections for laravel based on the connection variables of a linked database containor. The 'CONNECT' variable can be set to anything, Laravel must however be linked to a database containor for the connection variables to be set by the laravel containor.

examples:
'CONNECT=yes',
'CONNECT=anyting',           
or even, 'CONNECT=esgbrtir'  

'DUMP'
------
will dump and reload composer's autoload tables when it is set to anything.

'REFRESH'
-
will roll back all migrations and run them all again and can be set to anything.

'RESET'
-
will roll back all migrations and can be set to anything.

'CREATE'
-
will install the initial migration table used for migrations and can be set to anything.

'MIGRATIONS_PATH' 
-
sets a path to find or create migrations in.

example:
'MIGRATIONS_PATH=/path/to/migrations' to specify path to directory or file

'MIGRATE'
-
will run migrations, allong with 'MIGRATIONS_PATH' it can be set by specify a path to whatever directory or file you wish to migrate, and if set to 'all' or '*', will run all migrations in the default migration folder.

examples:                                                                             
'MIGRATE=filename' and 'MIGRATIONS_PATH=/migrations/path' for a specific folder,      
'MIGRATE=filename' for a specific migration file,                                   
'MIGRATE=all' or 'MIGRATE=*' runs all migrations in the default migrations directory

'MAKE'
-
will create a migration, it should be set to the desired name of the migration. if used while the 'MIGRATIONS_PATH' variable is set, will create a file in the directory specified in that variable, otherwise the migration will be created in the default migrations directory

example:
'MAKE=MyMigrationTableName'

and finally,

'SEED'
-
will run the seed database command, and seed the database, it can be set to anything.

All of these commands can be stringed together for fluid set up and editing of your laravel environment, for example, if you were to run:

docker run -d -v /web/root:/var/www -e INSTALL_LARAVEL=4.2.* -e CREATE=yes -e MIGRATE=all -e SEED=yes --link db:laravel repo/name:tag

then the docker containor would find the install directory for laravel, install laravel 4, create a migrations table in the database it has been linked to, run all migrations and then seed the database.

then later, if lets say you need to reset the autoload tables and refresh the database, and you have new data to add/seed into your database, but you dont need to install laravel, or whatever else, then you can run the container again with the necessary commands. 

for example:
docker run -d -v /web/root:/var/www -e DUMP=yup -e REFRESH=anything -e SEED=yes --link db:laravel repo/name:tag

would do the trick.

Thats pretty much it for the laravel containor, I hope it proves useful and easy to use.
