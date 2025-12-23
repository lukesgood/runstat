#!/bin/bash

# runstat 설치 스크립트

echo "runstat 설치를 시작합니다..."

# 기존 runstat 프로세스 종료
echo "기존 runstat 프로세스를 종료합니다..."
killall runstat 2>/dev/null || true

# 기존 앱 삭제
if [ -d "/Applications/runstat.app" ]; then
    echo "기존 runstat.app을 삭제합니다..."
    rm -rf "/Applications/runstat.app"
fi

# 새로운 앱 빌드
echo "새로운 runstat을 빌드합니다..."
swiftc -o runstat runstat.swift

if [ $? -ne 0 ]; then
    echo "빌드에 실패했습니다."
    exit 1
fi

# 앱 번들 생성
echo "앱 번들을 생성합니다..."
mkdir -p runstat.app/Contents/MacOS
mkdir -p runstat.app/Contents/Resources

# 실행 파일 복사
cp runstat runstat.app/Contents/MacOS/

# Info.plist 생성
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
    <string>1.1</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Applications 폴더로 복사
echo "Applications 폴더로 복사합니다..."
cp -R runstat.app /Applications/

# 권한 설정
chmod +x /Applications/runstat.app/Contents/MacOS/runstat

# LaunchAgent 설정 (자동 시작)
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="$LAUNCH_AGENT_DIR/com.runstat.app.plist"

mkdir -p "$LAUNCH_AGENT_DIR"

# 기존 LaunchAgent 제거
launchctl unload "$PLIST_FILE" 2>/dev/null || true

cat > "$PLIST_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.runstat.app</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/runstat.app/Contents/MacOS/runstat</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF

# LaunchAgent 등록
launchctl load "$PLIST_FILE"

echo "설치가 완료되었습니다!"
echo "runstat이 시스템 재시작 시 자동으로 실행됩니다."
echo ""
echo "수동 실행: open /Applications/runstat.app"
echo "자동 시작 해제: launchctl unload ~/Library/LaunchAgents/com.runstat.app.plist"
