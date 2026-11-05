const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Otp = require('../models/Otp');
const { isClusterConnected, loadFallbackData, saveFallbackData } = require('../db');

// Helper to sign JWT token using secret key
function generateToken(user) {
  const secret = process.env.JWT_SECRET || 'secret123';
  return jwt.sign(
    {
      id: user._id ? user._id.toString() : user.id,
      email: user.email,
      fullName: user.fullName || 'User',
    },
    secret,
    { expiresIn: '30d' }
  );
}

// Helper to generate a 6-digit numeric OTP
function generate6DigitOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// POST /api/auth/send-otp
router.post('/send-otp', async (req, res) => {
  try {
    const { fullName, email, phone, password } = req.body;

    if (!fullName || !email || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'All fields (fullName, email, phone, password) are required.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const normalizedPhone = phone.trim();
    const identifier = normalizedEmail || normalizedPhone;

    // Check if user already exists
    if (isClusterConnected()) {
      const existingUser = await User.findOne({
        $or: [{ email: normalizedEmail }, { phone: normalizedPhone }],
      });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'An account with this email or phone already exists. Please login.',
        });
      }
    } else {
      const db = loadFallbackData();
      const existingUser = db.users.find(
        (u) => u.email === normalizedEmail || u.phone === normalizedPhone
      );
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'An account with this email or phone already exists. Please login.',
        });
      }
    }

    // Generate 6-digit OTP
    const otpCode = generate6DigitOtp();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes validity
    const hashedPassword = await bcrypt.hash(password, 10);

    const pendingData = {
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: normalizedPhone,
      password: hashedPassword,
    };

    if (isClusterConnected()) {
      // Remove any prior pending OTPs for this user
      await Otp.deleteMany({ identifier });
      await Otp.create({
        identifier,
        otp: otpCode,
        pendingUserData: pendingData,
        expiresAt,
      });
      console.log(`[CLUSTER] Generated OTP for ${identifier}: ${otpCode}`);
    } else {
      const db = loadFallbackData();
      db.otps = db.otps.filter((o) => o.identifier !== identifier);
      db.otps.push({
        identifier,
        otp: otpCode,
        pendingUserData: pendingData,
        expiresAt: expiresAt.toISOString(),
      });
      saveFallbackData(db);
      console.log(`[LOCAL STORE] Generated OTP for ${identifier}: ${otpCode}`);
    }

    return res.status(200).json({
      success: true,
      message: `OTP generated successfully for ${normalizedEmail}.`,
      otp: otpCode, // Provided for easy development & testing preview
      expiresInSeconds: 300,
      identifier,
    });
  } catch (error) {
    console.error('Error in send-otp:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error while generating OTP: ' + error.message,
    });
  }
});

// POST /api/auth/verify-otp
router.post('/verify-otp', async (req, res) => {
  try {
    const { email, phone, otp } = req.body;

    if (!otp) {
      return res.status(400).json({
        success: false,
        message: 'OTP is required.',
      });
    }

    const normalizedOtp = otp ? otp.toString().replace(/\s+/g, '') : '';
    const normalizedEmail = email ? email.trim().toLowerCase() : '';
    const normalizedPhone = phone ? phone.trim() : '';
    const identifier = normalizedEmail || normalizedPhone;

    console.log(`[CLUSTER] Received /api/auth/verify-otp for identifier: "${identifier}", entered OTP: "${normalizedOtp}"`);

    if (!identifier) {
      return res.status(400).json({
        success: false,
        message: 'Email or phone identifier is required.',
      });
    }

    // Build flexible identifier condition list
    const identifierConditions = [];
    if (normalizedEmail) identifierConditions.push({ identifier: normalizedEmail });
    if (normalizedPhone) identifierConditions.push({ identifier: normalizedPhone });
    if (identifierConditions.length === 0 && identifier) identifierConditions.push({ identifier });

    let pendingRecord = null;

    if (isClusterConnected()) {
      pendingRecord = await Otp.findOne({
        $or: identifierConditions,
        otp: normalizedOtp,
      });

      if (!pendingRecord) {
        console.warn(`[CLUSTER] Invalid OTP attempt for ${identifier}. Entered: ${normalizedOtp}`);
        return res.status(400).json({
          success: false,
          message: 'Invalid OTP. Please check the code and try again.',
        });
      }

      if (new Date() > new Date(pendingRecord.expiresAt)) {
        await Otp.deleteMany({ $or: identifierConditions });
        return res.status(400).json({
          success: false,
          message: 'OTP has expired. Please request a new one.',
        });
      }

      // Check if user is already saved (prevents duplicate key error on fast double-tap)
      let user = await User.findOne({
        $or: [
          ...(normalizedEmail ? [{ email: normalizedEmail }] : []),
          ...(normalizedPhone ? [{ phone: normalizedPhone }] : []),
        ],
      });

      if (!user) {
        // Save new user to MongoDB Cluster
        user = await User.create({
          fullName: pendingRecord.pendingUserData.fullName,
          email: pendingRecord.pendingUserData.email,
          phone: pendingRecord.pendingUserData.phone,
          password: pendingRecord.pendingUserData.password,
          isVerified: true,
        });
        console.log(`[CLUSTER] User successfully registered and saved in database: ${user.email}`);
      } else {
        console.log(`[CLUSTER] User was already registered in database: ${user.email}`);
      }

      // Clear the used OTP(s)
      await Otp.deleteMany({ $or: identifierConditions });

      const token = generateToken(user);

      return res.status(200).json({
        success: true,
        message: 'Registration completed successfully! Your account is saved in the database cluster.',
        token,
        user: {
          id: user._id.toString(),
          fullName: user.fullName,
          email: user.email,
          phone: user.phone,
        },
      });
    } else {
      const db = loadFallbackData();
      const otpIdx = db.otps.findIndex(
        (o) =>
          (o.identifier === normalizedEmail ||
            (normalizedPhone && o.identifier === normalizedPhone) ||
            o.identifier === identifier) &&
          o.otp === normalizedOtp
      );

      if (otpIdx === -1) {
        return res.status(400).json({
          success: false,
          message: 'Invalid OTP. Please check the code and try again.',
        });
      }

      const match = db.otps[otpIdx];
      if (new Date() > new Date(match.expiresAt)) {
        db.otps.splice(otpIdx, 1);
        saveFallbackData(db);
        return res.status(400).json({
          success: false,
          message: 'OTP has expired. Please request a new one.',
        });
      }

      let user = db.users.find(
        (u) =>
          (normalizedEmail && u.email === normalizedEmail) ||
          (normalizedPhone && u.phone === normalizedPhone)
      );

      if (!user) {
        user = {
          id: 'usr_' + Date.now(),
          fullName: match.pendingUserData.fullName,
          email: match.pendingUserData.email,
          phone: match.pendingUserData.phone,
          password: match.pendingUserData.password,
          isVerified: true,
          createdAt: new Date().toISOString(),
        };
        db.users.push(user);
      }

      db.otps.splice(otpIdx, 1);
      saveFallbackData(db);

      console.log(`[LOCAL STORE] User successfully registered: ${user.email}`);
      const token = generateToken(user);

      return res.status(200).json({
        success: true,
        message: 'Registration completed successfully! Your account is saved.',
        token,
        user: {
          id: user.id,
          fullName: user.fullName,
          email: user.email,
          phone: user.phone,
        },
      });
    }
  } catch (error) {
    console.error('Error in verify-otp:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error while verifying OTP: ' + error.message,
    });
  }
});

