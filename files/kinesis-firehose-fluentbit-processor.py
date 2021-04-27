"""
{
  "invocationId": "invocationIdExample",
  "deliverySteamArn": "arn:aws:kinesis:EXAMPLE",
  "region": "us-east-1",
  "records": [
    {
      "recordId": "49546986683135544286507457936321625675700192471156785154",
      "approximateArrivalTimestamp": 1495072949453,
      "kinesisRecordMetadata": {
        "sequenceNumber": "49545115243490985018280067714973144582180062593244200961",
        "subsequenceNumber": "123456",
        "partitionKey": "partitionKey-03",
        "shardId": "shardId-000000000000",
        "approximateArrivalTimestamp": 1495072949453
      },
      "data": "SGVsbG8sIHRoaXMgaXMgYSB0ZXN0IDEyMy4="
    }
  ]
}
"""

from __future__ import print_function

import base64
import json


print('Loading function')

# def transformLogEvent(log_event, region):
# 
#     index = "splunk-test"
#     sourcetype = "json"
#     print('Received log event %s' % (log_event))
# 
#     # Need to add time parsing here
# 
#     return_message = '{"index": "' + index + '"'
#     return_message = return_message + ',"sourcetype":"' + sourcetype + '"'
#     return_message = return_message + ',"event": ' + json.dumps(log_event) + '}\n'
# 
#     return return_message + '\n'


def transformLogEvent(payload):

    index = "splunk-test"
    sourcetype = "json"
    print('Received log event %s' % (payload))

    # Need to add splunk specific time parsing here, this is dependent on log format that fluentbit generates

    return_message = '{"index": "' + index + '"'
    return_message = return_message + ',"sourcetype":"' + sourcetype + '"'
    return_message = return_message + ',"event": "' + str(payload) + '"}\n'

    return return_message + '\n'

def lambda_handler(event, context):
    output = []

    for record in event['records']:
        print(record['recordId'])
        payload = base64.b64decode(record['data'])
        payload = transformLogEvent(payload)
        
        print(record['recordId'])

        # Print stream as source only data here
        kinesisMetadata = record['kinesisRecordMetadata']
        print(kinesisMetadata['sequenceNumber'])
        print(kinesisMetadata['subsequenceNumber'])
        print(kinesisMetadata['partitionKey'])
        print(kinesisMetadata['shardId'])
        print(kinesisMetadata['approximateArrivalTimestamp'])

        # Do custom processing on the payload here
        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(payload.encode())
        }
        output.append(output_record)

    print('Successfully processed {} records.'.format(len(event['records'])))

    return {'records': output}