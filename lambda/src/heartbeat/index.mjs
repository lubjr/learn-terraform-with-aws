export const handler = async (event) => {
  const heartbeat = {
    message: "Heartbeat",
    source: event.source ?? "manual",
    time: new Date().toISOString(),
  };

  console.log(JSON.stringify(heartbeat));

  return {
    statusCode: 200,
    body: JSON.stringify(heartbeat),
  };
};
