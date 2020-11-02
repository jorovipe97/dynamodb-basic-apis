# Taken from this chapter.
# https://www.dynamodbguide.com/querying

# Creates the table.
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
    --provisioned-throughput '{
      "ReadCapacityUnits": 1,
      "WriteCapacityUnits": 1
    }'

# Inserts dummy data into the table.
aws dynamodb batch-write-item --request-items file://UserOrdersTable.json

# Start querying
aws dynamodb query \
    --table-name UserOrdersTable \
    --key-condition-expression "Username = :username" \
    --expression-attribute-values '{
        ":username": { "S": "daffyduck" }
    }'

# Querying a table with simple primary key.
# This is just like a get item but i'm not sure about the read capacity units used with this
# compared to the ones used by the get-item. This is not recommended anyway it is just for playing around.
aws dynamodb query \
    --table-name ProductCatalog \
    --key-condition-expression "Id = :id" \
    --expression-attribute-values '{
        ":id": { "N": "201" }
    }'

# For example, if we wanted all Orders from 2017, we would make sure our OrderId was between "20170101" and "20180101":
aws dynamodb query \
    --table-name UserOrdersTable \
    --key-condition-expression "Username = :username AND OrderId BETWEEN :startdate AND :enddate" \
    --expression-attribute-values '{
        ":username": { "S": "daffyduck" },
        ":startdate": { "S": "20170101" },
        ":enddate": { "S": "20180101" }
    }'

# With projection expression
aws dynamodb query \
    --table-name UserOrdersTable \
    --key-condition-expression "Username = :username AND OrderId BETWEEN :startdate AND :enddate" \
    --expression-attribute-values '{
        ":username": { "S": "daffyduck" },
        ":startdate": { "S": "20170101" },
        ":enddate": { "S": "20180101" }
    }' \
    --projection-expression 'Amount'


# Filter expressions
# https://www.dynamodbguide.com/filtering
# Let's reuse our previous Query to find Daffy Duck's orders. This time, we're looking for the big ticket orders, so we'll add a filter expression to return Orders with Amounts over $100:
aws dynamodb query \
    --table-name UserOrdersTable \
    --key-condition-expression "Username = :username" \
    --filter-expression "Amount > :amount" \
    --expression-attribute-values '{
        ":username": { "S": "daffyduck" },
        ":amount": { "N": "100" }
    }' \
    --return-consumed-capacity TOTAL