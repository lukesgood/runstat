#!/bin/bash

echo "runstat installation starting..."

# Kill existing runstat processes
echo "Stopping existing runstat processes..."
killall runstat 2>/dev/null || true

# Remove existing app
if [ -d "/Applications/runstat.app" ]; then
    echo "Removing existing runstat.app..."
    rm -rf "/Applications/runstat.app"
fi

# Build new app
echo "Building new runstat..."
swiftc -o runstat runstat.swift

if [ $? -ne 0 ]; then
    echo "Build failed."
    exit 1
fi

# Create app bundle
echo "Creating app bundle..."
mkdir -p runstat.app/Contents/MacOS
mkdir -p runstat.app/Contents/Resources

# Copy executable
cp runstat runstat.app/Contents/MacOS/

# Create Info.plist
cat > runstat.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>runstat</string>
    <key>CFBundleIdentifier</key>
    <string>com.runstat.app</string>
    <key>CFBundleName</key>
    <string>runstat</string>
    <key>CFBundleVersion</key>
    <string>1.2</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Copy to Applications folder
echo "Copying to Applications folder..."
cp -R runstat.app /Applications/

# Set permissions
chmod +x /Applications/runstat.app/Contents/MacOS/runstat

echo "Installation complete!"
echo ""
echo "To run: open /Applications/runstat.app"
echo "To enable auto-start: Right-click runstat menubar icon → Launch at Login"
