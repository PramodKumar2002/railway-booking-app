const express = require('express');
const router = express.Router();
const Contact = require('../models/Contact');
const { isClusterConnected, loadFallbackData, saveFallbackData } = require('../db');

// POST /api/contact - Submit contact inquiry
router.post('/', async (req, res) => {
  try {
    const { name, email, subject, message } = req.body;

    if (!name || !email || !subject || !message) {
      return res.status(400).json({
        success: false,
        message: 'All fields (name, email, subject, message) are required.',
      });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email.trim())) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid email address.',
      });
    }

    const contactData = {
      name: name.trim(),
      email: email.trim().toLowerCase(),
      subject: subject.trim(),
      message: message.trim(),
      createdAt: new Date(),
    };

    if (isClusterConnected()) {
      await Contact.create(contactData);
      console.log(`[CLUSTER] New contact query saved from: ${contactData.email}`);
    } else {
      const db = loadFallbackData();
      if (!db.contacts) db.contacts = [];
      contactData._id = 'cnt_' + Date.now();
      db.contacts.push(contactData);
      saveFallbackData(db);
      console.log(`[LOCAL STORE] New contact query saved from: ${contactData.email}`);
    }

    return res.status(200).json({
      success: true,
      message: 'Thank you for reaching out! Your message has been submitted to Railway Support.',
      data: {
        referenceId: 'REQ-' + Math.floor(100000 + Math.random() * 900000),
        name: contactData.name,
        email: contactData.email,
      },
    });
  } catch (error) {
    console.error('Error submitting contact message:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to submit contact message: ' + error.message,
    });
  }
});

module.exports = router;
