exports.downVatable2 = (event, context, callback) => {
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
        callback(JSON.stringify(err))
    } else {
        console.log("GetItem succeeded:", JSON.stringify(data))
        if (Object.keys(data).length > 0) {
            err = downVatable(docClient, event)
            callback(JSON.stringify(err))
        } else {
            console.log(`${event.name} exists`)
            err = {
                code: 404,
                message: "Vatable doesn't exist"
            }
            callback(JSON.stringify(err))
        }
    }
});
};

function downVatable(docClient, event) {
    var params = {
        TableName: 'vatable',
        Key:{
            "name": event.name
        },
        UpdateExpression: "set down = down + :val",
        ExpressionAttributeValues:{
            ":val":1
        },
        ReturnValues:"UPDATED_NEW"
    };

    console.log(`Downing ${event.name}`)
    docClient.update(params, function(err, data) {
        if (err) {
            console.error(`Unable to down ${event.name}`)
            console.error(err)
            return err
        } else {
            console.log(`Downed ${event.name}`)
        }
    });
}
