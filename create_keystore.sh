#!/bin/bash

# Script to create a new keystore for Android app signing
# Run this if you don't have keystore credentials

echo "Creating new keystore for your Islamic app..."

keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storetype JKS

echo ""
echo "Keystore created successfully!"
echo "Please update android/key.properties with:"
echo "storePassword=[password you just entered]"
echo "keyPassword=[key password you just entered]" 
echo "keyAlias=upload"
echo "storeFile=app/upload-keystore.jks"