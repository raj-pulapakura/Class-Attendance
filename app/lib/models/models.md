# App models

In this app we will need three models:

- User: A user of the app.
- Class: A class is a group of students. A class will have a separate attendance record from other classes.
- Student: It's a student.

## User

Fields:

- `id`: unique identifier, most likely an email address
- `classes`: a list of classes (ids)
- `students`: a list of students (ids)

## Class

Fields:

- `id`: unique identifier
- `name`: display name for the class
- `students`: a list of ids which correspond to the students in the class, e.g. `[]`

## Student

Fields:

- `id`: unique identifier
- `class`: identifier of the class that the student belongs to, can be null
- `firstName`: first name
- `lastName`: last name, can be null
- `standard`: grade/year, e.g. 10, can be null
- `phone`: contact number, can be null
- `email`: email address, can be null
- `imgURL`: link to a picture of the student (firebase storage), can be null
