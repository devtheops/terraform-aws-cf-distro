const path = require("path");
const INDEX_PATH = "${INDEX_PATH}";

exports.handler = (event, context, callback) => {
  const { request } = event.Records[0].cf;

  console.log("Request URI: ", request.uri);

  const parsedPath = path.parse(request.uri);
  let newUri;

  console.log("Parsed Path: ", parsedPath);

  if (parsedPath.ext === "") {
    newUri = INDEX_PATH;
  } else {
    newUri = request.uri;
  }

  console.log("New URI: ", newUri);

  // Replace the received URI with the URI that includes the index page
  request.uri = newUri;

  // Return to CloudFront
  return callback(null, request);
};
