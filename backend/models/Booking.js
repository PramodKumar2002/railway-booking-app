const mongoose = require('mongoose');

const passengerSchema = new mongoose.Schema({
  name: { type: String, required: true },
  age: { type: Number, required: true },
  gender: { type: String, required: true },
});

const bookingSchema = new mongoose.Schema({
  pnr: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  userId: {
    type: String,
    required: false,
  },
  userEmail: {
    type: String,
    required: true,
    trim: true,
  },
  trainNumber: {
    type: String,
    required: true,
  },
  trainName: {
    type: String,
    required: true,
  },
  source: {
    type: String,
    required: true,
  },
  destination: {
    type: String,
    required: true,
  },
  journeyDate: {
    type: String,
    required: true,
  },
  travelClass: {
    type: String,
    required: true,
  },
  passengers: [passengerSchema],
  contactEmail: {
    type: String,
    required: true,
  },
  contactPhone: {
    type: String,
    required: true,
  },
  farePerPassenger: {
    type: Number,
    required: true,
  },
  passengerCount: {
    type: Number,
    required: true,
  },
  totalFare: {
    type: Number,
    required: true,
  },
  status: {
    type: String,
    enum: ['CONFIRMED', 'WAITLISTED', 'CANCELLED'],
    default: 'CONFIRMED',
  },
  paymentStatus: {
    type: String,
    enum: ['PENDING_COUNTER', 'PAID', 'SIMULATED'],
    default: 'PENDING_COUNTER',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Booking', bookingSchema);
