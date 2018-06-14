# GrafanaJsonBackend
Backend Json server for Grafana SimpleJson Plugin.

## Usage

Search in grafana using following json format:

* {"return":"environment_list"} - List the all environments
* {"return":"region", "environment": "<ENV_NAME>"} - Return region for specified ENV_NAME
* {"return":"namespace", "region":"<AWS_REGION>", "environment":"<environment_name>", "namespace":"<AWS/RDS | AWS/ELB>"} - List the RDS or ELB resource for the specified environment.

Dumb the Json data in db.json file.