# kinesis_demo


https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy

```bash
aws kinesis put-record \
    --stream-name kinesis_stream \
    --data eyJldmVudCI6ICJZdWFuIGtpbmVzaXMgdGVzdCEifQo= \
    --partition-key "test"
```

```bash
aws kinesis put-record \
    --stream-name kinesis_stream \
    --data eyJldmVudCI6ICJZdWFuIGtpbmVzaXMgdGVzdCAoaW5kZXhlciBhY2sgZW5hYmxlZCkhIn0K \
    --partition-key "test"
```

eyJldmVudCI6ICJZdWFuIGtpbmVzaXMgdGVzdCEifQo= = {"event": "Yuan kinesis test!"}
eyJldmVudCI6ICJZdWFuIGtpbmVzaXMgdGVzdCAoaW5kZXhlciBhY2sgZW5hYmxlZCkhIn0K '{"event": "Yuan kinesis test (indexer ack enabled)!"}'

```bash
curl -k "<HEC Endpoint>" \
    -H "Authorization: Splunk <Hec Token>" \
    -d '{"event": "Yuan test!"}'
```

```bash
aws firehose put-record \
    --delivery-stream-name kinesis_firehose2 \
    --record '{"Data":"eyJldmVudCI6ICJIZWxsbywgd29ybGQhIiwgInNvdXJjZXR5cGUiOiAianNvbiJ9Cg=="}'
```

eyJldmVudCI6ICJIZWxsbywgd29ybGQhIiwgInNvdXJjZXR5cGUiOiAianNvbiJ9Cg== = {"event": "Hello, world!", "sourcetype": "json"}

```bash
docker build -t fluentbit-demo --build-arg AWS_DEFAULT_REGION=$REGION --build-arg AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID --build-arg AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY .
```

