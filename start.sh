#!/bin/bash

# install Laravel if specified
if [ ! -z "$INSTALL_LARAVEL" ]
then 
	install.sh
fi

# The "larCon" function sets the connection variables in the Laravel database configuration file
larCon(){
	if [[ -z "$( grep $1 $3 | grep -v '6379' | grep -v 'supported' )" ]]
	then
		grep "'host'" $3 | sort | uniq | while read -r append 
		do
			sed -i -e "1,114 s/.*$append.*/&\n$1  => '$2',/" $3;			
		done
	else
		grep $1 $3 | grep -v '=> __DIR__.' | grep -v '6379' | grep -v 'supported' | sort | uniq | while read -r pre  
		do
			sed -i -e "1,114 s/$pre/$1  => '$2',/" $3;
		done	
	fi		
}

# find the name of connected containers
Name=$(env | egrep 'ADDR' | egrep -o '^[^_]+' | grep -v -E '(HOSTNAME=|TERM|PWD|SHLVL|HOME|PATH)')

# find the laravel directory
laravelDir=$( find /var/www -name 'laravel' | grep -v 'vendor' )

if [ -z "$laravelDir" ]
then
	echo '  - No Laravel directory found'
else
	for dir in $laravelDir
	do 
		if [ -z $PROJECT ]
		then
			# if no project is specified search for any project and then attempt migrations in each ( without any specified variables this will migrate all projects )
			project=$( find $dir -name "*.proj" );
		else
			# find a specified project to run migrations from 
			project=$( find $dir -name "$PROJECT" );
		fi
	
		if [ -z $project ]
		then
			echo '  - no project found'	
		else
			for projDir in $project
			do
				for Alias in $Name;
				do
					# add numbers to initialized variable to number each connection with
					Number=$(($Number+1))
	
					# "Hname", "Port" and "Addr" are the host name, port and ip address of the linked connection being evaluated 
					Hname=$(env | grep $Alias'_ENV_HOSTNAME=' | grep -o '=.*' | tr -d '", =') 
					Port=$(env | egrep 'PORT='| egrep $Alias | egrep -v ':' | egrep -o '=.*' | tr -d '=')
					Addr=$(env | egrep $Alias'_PORT_'$Port'_TCP_ADDR=' | grep -o '=.*' | tr -d '=')
					Extdbname=$(env | grep $Alias'_ENV_DBNAME=' | grep -o '=.*' | tr -d '", =')	
					User=$( env | grep $Alias'_ENV_HUSER=' | grep -o '=.*' | tr -d '", =')
					Pwd=$( env | grep $Alias'_ENV_PASSWORD=' | grep -o '=.*' | tr -d '", =')
					migrationDir=$( find $projDir -name 'migrations' )
				
					if [ ! -z "$CONNECT" ]
					then
						echo " "
						echo " -----------------------------------------------------------------------"
						echo "|                            Connections                                |"
						echo " -----------------------------------------------------------------------"
						echo " "
					
						if [ ! -z "$( find /var/www -name '*.proj' )" ]	
						then
							for laravelDir in $( find /var/www -name '*.proj' )
							do
								if [ -z "$Extdbname" ]
								then
									dbName=$( basename $laravelDir | sed 's/.proj//g' )
								else
									dbName=$Extdbname
								fi	
								
								declare -a laravelDBs=$( find $laravelDir -name 'database.php' )

								for laravelDB in $laravelDBs
								do
									larCon "'port'" $Port $laravelDB 
        							larCon "'host'" $Addr $laravelDB
            						larCon "'database'" $dbName $laravelDB
            						larCon "'username'" $User $laravelDB
                    				larCon "'password'" $Pwd $laravelDB
               	 				done
               	 				echo "  - database connections set for laravel project \"$( basename $laravelDir )\" located in $( echo /web/root/$( echo $laravelDir | sed -e 's/\/var\/www\///g' ) | sed 's/\/$( basename $laravelDir )//g' )"
               	 				echo -e "  - $( basename $laravelDir ) is $( cd $laravelDir && php artisan -V )"
							done
						fi
					fi	
				
					# wait until MariaDB has started
 					x=0
					until [[ ! -z $( mysql -h "$Addr" -P "$Port" -u"$User" -p"$Pwd" -B -e "show databases" 2>/dev/null ) ]]
					do
						sleep 1
						x=$(($x+1))
		
						# if it takes longer then a minute then stop trying
						if [[ "$x" -gt "60" ]]
						then
							break && echo '  - could not connect to mysql'
						fi
 			  		done
   		
   		
   					if [ ! -z "$DUMP" ] || [ ! -z "$RESET" ] || [ ! -z "$REFRESH" ]
   					then
   						echo " "
						echo " -----------------------------------------------------------------------"
						echo "|                               Renewal                                 |"
						echo " -----------------------------------------------------------------------"
						echo " "
   					
						if [ ! -z "$DUMP" ]
						then
							echo -n ' - Dumping composer autoload...' && \
							cd $projDir && composer dump-autoload && echo ' success' || echo ' failed'
						fi
						
						if [ ! -z "$RESET" ]
						then
							echo "  - resetting migrations in $projDir" && \
							cd $projDir && php artisan migrate:reset
						fi
				
						if [ ! -z "$REFRESH" ]
						then
							echo "  - Refreshing migrations in $proDir" && \
							cd $projDir && php artisan migrate:refresh -y
						fi
					fi
					
					# migrate install if specified
					if [ ! -z "$CREATE" ]
					then
						echo " "
						echo " -----------------------------------------------------------------------"
						echo "|                      Migration table creation                         |"
						echo " -----------------------------------------------------------------------"
						echo " "
						echo '  - Installing migrations' && \
						cd $projDir && php artisan migrate:install
					fi						
								
					# check whether a file or folder has been specified for migration
					if [ ! -z "$MIGRATE" ]
					then
						echo " "
						echo " -----------------------------------------------------------------------"
						echo "|                             Migrations                                |"
						echo " -----------------------------------------------------------------------"
						echo " "
						if [ "$MIGRATE" == "all" ] || [ "$MIGRATE" == "*" ]
						then
							echo '  - running migrations' && \
							# run migrations on whole migrations directory if there is no file specified
							cd $projDir && php artisan migrate 
						else	
							echo "  - running migrations from $migrationDir/$RUN" && \
							# run migrations on specified file
							cd $projDir && php artisan migrate --path=$migrationDir/$MIGRATE
						fi	
					fi		
	
					if [ ! -z "$MAKE" ]
					then
						echo " "
						echo " -----------------------------------------------------------------------"
						echo "|                         Migration creation                            |"
						echo " -----------------------------------------------------------------------"
						echo " "
						if [ -z "$MIGRATION_PATH" ]
						then
							echo " - creating migration file called $MAKE" && \
							cd $projDir && php artisan migrate:make "$MAKE"
						else
							echo "  - creating migration file called $MAKE in $MIGRATION_PATH" && \
							cd $projDir && php artisan migrate:make "$MAKE" --path="$MIGRATION_PATH"
						fi	
					fi
					
					if [ ! -z "$SEED" ]
					then
						echo " "
						echo " -----------------------------------------------------------------------"
						echo "|                              Seeding                                  |"
						echo " -----------------------------------------------------------------------"
						echo " "
						echo '  - seeding database' && \
						cd $projDir && php artisan db:seed
					fi
				done
			done
		fi
	done
fi