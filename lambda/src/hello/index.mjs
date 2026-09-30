export const handler = async (event) => {
  const name = event.name ?? "world";

  return {
    statusCode: 200,
    body: JSON.stringify({ message: `Hello, ${name}!` }),
  };
};
