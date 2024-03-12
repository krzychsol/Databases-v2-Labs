use('yelp')

// Zadanie 1. Operacje wyszukiwania danych.

// a)
db.getCollection('business').find(
    {
        'categories': { $elemMatch: { $eq: 'Restaurants' } },
        'hours.Monday': { $exists: true },
        'stars': { $gte: 4 }
    },
    {
        'name': true,
        'full_address': true,
        'categories': true,
        'hours': true,
        'stars': true
    },
    {
        sort: [ 'name' ]
    }
);

// b)
db.getCollection('business').aggregate(
    [
        { $match: { 'categories': {
            $in: [ 'Hotels & Travel', 'Hotels' ]
        } } },
        { $group: {
            '_id': '$city',
            'hotel_count': { $count: {} }
        } },
        { $sort: { 'hotel_count': -1 } }
    ]
);

// c)
db.getCollection('tip').aggregate([
    { $match: { 'date': { $regex: /^2012/ } } },
    { $group: {
        '_id': '$business_id',
        'tip_count': { $count: {} }
    } },
    {
        $lookup: {
            from: 'business',
            localField: '_id',
            foreignField: 'business_id',
            as: 'business'
        }
    },
    { $sort: { 'tip_count': -1 } },
    {
        $project: {
            'business_name': { $first: '$business.name' },
            'tip_count': 1
        }
    }
]);


// d)
db.getCollection('review').aggregate([
    { 
        $project: {
            'votes': { $objectToArray: '$votes' }
        }
    },
    { $unwind: '$votes' },
    { $match: { 'votes.v': { $gt: 0 } } },
    {
        $group: {
            '_id': '$votes.k',
            'count': { $count: {} },
            'total': { $sum: '$votes.v' }
        }
    }
]);


// e)
db.getCollection('user').aggregate([
    {
        $match: {
            'votes.funny': 0,
            'votes.useful': 0,
            'type': 'user'
        }
    },
    { $sort: { 'name': 1 } }
]);


// f)
//przypadek 1
db.getCollection('review').aggregate([
    {
        $group: {
            '_id': '$business_id',
            'stars_mean': { $avg: '$stars' }
        }
    },
    { $match: { 'stars_mean': { $gt: 3 } } },
    { $sort: { '_id': 1 } },
]);


//przypadek 2
db.getCollection('review').aggregate([
    {
        $group: {
            '_id': '$business_id',
            'stars_mean': { $avg: '$stars' }
        }
    },
    { $match: { 'stars_mean': { $gt: 3 } } },
    {
        $lookup: {
            from: 'business',
            localField: '_id',
            foreignField: 'business_id',
            pipeline: [{ $group: { '_id': '$name' } }],
            as: 'business'
        }
    },
    {
        $project: {
            '_id': 0,
            'business_name': { $first: '$business._id' },
            'stars_mean': 1
        }
    },
    { $sort: { 'business_name': 1 } }
]);




