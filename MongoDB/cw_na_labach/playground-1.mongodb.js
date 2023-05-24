//2. Stwórz bazę danych/kolekcję/dokument

const database = 'restaurant';
const collection = 'food';

// Create a new database.
use(database);

db.food.insertMany(
    [{
        "part": "lunch",
        "foodEaten": [
        {
         "foodName": "screambled eggs", 
         "serving": 2,
         "caloriesPerServe": 360,
         "proteinsPerServe": 34
        }, 
        {
         "foodName": "pancakes", 
         "serving": 3,
         "caloriesPerServe": 367,
         "proteinsPerServe": 19
        },
        {
         "foodName": "sausages with beacon", 
         "serving": 3,
         "caloriesPerServe": 512,
         "proteinsPerServe": 11
        }
        ]
     },
     {
        "part": "dinner",
        "foodEaten": [
        {
         "foodName": "chicken soup", 
         "serving": 2,
         "caloriesPerServe": 100,
         "proteinsPerServe": 4
        }, 
        {
         "foodName": "sushi", 
         "serving": 3,
         "caloriesPerServe": 430,
         "proteinsPerServe": 40
        }
        ]
     }]

)
