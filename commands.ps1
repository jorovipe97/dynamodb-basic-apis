aws dynamodb batch-write-item --request-items file://ProductCatalog.json

# Get Simple item.
aws dynamodb get-item `
    --table-name ProductCatalog `
    --key file://retrieve-data/ProductCatalogKey.json `
		--return-consumed-capacity TOTAL

# Get item and show consumed capacity.
aws dynamodb get-item `
    --table-name ProductCatalog `
    --key file://retrieve-data/ProductCatalogKey.json `
		--return-consumed-capacity TOTAL

# Use projection expressions
# filterexpressions and projectexpressions are applied after the query has
# completed. So keep in mind that the number of Read Capacity Units will
# be the same whether you use these or not, however you can use it to save
# bandwidth usage. (Maybe for faster downloads).
aws dynamodb get-item `
    --table-name ProductCatalog `
    --key file://retrieve-data/ProductCatalogKey.json `
		--projection-expression "Title, Description" `
		--return-consumed-capacity TOTAL

aws dynamodb get-item `
    --table-name ProductCatalog `
    --key file://retrieve-data/ProductCatalogKey.json `
		--projection-expression "#t, #d" `
		--expression-attribute-name file://retrieve-data/expression-attribute-names.json `
		--return-consumed-capacity TOTAL

# Conditional Write
# Write only if Product id doesnt already exists.
aws dynamodb put-item `
    --table-name ProductCatalog `
    --item file://retrieve-data/product-item.json `
    --condition-expression "attribute_not_exists(#id)" `
    --expression-attribute-names '{ \"#id\": \"Id\" }'

aws dynamodb put-item `
    --table-name ProductCatalog `
    --item file://retrieve-data/product-item.json `
    --condition-expression "attribute_not_exists(Id)"

# Update Item
aws dynamodb update-item `
    --table-name ProductCatalog `
    --key '{
      \"Id\": {\"N\": \"101\"}
    }' `
    --update-expression 'SET #b = :b' `
    --expression-attribute-names '{
      \"#b\": \"Brand\"
    }' `
    --expression-attribute-values '{
      \":b\": {\"S\": \"The Super Company\"}
    }'

aws dynamodb get-item `
		--table-name ProductCatalog `
		--key '{
			\"Id\": { \"N\": \"101\" }
		}'