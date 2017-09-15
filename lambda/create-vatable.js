exports.createVatable2 = (event, context, callback) => {
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
        if (Object.keys(data).length === 0) {
            err = insertVatable(docClient, event)
            callback(err)
        } else {
            console.log(`${event.name} exists`)
            err = {
                code: 409,
                message: "Vatable already exists"
            }
            callback(JSON.stringify(err))
        }
    }
});
};

function insertVatable(docClient, event) {
    var params = {
        TableName:'vatable',
        Item:{
            "name": event.name.toLowerCase(),
            "up": 0,
            "down": 0,
            "report": 0
        }
    }

    console.log("Adding a new item...")
    docClient.put(params, function(err, data) {
        if (err) {
            console.error("Unable to add item. Error JSON:", JSON.stringify(err, null, 2))
            console.error(err)
            return err
        } else {
            console.log("Added item:", JSON.stringify(data, null, 2))
        }
    });
}
