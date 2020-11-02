# https://www.dynamodbguide.com/local-secondary-indexes
# Unfortunately, local secondary indexes must be specified at time of table creation. First, we'll need to delete our table:
aws dynamodb delete-table \
    --table-name UserOrdersTable

# Create table with local secondary indexes.
aws dynamodb create-table \
    --table-name UserOrdersTable \
    --attribute-definitions '[
      {
          "AttributeName": "Username",
          "AttributeType": "S"
      },
      {
          "AttributeName": "OrderId",
          "AttributeType": "S"
      },
      {
          "AttributeName": "Amount",
          "AttributeType": "N"
      }
    ]' \
    --key-schema '[
      {
          "AttributeName": "Username",
          "KeyType": "HASH"
      },
      {
          "AttributeName": "OrderId",
          "KeyType": "RANGE"
      }
    ]' \
    --local-secondary-indexes '[
      {
          "IndexName": "UserAmountIndex",
          "KeySchema": [
              {
                  "AttributeName": "Username",
                  "KeyType": "HASH"
              },
              {
                  "AttributeName": "Amount",
                  "KeyType": "RANGE"
              }
          ],
          "Projection": {
              "ProjectionType": "KEYS_ONLY"
          }
      }
    ]' \
    --provisioned-throughput '{
      "ReadCapacityUnits": 1,
      "WriteCapacityUnits": 1
    }'

# Inserts dummy data into the table.
aws dynamodb batch-write-item --request-items file://UserOrdersTable.json

# Count inserted items
aws dynamodb scan \
    --table-name UserOrdersTable \
    --select COUNT

# Now we can remove the use a query instead of the filter.
# With filter.
aws dynamodb query \
    --table-name UserOrdersTable \
    --key-condition-expression "Username = :username" \
    --filter-expression "Amount > :amount" \
    --expression-attribute-values '{
        ":username": { "S": "daffyduck" },
        ":amount": { "N": "100" }
    }' \
    --return-consumed-capacity TOTAL

# With local secondary index.
aws dynamodb query \
    --table-name UserOrdersTable \
    --index-name UserAmountIndex \
    --key-condition-expression "Username = :username AND Amount > :amount" \
    --expression-attribute-values '{
        ":username": { "S": "daffyduck" },
        ":amount": { "N": "100" }
    }' \
    --return-consumed-capacity TOTAL

# Creating global secondary indexes
aws dynamodb update-table \
    --table-name UserOrdersTable \
    --attribute-definitions '[
      {
          "AttributeName": "ReturnDate",
          "AttributeType": "S"
      },
      {
          "AttributeName": "OrderId",
          "AttributeType": "S"
      }
    ]' \
    --global-secondary-index-updates '[
        {
            "Create": {
                "IndexName": "ReturnDateOrderIdIndex",
                "KeySchema": [
                    {
                        "AttributeName": "ReturnDate",
                        "KeyType": "HASH"
                    },
                    {
                        "AttributeName": "OrderId",
                        "KeyType": "RANGE"
                    }
                ],
                "Projection": {
                    "ProjectionType": "ALL"
                },
                "ProvisionedThroughput": {
                    "ReadCapacityUnits": 1,
                    "WriteCapacityUnits": 1
                }
            }
        }
    ]'

aws dynamodb scan \
    --table-name UserOrdersTable \
    --index-name ReturnDateOrderIdIndex

# Create items that will be in the global secondary index
aws dynamodb batch-write-item \
    --request-items file://UserOrdersTable-GlobalIndex.json

# Scan the global secondary index
aws dynamodb scan \
    --table-name UserOrdersTable \
    --index-name ReturnDateOrderIdIndex