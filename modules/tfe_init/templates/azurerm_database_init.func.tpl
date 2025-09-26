%{ if msi_auth_enabled ~}

# Updates the owner of database to `azure_pg_admin` so that 
# MSI identity user can perform operations in the database
function azurerm_database_init {
	local log_pathname=$1

	%{ if distribution == "ubuntu" ~}
	apt-get --assume-yes update
	apt-get --assume-yes install postgresql-client
	%{ else ~}
	yum install --assumeyes postgresql
	%{ endif ~}

	# Database connection parameters
	DB_HOST='${database_host}'
	DB_PORT="5432"
	DEFAULT_DATABASE="postgres"
	DB_USER='${admin_database_username}'
	DB_PASSWORD='${admin_database_password}'

	# SQL command to execute
	SQL_COMMAND="ALTER DATABASE ${database_name} OWNER TO azure_pg_admin;"

	echo "[Terraform Enterprise] Changing owner of database '${database_name}' to 'azure_pg_admin'." | tee -a $log_pathname

	if PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DEFAULT_DATABASE -c "$SQL_COMMAND"; then
		echo "[Terraform Enterprise] Successfully changed database owner." | tee -a $log_pathname
	else
		echo "[Terraform Enterprise] ERROR: Failed to change database owner." | tee -a $log_pathname
    fi
}
%{ endif ~}
