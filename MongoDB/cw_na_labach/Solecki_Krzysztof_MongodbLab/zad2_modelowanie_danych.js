use("mongodbLab_KS")

// Zadanie 2. Modelowanie danych.

db.getCollection('lecturers').insertOne(
{
    "_id": ObjectId(),
    "faculty": ["IET", "EAIIB", "WIMiR"],
    "degree": ["inż", "mgr", "dr", "prof"],
    "fname": "Jan",
    "lname": "Kowalski",
    "age": 39,
    "address": {
        "street": "Kwiatowa",
        "city": "Cracow",
        "country": "Poland",
        "zip": "30-901",
        "homeNumber": 121
    },
    "subjects": [
        {
            "subjectName": "Introduction to Computer Science",
            "role": "lecturer",
            "subjectID": ObjectId()
        },
        {
            "subjectName": "Algorithms and Data Structures",
            "role": "assistant",
            "subjectID": ObjectId()
        }
    ]
})


db.getCollection('students').insertOne(
{
    "_id": ObjectId(),
    "indexNumber": 403231,
    "semester": 4,
    "faculty": "IET",
    "fname": "Krzysztof",
    "lname": "Solecki",
    "age": 23,
    "address": {
        "street": "Kwiatkowa",
        "city": "Cracow",
        "country": "Poland",
        "zip": "30-901",
        "homeNumber": 121
    },
    "subjects": [
        {
            "subjectName": "Discrete Mathematics",
            "subjectID": ObjectId()
        },
        {
            "subjectName": "Algorithms and Data Structures",
            "subjectID": ObjectId()
        },
        {
            "subjectName": "Programming in C",
            "subjectID": ObjectId()
        }
    ],
    "grades": [
        {
            "subjectName:": "Discrete Mathematics",
            "subjectGrades": [5.0, 4.5, 4.0, 5.0, 4.0],
            "subjectID": ObjectId()
        },  
        { 
            "subjectName:": "Algorithms and Data Structures",
            "subjectGrades": [3.0, 4.5, 4.0, 5.0, 4.0],
            "subjectID": ObjectId()
        },
        {
            "subjectName:": "Programming in C",
            "subjectGrades": [5.0, 4.5, 4.0, 5.0, 4.0],
            "subjectID": ObjectId()
        }
    ]
}
)

db.getCollection('subjects').insertOne(
{
    "_id": ObjectId(),
    "name": "Discrete Mathematics",
    "fieldOfStudy": "Computer Science",
    "mandatory": "obligatory",
    "lectureLanguage": "Polish",
    "faculty": "IET",
    "form of verification": "exam",
    "numberOfHours": {
        "noLectures": 30,
        "noExercises": 30,
        "noLaboratories": 0
    },
    "assistant": {
        "name": "Jan Kowalski",
        "id": ObjectId()
    },
    "lecturers": [
    {
        "name": "Jan Kowalski",
        "id": ObjectId()
    }
    ],
    "literature": ["Discrete Mathematics", "Discrete Mathematics and its Applications"],
    "ECTS": "5",
    "goals": "The aim of the course is to introduce students to the basic concepts of discrete mathematics and to develop their skills in the use of these concepts in solving problems related to computer science.",
    "studyContent": "1. Set theory. 2. Relations and functions. 3. Combinatorics. 4. Graph theory. 5. Boolean algebra. 6. Logic. 7. Number theory.",
    "additionalInformation": "The course is a continuation of the course 'Introduction to Computer Science'.",
    "reviews": [
    {
        "studentID": ObjectId(),
        "studentName": "Krzysztof Solecki",
        "content": "Very interesting subject, I recommend it to everyone.",
    }
    ]
}
)

db.getCollection('lecturers').insertOne(
    {
        "_id": ObjectId(),
        "faculty": ["IET", "EAIIB"],
        "degree": ["inż", "mgr"],
        "fname": "Marian",
        "lname": "Nowak",
        "age": 43,
        "address": {
            "street": "Pszczelna",
            "city": "Cracow",
            "country": "Poland",
            "zip": "30-920",
            "homeNumber": 124
        },
        "subjects": [
            {
                "subjectName": "Haskell Programming",
                "role": "assistant",
                "subjectID": ObjectId()
            },
            {
                "subjectName": "Advanced Machine Learning",
                "role": "assistant",
                "subjectID": ObjectId()
            }
        ]
    })

