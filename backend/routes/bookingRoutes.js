const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const { isClusterConnected, loadFallbackData, saveFallbackData } = require('../db');

// Helper to generate real 10-digit PNR
function generatePnr() {
  const prefix = Math.floor(200 + Math.random() * 700).toString(); // e.g. 234, 456, 891
  const rest = Math.floor(1000000 + Math.random() * 9000000).toString(); // 7 digits
  return prefix + rest;
}

// POST /api/bookings - Create ticket booking
router.post('/', async (req, res) => {
  try {
    const {
      userId,
      userEmail,
      trainNumber,
      trainName,
      source,
      destination,
      journeyDate,
      travelClass,
      passengers,
      contactEmail,
      contactPhone,
      farePerPassenger,
    } = req.body;

    // Validation
    if (!trainNumber || !trainName || !source || !destination || !journeyDate || !travelClass) {
      return res.status(400).json({
        success: false,
        message: 'Missing required journey or train details.',
      });
    }

    if (!Array.isArray(passengers) || passengers.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'At least one passenger must be provided.',
      });
    }

    for (let i = 0; i < passengers.length; i++) {
      const p = passengers[i];
      if (!p.name || !p.age || !p.gender) {
        return res.status(400).json({
          success: false,
          message: `Passenger #${i + 1} is missing name, age, or gender.`,
        });
      }
    }

    if (!contactEmail || !contactPhone) {
      return res.status(400).json({
        success: false,
        message: 'Contact email and mobile number are required.',
      });
    }

    const passengerCount = passengers.length;
    const unitFare = Number(farePerPassenger) || 850;
    const totalFare = unitFare * passengerCount;
    const pnr = generatePnr();

    const bookingData = {
      pnr,
      userId: userId || 'usr_guest',
      userEmail: (userEmail || contactEmail).trim().toLowerCase(),
      trainNumber,
      trainName,
      source,
      destination,
      journeyDate,
      travelClass,
      passengers,
      contactEmail: contactEmail.trim().toLowerCase(),
      contactPhone: contactPhone.trim(),
      farePerPassenger: unitFare,
      passengerCount,
      totalFare,
      status: 'CONFIRMED',
      paymentStatus: 'SIMULATED', // Payment simulation; in real deployment, gateway integration
      createdAt: new Date(),
    };

    let savedBooking = null;

    if (isClusterConnected()) {
      savedBooking = await Booking.create(bookingData);
      console.log(`[CLUSTER] Booking confirmed & saved! PNR: ${pnr}, User: ${bookingData.userEmail}`);
    } else {
      const db = loadFallbackData();
      if (!db.bookings) db.bookings = [];
      bookingData._id = 'bk_' + Date.now();
      db.bookings.push(bookingData);
      saveFallbackData(db);
      savedBooking = bookingData;
      console.log(`[LOCAL STORE] Booking confirmed & saved! PNR: ${pnr}`);
    }

    return res.status(201).json({
      success: true,
      message: 'Booking confirmed successfully! Your ticket has been saved to the database.',
      pnr,
      booking: savedBooking,
    });
  } catch (error) {
    console.error('Error creating booking:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error while processing booking: ' + error.message,
    });
  }
});

// GET /api/bookings/my-bookings
router.get('/my-bookings', async (req, res) => {
  try {
    const { email, userId } = req.query;

    let queryFilter = {};
    if (email) {
      queryFilter.userEmail = email.trim().toLowerCase();
    } else if (userId) {
      queryFilter.userId = userId;
    }

    let bookings = [];

    if (isClusterConnected()) {
      bookings = await Booking.find(queryFilter).sort({ createdAt: -1 });
    } else {
      const db = loadFallbackData();
      bookings = (db.bookings || []).filter((b) => {
        if (email && b.userEmail !== email.trim().toLowerCase()) return false;
        if (userId && b.userId !== userId) return false;
        return true;
      });
      bookings.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    }

    return res.status(200).json({
      success: true,
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    console.error('Error fetching bookings:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error while fetching bookings: ' + error.message,
    });
  }
});

// GET /api/bookings/pnr/:pnr
router.get('/pnr/:pnr', async (req, res) => {
  try {
    const { pnr } = req.params;
    let booking = null;

    if (isClusterConnected()) {
      booking = await Booking.findOne({ pnr });
    } else {
      const db = loadFallbackData();
      booking = (db.bookings || []).find((b) => b.pnr === pnr);
    }

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: `No booking found for PNR: ${pnr}`,
      });
    }

    return res.status(200).json({
      success: true,
      booking,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;
