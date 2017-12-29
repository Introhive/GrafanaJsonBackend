# GrafanaJsonBackend
Backend Json server for Grafana SimpleJson Plugin.

## Usage

Search in grafana using following json format:

* {"region":"<AWS_REGION>", environment":"list"} - List the environments
* {"region":"<AWS_REGION>", "environment":"<environment_name>", "namespace":"<AWS/RDS | AWS/ELB>"} - List the RDS or ELB resource for the specified environment.

Dumb the Json data in db.json file.