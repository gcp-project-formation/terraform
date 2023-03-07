import sys
import yaml

fileName = "configMap.yaml"

stream = open(fileName, 'r')
data = yaml.load(stream)

print(sys.argv[1])
data['data']['REDIS_ADDR'] = sys.argv[1] + ":6379"

with open(fileName, 'w') as yaml_file:
    yaml_file.write( yaml.dump(data, default_flow_style=False))