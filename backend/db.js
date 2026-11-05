const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');

let isConnectedToCluster = false;
const fallbackDataFile = path.join(__dirname, 'local_fallback_data.json');

function loadFallbackData() {
  try {
    if (fs.existsSync(fallbackDataFile)) {
      const raw = fs.readFileSync(fallbackDataFile, 'utf8');
      return JSON.parse(raw);
    }
  } catch (err) {
    console.error('Error reading fallback storage file:', err);
  }
  return { users: [], otps: [] };
}

function saveFallbackData(data) {
  try {
    fs.writeFileSync(fallbackDataFile, JSON.stringify(data, null, 2), 'utf8');
  } catch (err) {
    console.error('Error saving fallback storage file:', err);
  }
}

async function connectDB() {
  const uri = process.env.MONGO_URI || process.env.MONGODB_URI;
  if (!uri) {
    console.warn('⚠️ MONGO_URI not provided in .env. Running with local fallback store.');
    return;
  }

  try {
    console.log('🔄 Attempting connection to MongoDB Cluster...');
    await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 10000,
    });
    isConnectedToCluster = true;
    console.log(`✅ Connected to MongoDB Cluster successfully! Database: ${mongoose.connection.name}`);
  } catch (error) {
    isConnectedToCluster = false;
    console.warn('⚠️ Could not connect to MongoDB Cluster:', error.message);
    console.warn('⚡ Using local fallback store so registration & login still work seamlessly!');
  }

  mongoose.connection.on('connected', () => {
    isConnectedToCluster = true;
    console.log('✅ MongoDB Cluster connection established.');
  });

  mongoose.connection.on('disconnected', () => {
    isConnectedToCluster = false;
    console.warn('⚠️ MongoDB Cluster disconnected. Using fallback store.');
  });
}

function isClusterConnected() {
  return isConnectedToCluster && mongoose.connection.readyState === 1;
}

module.exports = {
  connectDB,
  isClusterConnected,
  loadFallbackData,
  saveFallbackData,
};
