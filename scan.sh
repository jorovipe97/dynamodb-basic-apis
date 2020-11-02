# Taken from
# https://www.dynamodbguide.com/scans

aws dynamodb scan \
    --table-name UserOrdersTable

aws dynamodb scan \
    --select COUNT \
    --table-name UserOrdersTable

# Pagination, this also works with scan
aws dynamodb scan \
    --table-name UserOrdersTable \
    --max-items 1

# Show next page.
aws dynamodb scan \
    --table-name UserOrdersTable \
    --max-items 1 \
    --starting-token NEXT_TOKEN

# One use case for Scans is to export the data into cold storage or for data analysis. If you have a large amount of data, scanning through a table with a single process can take quite a while.
# DynamoDB has the notion of Segments which allow for parallel scans. When making a Scan, a request can say how many Segments to divide the table into and which Segment number is claimed by the particular request. This allows you to spin up multiple threads or processes to scan the data in parallel.
aws dynamodb scan \
    --table-name UserOrdersTable \
    --total-segments 3 \
    --segment 1
