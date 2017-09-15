exports.searchVatable2 = (event, context, callback) => {
    console.log("Handle request")
    var AWS = require("aws-sdk")
    console.log("Created AWS")
    var docClient = new AWS.DynamoDB.DocumentClient()
    console.log("Created docclient")


    var params = {
        TableName: "vatable",
        ProjectionExpression: "#vatabale",
        FilterExpression: "(contains(#vatabale, :name))",
        ExpressionAttributeNames: {
             "#vatabale": 'name'
        },
        ExpressionAttributeValues: {
             ":name": event.name.toLowerCase()
        }
    }

    console.log(`Scan for ${JSON.stringify(params)}`)
    docClient.scan(params, function(err, data) {
        if (err) {
            console.error("Unable to read item. Error JSON:", JSON.stringify(err, null, 2))
            throw err
        } else {
            console.log("GetItem succeeded:", JSON.stringify(data))
            if (Object.keys(data).length > 0) {
                callback(null, data.Items)
            } else {
                console.log(`No vatables found for ${event.name}`)
                callback(null, [])
            }
        }
    })
};
