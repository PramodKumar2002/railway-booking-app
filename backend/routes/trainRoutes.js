const express = require('express');
const router = express.Router();
const Train = require('../models/Train');
const { isClusterConnected } = require('../db');

// Master curated Indian Railway train list
const DEFAULT_TRAINS = [
  {
    trainNumber: '12952',
    trainName: 'Mumbai Rajdhani Express',
    source: 'New Delhi (NDLS)',
    destination: 'Mumbai Central (MMCT)',
    departureTime: '16:55',
    arrivalTime: '08:35',
    duration: '15h 40m',
    runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 18, fare: 4850 },
      { className: '2AC', availableSeats: 42, fare: 2980 },
      { className: '3AC', availableSeats: 96, fare: 2150 },
      { className: 'SL', availableSeats: 120, fare: 820 },
    ],
  },
  {
    trainNumber: '12951',
    trainName: 'Mumbai Rajdhani Express',
    source: 'Mumbai Central (MMCT)',
    destination: 'New Delhi (NDLS)',
    departureTime: '17:00',
    arrivalTime: '08:32',
    duration: '15h 32m',
    runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 14, fare: 4850 },
      { className: '2AC', availableSeats: 38, fare: 2980 },
      { className: '3AC', availableSeats: 85, fare: 2150 },
      { className: 'SL', availableSeats: 110, fare: 820 },
    ],
  },
  {
    trainNumber: '22436',
    trainName: 'Vande Bharat Express',
    source: 'New Delhi (NDLS)',
    destination: 'Varanasi Junction (BSB)',
    departureTime: '06:00',
    arrivalTime: '14:00',
    duration: '8h 00m',
    runsOn: ['Tue', 'Wed', 'Fri', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 26, fare: 3350 },
      { className: '2AC', availableSeats: 58, fare: 2280 },
      { className: '3AC', availableSeats: 110, fare: 1750 },
      { className: 'SL', availableSeats: 0, fare: 750 },
    ],
  },
  {
    trainNumber: '22435',
    trainName: 'Vande Bharat Express',
    source: 'Varanasi Junction (BSB)',
    destination: 'New Delhi (NDLS)',
    departureTime: '15:00',
    arrivalTime: '23:00',
    duration: '8h 00m',
    runsOn: ['Tue', 'Wed', 'Fri', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 30, fare: 3350 },
      { className: '2AC', availableSeats: 64, fare: 2280 },
      { className: '3AC', availableSeats: 115, fare: 1750 },
      { className: 'SL', availableSeats: 0, fare: 750 },
    ],
  },
  {
    trainNumber: '12002',
    trainName: 'Bhopal Shatabdi Express',
    source: 'New Delhi (NDLS)',
    destination: 'Bhopal Junction (BPL)',
    departureTime: '06:00',
    arrivalTime: '14:40',
    duration: '8h 40m',
    runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 22, fare: 2620 },
      { className: '2AC', availableSeats: 48, fare: 1850 },
      { className: '3AC', availableSeats: 74, fare: 1290 },
      { className: 'SL', availableSeats: 130, fare: 520 },
    ],
  },
  {
    trainNumber: '12626',
    trainName: 'Kerala Superfast Express',
    source: 'New Delhi (NDLS)',
    destination: 'Thiruvananthapuram (TVC)',
    departureTime: '20:10',
    arrivalTime: '14:35',
    duration: '42h 25m',
    runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 12, fare: 5600 },
      { className: '2AC', availableSeats: 36, fare: 3450 },
      { className: '3AC', availableSeats: 88, fare: 2380 },
      { className: 'SL', availableSeats: 160, fare: 920 },
    ],
  },
  {
    trainNumber: '12301',
    trainName: 'Howrah Rajdhani Express',
    source: 'Howrah (HWH)',
    destination: 'New Delhi (NDLS)',
    departureTime: '16:50',
    arrivalTime: '10:05',
    duration: '17h 15m',
    runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    classes: [
      { className: '1AC', availableSeats: 16, fare: 4720 },
      { className: '2AC', availableSeats: 44, fare: 2890 },
      { className: '3AC', availableSeats: 102, fare: 2080 },
      { className: 'SL', availableSeats: 140, fare: 790 },
    ],
  },
  {
    trainNumber: '12302',
    trainName: 'Kolkata Rajdhani Express',
    source: 'New Delhi (NDLS)',
    destination: 'Howrah (HWH)',
    departureTime: '16:55',
    arrivalTime: '09:55',
    duration: '17h 00m',
    runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 18, fare: 4720 },
      { className: '2AC', availableSeats: 50, fare: 2890 },
      { className: '3AC', availableSeats: 98, fare: 2080 },
      { className: 'SL', availableSeats: 150, fare: 790 },
    ],
  },
  {
    trainNumber: '12621',
    trainName: 'Tamil Nadu Express',
    source: 'Chennai Central (MAS)',
    destination: 'New Delhi (NDLS)',
    departureTime: '22:00',
    arrivalTime: '06:30',
    duration: '32h 30m',
    runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 10, fare: 5200 },
      { className: '2AC', availableSeats: 32, fare: 3120 },
      { className: '3AC', availableSeats: 76, fare: 2190 },
      { className: 'SL', availableSeats: 135, fare: 840 },
    ],
  },
  {
    trainNumber: '12622',
    trainName: 'Tamil Nadu Express',
    source: 'New Delhi (NDLS)',
    destination: 'Chennai Central (MAS)',
    departureTime: '21:05',
    arrivalTime: '06:15',
    duration: '33h 10m',
    runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 12, fare: 5200 },
      { className: '2AC', availableSeats: 30, fare: 3120 },
      { className: '3AC', availableSeats: 82, fare: 2190 },
      { className: 'SL', availableSeats: 140, fare: 840 },
    ],
  },
  {
    trainNumber: '12677',
    trainName: 'Ernakulam InterCity SF Express',
    source: 'Bengaluru City (SBC)',
    destination: 'Ernakulam Junction (ERS)',
    departureTime: '06:10',
    arrivalTime: '16:55',
    duration: '10h 45m',
    runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 0, fare: 1980 },
      { className: '2AC', availableSeats: 28, fare: 1420 },
      { className: '3AC', availableSeats: 64, fare: 990 },
      { className: 'SL', availableSeats: 180, fare: 360 },
    ],
  },
  {
    trainNumber: '12007',
    trainName: 'Mysuru Shatabdi Express',
    source: 'Chennai Central (MAS)',
    destination: 'Bengaluru City (SBC)',
    departureTime: '06:00',
    arrivalTime: '10:55',
    duration: '4h 55m',
    runsOn: ['Mon', 'Tue', 'Wed', 'Fri', 'Sat', 'Sun'],
    classes: [
      { className: '1AC', availableSeats: 25, fare: 1850 },
      { className: '2AC', availableSeats: 60, fare: 1350 },
      { className: '3AC', availableSeats: 92, fare: 980 },
      { className: 'SL', availableSeats: 0, fare: 410 },
    ],
  },
];

