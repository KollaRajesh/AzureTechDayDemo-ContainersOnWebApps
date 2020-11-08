$resourceGroup="aztechdAppgroup"
$location ="eastus"

az group create  -l $location  -n $resourceGroup


$planName="aztechwpappserviceplan"

az appservice plan create  -n $planName -g $resourceGroup -l $location  --is-linux --sku S1

$mysqlServerName ="aztechmysqlwpas"
$adminUser ="wpadmin"

$adminPassword ="p05530rd$"

az mysql server create -g $resourceGroup  -n  $mysqlServerName `
    --admin-user $adminUser --admin-password $adminPassword `
    -l $location `
    --ssl-enforcement Disabled `
   --sku-name GP_Gen5_2 --version 5.7 ## --no-wait

az mysql server firewall-rule create -g $resourceGroup `
 --server $mysqlServerName --name  AllowAppService  `
  --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

$appName="aztechwordpress"

$dockerRepo="wordpress"

az webapp create  -n $appName -g $resourceGroup --plan $PlanName   -i  $dockerRepo

$wordpressDbHost =(az mysql server show -g $resourceGroup -n $mysqlServerName  --query "fullyQualifiedDomainName"  -o tsv)

$wordpressDbHost


az webapp config appsettings set -n $appName -g $resourceGroup --settings `
       WORDPRESS_DB_HOST=$wordpressDbHost `
       WORDPRESS_DB_USER="$adminUser@$mysqlServerName" `
       WORDPRESS_DB_PASSWORD="$adminPassword"


az webapp show -n $appName -g $resourceGroup  --query  "defaultHostName" -o tsv

az appservice plan update -n $planName  -g $resourceGroup --number-of-workers 3

az group delete -n $resourceGroup --no-wait --yes 
##az group show -n $resourceGroup
##az group exists -n $resourceGroup