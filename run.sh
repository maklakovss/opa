# running of two containers for authorization based on the Open Policy Agent (OPA) and the Open Policy Administrative Level (OPAL - server + client)
# OPA responds to authorization requests from the orchestrator service using a rego script and a data object
# OPAL regularly updates rego script and data object from repository and send updates to OPA as needed

# create network for communicate between opal_client and opal_server
sudo docker network create opa

# run opal_server container based on official image (contains OPAL-server)
# port 7002 - used for opal_client communicate with opal_server (not required outside now)
# OPAL_POLICY_REPO_URL - repo url with rego script and data, may include username and password
# OPAL_POLICY_REPO_POLLING_INTERVAL - interval in seconds to check for updates in repo
# OPAL_DATA_CONFIG_SOURCES - data source settings
sudo docker run -d --network opa -e "OPAL_POLICY_REPO_URL=https://github.com/maklakovss/opa.git" -e "OPAL_POLICY_REPO_POLLING_INTERVAL=30" -e 'OPAL_DATA_CONFIG_SOURCES={"config":{"entries":[{"url":"http://opal_server:7002/policy-data","topics":["policy_data"],"dst_path":"/static"}]}}' --name opal_server permitio/opal-server:latest

# run opal_client and opa based on official image (contains OPAL-client and OPA-service)
# port 7000 - used for communicate with opal_client (not required outside now)
# port 8181 - for communicate with opa (used for orchestrator)
# OPAL_SERVER_URL - for getting initial policies and data after opal_client start
sudo docker run -d --network opa -p 8181:8181 -e "OPAL_SERVER_URL=http://opal_server:7002" --name opal_client permitio/opal-client:latest
