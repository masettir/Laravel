#!/bin/bash

echo " "
echo " -----------------------------------------------------------------------"
echo "|                              Install                                  |"
echo " -----------------------------------------------------------------------"
echo " "

	
installDir=$( find /var/www -name 'laravel' | grep -v 'vendor' )
	
# | sed -e "s/\/composer.json//" | grep 'laravel' | grep -v ".proj" | grep -v 'vendor' )

for Dir in $( ls "$installDir" )
do
	laravelDir="$installDir/$Dir"
		
	#  get the name of the project
	projectName=$( basename "$laravelDir.proj" )	
	
	# if "LARAVEL" variable exists and there isn't already a project folder created then install laravel
	if [ ! -e "$laravelDir/$projectName" ] 
	then
		echo -e "  - Installing Laravel"
	    cd $laravelDir && composer create-project laravel/laravel $projectName $INSTALL_LARAVEL --prefer-source
	else		
		echo -e "  - $projectName exists in /web/root/$( echo $laravelDir | sed -e 's/\/var\/www\///g' ), resolving dependencies... \n"

		# Update the dependencies if there is a composer.lock file in the same directory as composer.json (meaning its already installed)
	    if [[ -e "$laravelDir/$projectName/composer.lock" ]]
   		then
       		cd $laravelDir/$projectName && composer update  && echo -e "\n  - Dependencies updated for $projectName" || echo '  - install failed'
		# if there is no composer.lock file in the same directory as the composer.json file (meaning composer has not installed dependencies in the directory) then install the dependencies), then echo the paths that have been installed to
	    else
       		cd $laravelDir/$projectName && composer install && echo -e "\n  - Dependencies for $projectName successfully installed" || echo '  - install failed'
   		fi
	fi
	# cd $laravelDir && chown -R "$HUSER":"$GROUP" "$projectName" && chmod -R 777 "$projectName/app/storage"
done
