import { randomUUID } from "node:crypto";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DeleteCommand,
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  ScanCommand,
} from "@aws-sdk/lib-dynamodb";

const client = DynamoDBDocumentClient.from(new DynamoDBClient());
const TableName = process.env.TABLE_NAME;

const json = (statusCode, body) => ({
  statusCode,
  headers: { "content-type": "application/json" },
  body: JSON.stringify(body),
});

const parseBody = (event) => {
  if (!event.body) return {};
  const raw = event.isBase64Encoded
    ? Buffer.from(event.body, "base64").toString("utf8")
    : event.body;
  const body = JSON.parse(raw);
  if (typeof body !== "object" || body === null || Array.isArray(body)) {
    throw new SyntaxError("Body must be a JSON object");
  }
  return body;
};

const routes = {
  "GET /items": async () => {
    const { Items } = await client.send(new ScanCommand({ TableName }));
    return json(200, Items);
  },

  "POST /items": async (event) => {
    const item = { ...parseBody(event), id: randomUUID(), createdAt: new Date().toISOString() };
    await client.send(new PutCommand({ TableName, Item: item }));
    return json(201, item);
  },

  "GET /items/{id}": async (event) => {
    const { Item } = await client.send(
      new GetCommand({ TableName, Key: { id: event.pathParameters.id } }),
    );
    return Item ? json(200, Item) : json(404, { message: "Item not found" });
  },

  "PUT /items/{id}": async (event) => {
    const item = { ...parseBody(event), id: event.pathParameters.id, updatedAt: new Date().toISOString() };
    await client.send(
      new PutCommand({ TableName, Item: item, ConditionExpression: "attribute_exists(id)" }),
    );
    return json(200, item);
  },

  "DELETE /items/{id}": async (event) => {
    await client.send(
      new DeleteCommand({
        TableName,
        Key: { id: event.pathParameters.id },
        ConditionExpression: "attribute_exists(id)",
      }),
    );
    return { statusCode: 204 };
  },
};

export const handler = async (event) => {
  const route = routes[event.routeKey];
  if (!route) return json(404, { message: "Route not found" });

  try {
    return await route(event);
  } catch (error) {
    if (error instanceof SyntaxError) return json(400, { message: "Body must be valid JSON" });
    if (error.name === "ConditionalCheckFailedException") return json(404, { message: "Item not found" });

    console.error(error);
    return json(500, { message: "Internal server error" });
  }
};
