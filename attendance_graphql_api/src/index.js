import { ApolloServer } from "@apollo/server";
import { startStandaloneServer } from "@apollo/server/standalone";
import {
  startServerAndCreateLambdaHandler,
  handlers,
} from "@as-integrations/aws-lambda";
import typeDefs from "./schema.js";
import resolvers from "./resolvers.js";
import StudentAPI from "./datasources/studentApi.js";

async function startApolloServer() {
  const server = new ApolloServer({
    typeDefs,
    resolvers,
  });

  // UNCOMMENT THIS DURING DEVELOPMENT
  // const { url } = await startStandaloneServer(server, {
  //   context: async () => {
  //     const { cache } = server;
  //     return {
  //       dataSources: {
  //         studentAPI: new StudentAPI({ cache }),
  //       },
  //     };
  //   },
  // });

  console.log(`
    🚀 Server is running!
    `);

  return server;
}

const server = await startApolloServer();

// COMMENT THIS DURING DEVELOPMENT:
export const graphqlHandler = startServerAndCreateLambdaHandler(
  server,
  handlers.createAPIGatewayProxyEventV2RequestHandler(),
  {
    context: async () => {
      const { cache } = server;
      return {
        dataSources: {
          studentAPI: new StudentAPI({ cache }),
        },
      };
    },
  }
);
