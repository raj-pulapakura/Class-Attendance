const { ApolloServer } = require("@apollo/server");
const { startStandaloneServer } = require("@apollo/server/standalone");

const typeDefs = require("./schema");
const resolvers = require("./resolvers");
const StudentAPI = require("./datasources/studentApi");

async function startApolloServer() {
    const server = new ApolloServer({
        typeDefs,
        resolvers,
    });

    const {url} = await startStandaloneServer(server, { 
        context: async () => {
            const { cache } = server;
            return {
                dataSources: {
                    studentAPI: new StudentAPI({ cache }),
                }
            }
        }
     });
    
    console.log(`
    🚀 Server is running!
    📭 Query at ${url}
    `)
}

startApolloServer();

