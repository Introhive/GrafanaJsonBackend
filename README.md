# GrafanaJsonBackend
Backend Json server for Grafana SimpleJson Plugin.

## Usage

Search in grafana using following json format:

* {"return":"environment_list"} - List the all environments
* {"return":"region", "environment":"<ENV_LIST>|<ENV_NAME>"} - List the all regions or Return region for specified ENV_NAME
* {"return":"resource", "environment":"<ENV_LIST>|<ENV_NAME>", "namespace":"<AWS/RDS | AWS/ELB>"} - List the AWS resource for the specified environment(return list if contains more than 2).
* {"attribute":"<ATTRIBUTE_NAME>","return":"resource", "environment":"<ENV_LIST>|<ENV_NAME>", "namespace":"<AWS/RDS | AWS/ELB>"} - List the AWS  resource(extract only specified attribute) from the specified environment(return list if contains more than 2).

Dumb the Json data in db.json file.
