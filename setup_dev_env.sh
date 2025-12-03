#!/bin/bash
# Android Dev Environment Setup Script
# Java 17 + Gradle 8.3 + Android SDK CLI
# Run as normal user, not root (except where sudo needed)

set -e

echo "🚀 Starting Android dev environment setup..."

# 1️⃣ Remove old Java & Gradle (optional but safe)
echo "🗑 Removing old Java & Gradle..."
sudo apt remove openjdk-* -y || true
sudo rm -rf /opt/gradle ~/.gradle || true

# 2️⃣ Install OpenJDK 17
echo "☕ Installing OpenJDK 17..."
sudo apt update
sudo apt install -y openjdk-17-jdk wget unzip

# Verify Java
java -version
javac -version

# 3️⃣ Install Gradle 8.3
echo "⚡ Installing Gradle 8.3..."
wget https://services.gradle.org/distributions/gradle-8.3-bin.zip -P /tmp
sudo unzip -d /opt/gradle /tmp/gradle-8.3-bin.zip
echo 'export PATH=$PATH:/opt/gradle/gradle-8.3/bin' >> ~/.bashrc

# 4️⃣ Android SDK CLI tools
echo "📦 Installing Android SDK CLI..."
mkdir -p ~/Android/Sdk
cd ~/Android/Sdk
wget https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip
unzip -o commandlinetools-linux-9123335_latest.zip
mv cmdline-tools latest
mkdir cmdline-tools
mv latest cmdline-tools/


# Add Android SDK to PATH
echo 'export ANDROID_SDK_ROOT=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH' >> ~/.bashrc
echo 'export PATH=$ANDROID_SDK_ROOT/platform-tools:$PATH' >> ~/.bashrc

# 5️⃣ Install essential SDK components
echo "🔧 Installing essential Android SDK packages..."
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID_SDK_ROOT/platform-tools:$PATH
sdkmanager --install "platform-tools" "platforms;android-33" "build-tools;33.0.2" --sdk_root=$ANDROID_SDK_ROOT

# Verify everything
echo "✅ Setup complete. Verifying installations..."
java -version
javac -version
gradle -v
sdkmanager --list

echo "🎉 Android development environment is ready! You can now build Android projects."