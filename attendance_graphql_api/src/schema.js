import gql from "graphql-tag";

const typeDefs = gql`
  type Query {
    students: [Student!]!
    student(student_id: ID!): Student
  }

  type Mutation {
    addStudent(
      first_name: String!
      last_name: String!
      primary_contact: String!
      secondary_contact: String!
    ): AddStudentResponse
    updateStudent(
      student_id: ID!
      first_name: String!
      last_name: String!
      primary_contact: String!
      secondary_contact: String!
    ): UpdateStudentResponse
    deleteStudent(student_id: ID!): DeleteStudentResponse
  }

  type AddStudentResponse {
    code: Int!
    success: Boolean!
    message: String!
    student: Student
  }

  type UpdateStudentResponse {
    code: Int!
    success: Boolean!
    message: String!
    student: Student
  }

  type DeleteStudentResponse {
    code: Int!
    success: Boolean!
    message: String!
    student_id: ID!
  }

  type Student {
    student_id: ID!
    first_name: String!
    last_name: String!
    primary_contact: String!
    secondary_contact: String!
  }
`;

export default typeDefs;
