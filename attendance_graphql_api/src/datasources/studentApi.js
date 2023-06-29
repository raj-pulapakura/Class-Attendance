const { RESTDataSource } = require("@apollo/datasource-rest");

class StudentAPI extends RESTDataSource {
    baseURL = "https://ogypedi8rh.execute-api.ap-southeast-2.amazonaws.com/dev/"

    // get list of all Students
    getStudents() {
        return this.get("students");
    }

    // get a Student by ID
    getStudent(student_id) {
        return this.get(`student/${student_id}`);
    }

    // add a new Student
    // the REST API only returns the student_id of the newly created Student
    // a GET request is made to fetch the entire student after the it has been created 
    async addStudent(first_name, last_name, primary_contact, secondary_contact) {
        const { student_id } = await this.post("student", {
            body: JSON.stringify({
                first_name: first_name,
                last_name: last_name,
                primary_contact: primary_contact,
                secondary_contact: secondary_contact,
            }),
            headers: {
                "Content-Type": "application/json"
            }
        });
        return this.getStudent(student_id);
    }

    // update an existing Student with all fields
    // the REST API returns the entire updated student
    updateStudent(student_id, first_name, last_name, primary_contact, secondary_contact) {
        return this.put("student", {
            body: JSON.stringify({
                student_id: student_id,
                first_name: first_name,
                last_name: last_name,
                primary_contact: primary_contact,
                secondary_contact: secondary_contact,
            }),
            headers: {
                "Content-Type": "application/json"
            }
        });
    }

    // deletes a Student
    // return the student_id of the deleted Student
    deleteStudent(student_id) {
        return this.delete(`student/${student_id}`);
    }
}

module.exports = StudentAPI;
