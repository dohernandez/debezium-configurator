import os
import json

prefix = os.environ['ENV_PREFIX'].lower()

config = {}

for env in os.environ.items():
  if(env[0].lower().startswith(prefix)):
    prop = env[0].lower().replace(prefix, '', 1).replace('_', '.')
    config[prop] = env[1]

connector = {}
connector["name"] = os.environ['CONNECTOR_NAME']
connector["config"] = config

print(json.dumps(connector))
