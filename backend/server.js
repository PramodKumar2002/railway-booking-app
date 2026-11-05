require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { connectDB } = require('./db');
const authRoutes = require('./routes/authRoutes');
const trainRoutes = require('./routes/trainRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const contactRoutes = require('./routes/contactRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS for all incoming Flutter web, mobile, and desktop requests
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());

// Request logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.url}`);
  next();
});

// Mount Routes
app.use('/api/auth', authRoutes);
app.use('/api/trains', trainRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/contact', contactRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'Railway App Backend API is active',
    version: '1.0.0',
    endpoints: {
      auth: {
        sendOtp: 'POST /api/auth/send-otp',
        verifyOtp: 'POST /api/auth/verify-otp',
        resendOtp: 'POST /api/auth/resend-otp',
        login: 'POST /api/auth/login',
        status: 'GET /api/auth/status',
      },
      trains: {
        search: 'GET /api/trains/search?source=&destination=&date=&class=',
        stations: 'GET /api/trains/stations',
        details: 'GET /api/trains/:trainNumber',
      },
      bookings: {
        create: 'POST /api/bookings',
        myBookings: 'GET /api/bookings/my-bookings?email=',
        pnr: 'GET /api/bookings/pnr/:pnr',
      },
      contact: {
        submit: 'POST /api/contact',
      },
    },
  });
});

// Start Server
app.listen(PORT, async () => {
  console.log(`========================================`);
  console.log(`🚀 Railway App Backend Server running!`);
  console.log(`📡 URL: http://localhost:${PORT}`);
  console.log(`========================================`);

  // Connect to MongoDB Cluster
  await connectDB();
});
