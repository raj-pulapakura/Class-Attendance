from fastapi import FastAPI
from utils import gen_primary_key
from features.student import get_student_table, StudentItem
from mangum import Mangum

# create app
app = FastAPI()
handler = Mangum(app)

# get access to Student table
table = get_student_table()

# validation route
@app.get("/")
async def root():
    return {
        "message": "success"
    }

# get a single student by id
@app.get("/student/{student_id}")
async def get_student(student_id: str):
    response = table.get_item(Key={"student_id": str(student_id)})
    return response["Item"]

# get all students
@app.get("/students")
async def get_students():
    response = table.scan()
    return response['Items']

# create a student
@app.post("/student")
async def add_student(item: StudentItem):
    student_id = gen_primary_key()
    table.put_item(
        Item={
            "student_id": student_id,
            "first_name": item.first_name,
            "last_name": item.last_name,
            "primary_contact": item.primary_contact,
            "secondary_contact": item.secondary_contact
        }
    )
    return {
        "student_id": student_id
    }

# delete a student by id
@app.delete("/student/{student_id}")
async def delete_student(student_id: str):
    table.delete_item(
        Key={
            "student_id": student_id
        }
    )
    return {
        "student_id": student_id
    }

# update a student
@app.put("/student")
async def update_student(item: StudentItem):
    response = table.update_item(
        Key={
            "student_id": item.student_id
        },
        UpdateExpression="SET first_name=:first_name, last_name=:last_name, primary_contact=:primary_contact, secondary_contact=:secondary_contact",
        ExpressionAttributeValues={
            ":first_name": item.first_name,
            ":last_name": item.last_name,
            ":primary_contact": item.primary_contact,
            ":secondary_contact": item.secondary_contact,
        },
        ReturnValues="UPDATED_NEW"
    )
    return {
        **response["Attributes"],
        "student_id": item.student_id
    }