// POST /api/auth/resend-otp
router.post('/resend-otp', async (req, res) => {
  try {
    const { email, phone } = req.body;
    const normalizedEmail = email ? email.trim().toLowerCase() : '';
    const normalizedPhone = phone ? phone.trim() : '';
    const identifier = normalizedEmail || normalizedPhone;

    if (!identifier) {
      return res.status(400).json({
        success: false,
        message: 'Email or phone identifier is required.',
      });
    }

    const newOtp = generate6DigitOtp();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    if (isClusterConnected()) {
      const existing = await Otp.findOne({ identifier });
      if (!existing) {
        return res.status(404).json({
          success: false,
          message: 'No pending registration found. Please register again.',
        });
      }

      existing.otp = newOtp;
      existing.expiresAt = expiresAt;
      await existing.save();

      console.log(`[CLUSTER] Resent OTP for ${identifier}: ${newOtp}`);
    } else {
      const db = loadFallbackData();
      const existing = db.otps.find((o) => o.identifier === identifier);
      if (!existing) {
        return res.status(404).json({
          success: false,
          message: 'No pending registration found. Please register again.',
        });
      }

      existing.otp = newOtp;
      existing.expiresAt = expiresAt.toISOString();
      saveFallbackData(db);

      console.log(`[LOCAL STORE] Resent OTP for ${identifier}: ${newOtp}`);
    }

    return res.status(200).json({
      success: true,
      message: `A new OTP has been generated for ${identifier}.`,
      otp: newOtp,
      expiresInSeconds: 300,
    });
  } catch (error) {
    console.error('Error in resend-otp:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error while resending OTP: ' + error.message,
    });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();
    let user = null;

    if (isClusterConnected()) {
      user = await User.findOne({
        $or: [{ email: normalizedEmail }, { phone: normalizedEmail }],
      });
    } else {
      const db = loadFallbackData();
      user = db.users.find(
        (u) => u.email === normalizedEmail || u.phone === normalizedEmail
      );
    }

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'No account found with this email/phone. Please register first.',
      });
    }

    // Verify password
    const isPasswordMatch = await bcrypt.compare(password, user.password);
    if (!isPasswordMatch) {
      return res.status(401).json({
        success: false,
        message: 'Incorrect password. Please try again.',
      });
    }

    const token = generateToken(user);
    console.log(`[CLUSTER] User successfully logged in: ${user.email}`);

    return res.status(200).json({
      success: true,
      message: 'Login successful! Welcome back, ' + user.fullName,
      token,
      user: {
        id: user._id ? user._id.toString() : user.id,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
      },
    });
  } catch (error) {
    console.error('Error in login:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during login: ' + error.message,
    });
  }
});

// GET /api/auth/status
router.get('/status', (req, res) => {
  return res.status(200).json({
    status: 'online',
    database: 'railway',
    clusterConnected: isClusterConnected(),
    port: process.env.PORT || 5000,
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