db.getCollection('lecturers').insertOne(
    {
        "_id": ObjectId(),
        "faculty": ["IET", "EAIIB"],
        "degree": ["inż", "mgr", "dr"],
        "fname": "Faustyna",
        "lname": "Kowalska",
        "age": 41,
        "address": {
            "street": "Opolska",
            "city": "Cracow",
            "country": "Poland",
            "zip": "30-920",
            "homeNumber": 23
        },
        "subjects": [
            {
                "subjectName": "Numerical Methods",
                "role": "lecturer",
                "subjectID": ObjectId()
            },
            {
                "subjectName": "Probability Theory and Statistics",
                "role": "assistant",
                "subjectID": ObjectId()
            },
            {
                "subjectName": "Operating Systems",
                "role": "assistant",
                "subjectID": ObjectId()
            }
        ]
    })

db.getCollection('students').insertOne(
{
    "_id": ObjectId(),
    "indexNumber": 402122,
    "semester": 4,
    "faculty": "IET",
    "fname": "Bartosz",
    "lname": "Walczak",
    "age": 22,
    "address": {
        "street": "Akacjowa",
        "city": "Cracow",
        "country": "Poland",
        "zip": "30-901",
        "homeNumber": 23
    },
    "subjects": [
        {
            "subjectName": "Operating Systems",
            "subjectID": ObjectId()
        },
        {
            "subjectName": "Numerical Methods",
            "subjectID": ObjectId()
        },
        {
            "subjectName": "Automata and Formal Languages",
            "subjectID": ObjectId()
        }
    ],
    "grades": [
        {
            "subjectName:": "Operating Systems",
            "subjectGrades": [3.0, 3.5, 4.0, 5.0, 4.0],
            "subjectID": ObjectId()
        },  
        { 
            "subjectName:": "Numerical Methods",
            "subjectGrades": [3.0, 4.5, 4.0, 5.0, 4.0],
            "subjectID": ObjectId()
        },
        {
            "subjectName:": "Automata and Formal Languages",
            "subjectGrades": [4.0, 2.0, 4.0, 5.0, 4.0],
            "subjectID": ObjectId()
        }
    ]
}
)

db.getCollection('students').insertOne(
    {
        "_id": ObjectId(),
        "indexNumber": 408122,
        "semester": 1,
        "faculty": "IET",
        "fname": "Anna",
        "lname": "Rogowska",
        "age": 21,
        "address": {
            "street": "Głogowska",
            "city": "Cracow",
            "country": "Poland",
            "zip": "30-901",
            "homeNumber": 244
        },
        "subjects": [
            {
                "subjectName": "Algebra",
                "subjectID": ObjectId()
            },
            {
                "subjectName": "Introduction to Computer Science",
                "subjectID": ObjectId()
            },
            {
                "subjectName": "Interpersonal Communication",
                "subjectID": ObjectId()
            }
        ],
        "grades": [
            {
                "subjectName:": "Algebra",
                "subjectGrades": [3.0, 3.5, 4.0, 5.0, 4.0],
                "subjectID": ObjectId()
            },  
            { 
                "subjectName:": "Introduction to Computer Science",
                "subjectGrades": [3.0, 4.5, 4.0, 5.0, 4.0],
                "subjectID": ObjectId()
            },
            {
                "subjectName:": "Interpersonal Communication",
                "subjectGrades": [4.0, 2.0, 4.0, 5.0, 4.0],
                "subjectID": ObjectId()
            }
        ]
    }
)
    
