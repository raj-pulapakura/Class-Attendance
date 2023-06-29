const resolvers = {
    Query: {
        // returns an array of Students
        students: (_, __, { dataSources }) => {
            return dataSources.studentAPI.getStudents();
        },
        // return a single Student by ID
        student: (_, { student_id }, { dataSources }) => {
            return dataSources.studentAPI.getStudent(student_id);
        }
    },
    Mutation: {
        // adds a new Student
        addStudent: async (_, { first_name, last_name, primary_contact, secondary_contact }, { dataSources }) => {
            try {
                const student = await dataSources.studentAPI.addStudent(first_name, last_name, primary_contact, secondary_contact);
                
                return {
                    code: 200,
                    success: true,
                    message: `Successfully added Student (${student.student_id})`,
                    student: student,
                }
            } catch (err) {
                return {
                    code: err.extensions.response.status,
                    success: false,
                    message: err.extensions.response.body.detail[0].msg,
                    student: null,
                }
            }
            
        },
        // updates an existing Student
        updateStudent: async (_, { student_id, first_name, last_name, primary_contact, secondary_contact }, { dataSources }) => {
            try {
                const student = await dataSources.studentAPI.updateStudent(student_id, first_name, last_name, primary_contact, secondary_contact);

                return {
                    code: 200,
                    success: true,
                    message: `Successfully updated Student (${student.student_id})`,
                    student: student,
                }
            } catch (err) {
                return {
                    code: err.extensions.response.status,
                    success: false,
                    message: err.extensions.response.body.detail[0].msg,
                    student: null,
                }
            }
        },
        // deletes a Student
        deleteStudent: async (_, { student_id }, { dataSources }) => {
            try {
                const res = await dataSources.studentAPI.deleteStudent(student_id);

                return {
                    code: 200,
                    success: true,
                    message: `Successfully deleted Student (${res.student_id})`,
                    student_id: res.student_id,
                }
            } catch (err) {
                return {
                    code: err.extensions.response.status,
                    success: false,
                    message: err.extensions.response.body.detail[0].msg,
                    student: null,
                }
            }
        }
    }
};

module.exports = resolvers;