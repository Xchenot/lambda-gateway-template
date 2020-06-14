exports.handle = async (event) => {
  // TODO implement
  const response = {
      statusCode: 200,
      body: JSON.stringify('Hello mec, from Lambda!'),
  };
  return response;
};
