# runstat

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-10.13+-blue.svg)](https://www.apple.com/macos/)

macOS 메뉴바 시스템 모니터 - CPU 사용률 수치 표시

## 기능
- 실시간 CPU, 메모리, 디스크 사용률 모니터링
- 메뉴바에 CPU 사용률 퍼센트 표시
- 마우스 오버시 상세 정보 툴팁 (CPU, 메모리, 디스크)
- macOS 10.13 이상 지원

## 표시 방식
- 메뉴바: 🖥️ CPU 사용률 퍼센트 (예: 🖥️ 25%)
- 색상 구분:
  - 🟢 초록 배경/흰 글씨: 0-39% (정상)
  - 🟡 노랑 배경/검은 글씨: 40-59% (주의)
  - 🟠 주황 배경/흰 글씨: 60-79% (경고)
  - 🔴 빨강 배경/흰 글씨: 80%+ (위험)
- 툴팁: CPU, 메모리, 디스크 사용률 상세 정보

## 설치 방법

### 자동 설치 및 시작 프로그램 등록
```bash
./install.sh
```

### 수동 설치
1. runstat.app을 Applications 폴더로 복사
2. Applications에서 runstat 실행

### 빌드하기
```bash
swiftc -o runstat runstat.swift
```

## 제거 방법
Applications 폴더에서 runstat.app 삭제

## 기여하기
기여를 환영합니다! [CONTRIBUTING.md](CONTRIBUTING.md)를 참고해주세요.

## 라이선스
이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

## 버전
- 1.2 - CPU 사용률 수치 직접 표시로 변경
- 1.1 - runcat 스타일 애니메이션 추가, CPU 반응형 속도 조절
- 1.0 - 초기 릴리즈