const STATIONS = [
  'New Delhi (NDLS)',
  'Mumbai Central (MMCT)',
  'Bengaluru City (SBC)',
  'Chennai Central (MAS)',
  'Howrah (HWH)',
  'Varanasi Junction (BSB)',
  'Bhopal Junction (BPL)',
  'Ahmedabad Junction (ADI)',
  'Pune Junction (PUNE)',
  'Jaipur Junction (JP)',
  'Hyderabad Deccan (HYB)',
  'Thiruvananthapuram (TVC)',
  'Ernakulam Junction (ERS)',
];

// Helper: normalize string for fuzzy search
function clean(str) {
  return (str || '')
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '');
}

// Seed trains into database if empty
async function seedTrainsIfNeeded() {
  if (isClusterConnected()) {
    try {
      const count = await Train.countDocuments();
      if (count === 0) {
        await Train.insertMany(DEFAULT_TRAINS);
        console.log(`[CLUSTER] Seeded ${DEFAULT_TRAINS.length} trains into MongoDB.`);
      }
    } catch (err) {
      console.warn('Could not seed trains to cluster:', err.message);
    }
  }
}

// Ensure seeding on start
seedTrainsIfNeeded();

// GET /api/trains/stations
router.get('/stations', (req, res) => {
  return res.status(200).json({
    success: true,
    stations: STATIONS,
  });
});