db.getCollection('subjects').insertOne(
    {
        "_id": ObjectId(),
        "name": "Algorithms and Data Structures",
        "fieldOfStudy": "Computer Science",
        "mandatory": "obligatory",
        "lectureLanguage": "Polish",
        "faculty": "IET",
        "form of verification": "exam",
        "numberOfHours": {
            "noLectures": 30,
            "noExercises": 30,
            "noLaboratories": 0
        },
        "assistant": {
            "name": "Piotr Horban",
            "id": ObjectId()
        },
        "lecturers": [
        {
            "name": "Daniel Lewandowski",
            "id": ObjectId()
        }
        ],
        "literature": ["Cormen, Leiserson, Rivest, Stein: Introduction to Algorithms, MIT Press, 2009", "T. H. Cormen, C. E. Leiserson, R. L. Rivest, C. Stein: Wprowadzenie do algorytmów, Wydawnictwo Naukowo-Techniczne, 2001"],
        "ECTS": "6",
        "goals": "The aim of the course is to acquaint students with the basic algorithms and data structures used in computer science. The course is a continuation of the course Introduction to Computer Science.",
        "reviews": [
        {
            "studentID": ObjectId(),
            "studentName": "Bartosz Walczak",
            "content": "Hard but interesting subject. I recommend it to everyone who wants to learn something about algorithms and data structures.",
        }
        ]
    }
)
    
db.getCollection('subjects').insertOne(
    {
        "_id": ObjectId(),
        "name": "Haskell Programming",
        "fieldOfStudy": "Computer Science",
        "mandatory": "elective",
        "lectureLanguage": "English",
        "faculty": "WIMiR",
        "form of verification": "assessment",
        "numberOfHours": {
            "noLectures": 14,
            "noExercises": 0,
            "noLaboratories": 30
        },
        "assistant": {
            "name": "Szymon Chojnacki",
            "id": ObjectId()
        },
        "lecturers": [
        {
            "name": "Urszula Kaczmarek",
            "id": ObjectId()
        }
        ],
        "literature": ["Graham Hutton: Programming in Haskell, Cambridge University Press, 2007", "Graham Hutton: Programowanie w Haskellu, Helion, 2016"],
        "ECTS": "3",
        "goals": "The aim of the course is to aquire knowledge about functional programming in Haskell language. The course is a continuation of the course Introduction to Computer Science.",
        "reviews": [
        {
            "studentID": ObjectId(),
            "studentName": "Anna Rogowska",
            "content": "Boredom. I don't recommend it to anyone.",
        }
        ]
    }
    )


// Operacje na kolekcjach

// Zapis studenta na przedmiot

db.getCollection('students').updateOne(
    {
        "indexNumber": 408122,
    },
    {
        $push: {
            "subjects": {
                "subjectName": "Haskell Programming",
                "subjectID": ObjectId()
            }
        }
    }
)

db.getCollection('students').updateOne(
    {
        "indexNumber": 408122,
    },
    {
        $push: {
            "grades": {
                "subjectName:": "Haskell Programming",
                "subjectGrades": [3.0, 4.5, 4.0, 5.0, 4.0],
                "subjectID": ObjectId()
            }
        }
    }
)

// Przyznanie prowadzenia zajęć danemu prowadzącemu.

db.getCollection('subjects').updateOne(
    {
        "name": "Haskell Programming",
    },
    {
        $push: {
            "lecturers": {
                "name": "Urszula Kaczmarek",
                "id": ObjectId()
            }
        }
    }
)

// Dodanie oceny do przedmiotu

db.getCollection('subjects').updateOne(
    {
        "name": "Haskell Programming",
    },
    {
        $push: {
            "reviews": {
                "studentID": ObjectId(),
                "studentName": "Anna Rogowska",
                "content": "Boredom. I don't recommend it to anyone.",
            }
        }
    }
)

// Przyznanie koordynowania zajęć danemu prowadzącemu.

db.getCollection('subjects').updateOne(
    {
        "name": "Haskell Programming",
    },
    {
        $set: {
            "assistant": {
                "name": "Szymon Chojnacki",
                "id": ObjectId()
            }
        }
    }
)

// Wykładowca wystawia ocenę studentowi

db.getCollection('students').updateOne(
    {
        "indexNumber": 408122,
        "grades.subjectName": "Algebra"
    },
    {
        $push: {
            "grades.$.subjectGrades": 4.5
        }
    }
)

// Ocena przedmiotu przez studenta

db.getCollection('subjects').updateOne(
    (
        { "name": "Discrete Mathematics", "faculty": "IET" }
    ),
    {
        $push: {
            "reviews": {
                "studentID": ObjectId(),
                "studentName": "Bartosz Walczak",
                "content": "Interesting and useful subject."
            }
        }
    }
)
