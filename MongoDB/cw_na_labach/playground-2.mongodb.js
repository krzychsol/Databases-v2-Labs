// 5. OPERACJE CRUD

// stwórz nową bazę danych, jako nazwy bazy danych użyj swoich inicjałów
const database = 'KS';
use(database);

/*
stwórz kolekcję "student"
o informacje o studentach, przedmiotach ocenach z przedmiotów itp.
o zaproponuj strukturę dokumentu
o wykorzystaj typy proste/podstawowe, dokumenty zagnieżdżone, tablice itp.
*/

const collection = 'student';

//wprowadź kilka przykładowych dokumentów 
db.student.insertMany([
    {
      "firstName": "Adam",
      "lastName": "Nowakowski",
      "age": 22,
      "gender": "M",
      "major": "Ekonomia",
      "enrollmentYear": 2019,
      "courses": [
        {
          "name": "Mikroekonomia",
          "code": "ECO101",
          "grade": "B+"
        },
        {
          "name": "Statystyka ekonomiczna",
          "code": "ECO202",
          "grade": "A"
        }
      ],
      "address": {
        "street": "ul. Gospodarcza 15",
        "city": "Gdańsk",
        "country": "Polska"
      },
      "contact": {
        "email": "adam.nowakowski@example.com",
        "phone": "+48 987654321"
      }
    },
    {
      "firstName": "Maria",
      "lastName": "Wójcik",
      "age": 23,
      "gender": "F",
      "major": "Historia",
      "enrollmentYear": 2018,
      "courses": [
        {
          "name": "Historia Polski",
          "code": "HIS101",
          "grade": "A-"
        },
        {
          "name": "Historia Europy",
          "code": "HIS201",
          "grade": "B"
        }
      ],
      "address": {
        "street": "ul. Historyczna 8",
        "city": "Poznań",
        "country": "Polska"
      },
      "contact": {
        "email": "maria.wojcik@example.com",
        "phone": "+48 555444333"
      }
    },
    {
      "firstName": "Piotr",
      "lastName": "Jankowski",
      "age": 20,
      "gender": "M",
      "major": "Medycyna",
      "enrollmentYear": 2021,
      "courses": [
        {
          "name": "Anatomia",
          "code": "MED101",
          "grade": "A"
        },
        {
          "name": "Biochemia",
          "code": "MED202",
          "grade": "B"
        }
      ],
      "address": {
        "street": "ul. Medyczna 3",
        "city": "Wrocław",
        "country": "Polska"
      },
      "contact": {
        "email": "piotr.jankowski@example.com",
        "phone": "+48 777888999"
      }
    },
    {
      "firstName": "Katarzyna",
      "lastName": "Kowalczyk",
      "age": 22,
      "gender": "F",
      "major": "Socjologia",
      "enrollmentYear": 2019,
      "courses": [
        {
          "name": "Podstawy socjologii",
          "code": "SOC101",
          "grade": "B+"
        },
        {
          "name": "Metody badawcze",
          "code": "SOC202",
          "grade": "A-"
        }
      ],
      "address": {
        "street": "ul. Krakowska 13",
        "city": "Kraków",
        "country": "Polska"
      },
      "contact": {
        "email": "katarzyna.kowalczyk@example.com",
        "phone": "+48 888888999"
      }
    }
])

//Dodanie pojedynczego dokumentu
db.student.insertOne({
    "firstName": "Marta",
    "lastName": "Nowicka",
    "age": 21,
    "gender": "F",
    "major": "Matematyka",
    "enrollmentYear": 2022,
    "courses": [
      {
        "name": "Analiza matematyczna",
        "code": "MAT101",
        "grade": "A"
      },
      {
        "name": "Algebra liniowa",
        "code": "MAT201",
        "grade": "A-"
      }
    ],
    "address": {
      "street": "ul. Matematyczna 5",
      "city": "Kraków",
      "country": "Polska"
    },
    "contact": {
      "email": "marta.nowicka@example.com",
      "phone": "+48 777111222"
    }
  })
  
//Modyfikacja dokumentu
db.student.updateOne(
    { "firstName": "Adam" },
    { $set: { "lastName": "Nowak" } }
  )

//Usunięcie dokumentu
db.student.deleteOne({ "firstName": "Adam" })


//Wyszukiwanie dokumentów

// Znalezienie wszystkich studentów
db.student.find()

// Znalezienie studenta o nazwisku "Jankowski"
db.student.find({ "lastName": "Jankowski" })

// Znalezienie studentów z oceną "A" w kursie "Analiza Matematyczna"
db.student.find({ "courses": { $elemMatch: { "name": "Analiza matematyczna", "grade": "A" } } })