// GET /api/trains/search
router.get('/search', async (req, res) => {
  try {
    const { source, destination, date, class: travelClass } = req.query;

    let allTrains = DEFAULT_TRAINS;
    if (isClusterConnected()) {
      try {
        const dbTrains = await Train.find();
        if (dbTrains && dbTrains.length > 0) {
          allTrains = dbTrains;
        }
      } catch (e) {
        allTrains = DEFAULT_TRAINS;
      }
    }

    if (!source && !destination) {
      return res.status(200).json({
        success: true,
        count: allTrains.length,
        trains: allTrains,
      });
    }

    const cleanSource = clean(source);
    const cleanDest = clean(destination);

    let matching = allTrains.filter((t) => {
      const tSrc = clean(t.source);
      const tDst = clean(t.destination);

      const matchesSource = !cleanSource || tSrc.includes(cleanSource) || cleanSource.includes(tSrc);
      const matchesDest = !cleanDest || tDst.includes(cleanDest) || cleanDest.includes(tDst);

      return matchesSource && matchesDest;
    });

    // If no direct matching train in fixed list, generate dynamic schedule for the requested route
    if (matching.length === 0 && source && destination) {
      const generatedTrains = [
        {
          trainNumber: '1' + Math.floor(2000 + Math.random() * 8000),
          trainName: `${source.split(' ')[0]} - ${destination.split(' ')[0]} Express`,
          source: source.trim(),
          destination: destination.trim(),
          departureTime: '07:15',
          arrivalTime: '19:45',
          duration: '12h 30m',
          runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          classes: [
            { className: '1AC', availableSeats: 22, fare: 3850 },
            { className: '2AC', availableSeats: 48, fare: 2450 },
            { className: '3AC', availableSeats: 94, fare: 1650 },
            { className: 'SL', availableSeats: 120, fare: 620 },
          ],
        },
        {
          trainNumber: '2' + Math.floor(1000 + Math.random() * 8000),
          trainName: `${source.split(' ')[0]} Superfast Special`,
          source: source.trim(),
          destination: destination.trim(),
          departureTime: '17:30',
          arrivalTime: '06:00',
          duration: '12h 30m',
          runsOn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          classes: [
            { className: '1AC', availableSeats: 16, fare: 4100 },
            { className: '2AC', availableSeats: 34, fare: 2600 },
            { className: '3AC', availableSeats: 82, fare: 1780 },
            { className: 'SL', availableSeats: 95, fare: 690 },
          ],
        },
      ];
      matching = generatedTrains;
    }

    return res.status(200).json({
      success: true,
      count: matching.length,
      trains: matching,
      query: { source, destination, date, travelClass },
    });
  } catch (error) {
    console.error('Error in train search:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to search trains: ' + error.message,
    });
  }
});

// GET /api/trains/:trainNumber
router.get('/:trainNumber', async (req, res) => {
  try {
    const { trainNumber } = req.params;
    let train = null;
    if (isClusterConnected()) {
      train = await Train.findOne({ trainNumber });
    }
    if (!train) {
      train = DEFAULT_TRAINS.find((t) => t.trainNumber === trainNumber);
    }

    if (!train) {
      return res.status(404).json({
        success: false,
        message: `Train ${trainNumber} not found.`,
      });
    }

    return res.status(200).json({
      success: true,
      train,
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
