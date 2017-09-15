exports.getVatable2 = (event, context, callback) => {
    console.log("Handle request")
    var AWS = require("aws-sdk")
    console.log("Created AWS")
    var docClient = new AWS.DynamoDB.DocumentClient()
    console.log("Created docclient")

    var params = {
        TableName:'vatable',
        Key:{
            "name": event.name
        }
    }
    docClient.get(params, function(err, data) {
        if (err) {
            console.error("Unable to read item. Error JSON:", JSON.stringify(err, null, 2))
            throw err
        } else {
            console.log("GetItem succeeded:", JSON.stringify(data))
            if (Object.keys(data).length > 0) {
                callback(null, data.Item)
            } else {
                var error = {
                    code: 404,
                    message: "Vatable not found"
                };
                callback(JSON.stringify(error))
            }
        }
    })
};
