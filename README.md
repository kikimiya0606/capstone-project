<div align="center">

<br/>

```
 █████╗ ██╗    ███████╗ █████╗ ███╗   ███╗██╗██╗  ██╗   ██╗
██╔══██╗██║    ██╔════╝██╔══██╗████╗ ████║██║██║  ╚██╗ ██╔╝
███████║██║    █████╗  ███████║██╔████╔██║██║██║   ╚████╔╝ 
██╔══██║██║    ██╔══╝  ██╔══██║██║╚██╔╝██║██║██║    ╚██╔╝  
██║  ██║██║    ██║     ██║  ██║██║ ╚═╝ ██║██║███████╗██║   
╚═╝  ╚═╝╚═╝    ╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚══════╝╚═╝  
```

### 🌱 생성형 AI 기반 감정 분석 및 캐릭터 성장 시스템을 활용한 가족 소통 플랫폼

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![OpenAI](https://img.shields.io/badge/GPT--4o-412991?style=for-the-badge&logo=openai&logoColor=white)](https://openai.com)
[![HuggingFace](https://img.shields.io/badge/KoBERT-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black)](https://huggingface.co)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org)

<br/>

> *"감정을 기록하고, AI가 이어주고, 가족이 함께 자랍니다"*

<br/>

</div>

---

## 📖 프로젝트 소개

현대 사회에서 바쁜 일상과 1인 가구의 증가로 가족 간 대화 시간이 점점 줄어들고 있습니다.  
**AI Family**는 생성형 AI 기술을 활용하여 가족 구성원들이 자연스럽게 감정을 나누고, 소통할 수 있도록 돕는 모바일 플랫폼입니다.

단순한 메신저를 넘어, **KoBERT 감정 분석**과 **GPT-4o 공감 메시지 생성**을 결합해 깊이 있는 정서 교류를 이끌어내고,  
**가족 정원 성장 시스템(게이미피케이션)** 으로 꾸준한 참여를 유도합니다.

<br/>

## ✨ 핵심 기능

| 기능 | 설명 |
|------|------|
| 📔 **감정 일기** | KoBERT 기반 한국어 감정 자동 분류 (긍정/부정/중립) |
| 💬 **AI 공감 메시지** | GPT-4o가 생성하는 감정 맞춤형 따뜻한 메시지 |
| ❓ **AI 데일리 질문** | 가족 간 대화를 유도하는 매일 새로운 맞춤형 질문 |
| 🌿 **가족 정원 성장** | 소통 활동량에 따라 함께 성장하는 캐릭터 & 정원 |
| 📅 **스마트 일정 공유** | 가족 공동 일정 등록, 조회, 알림 |
| 🕰️ **타임캡슐** | 소중한 감정과 추억을 보관하고 미래에 다시 여는 아카이브 |
| 📊 **감정 리포트** | 주간/월간 감정 흐름 및 가족 소통 현황 분석 |

<br/>

## 🏗️ 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend (Flutter)                    │
│           iOS / Android Cross-Platform App               │
└────────────────────┬────────────────────────────────────┘
                     │ REST API (HTTPS)
┌────────────────────▼────────────────────────────────────┐
│              Backend (Node.js + Firebase)                │
│        Firebase Auth │ API Server │ Cloud Functions      │
└──────┬──────────────┴──────────────────┬────────────────┘
       │                                  │
┌──────▼──────────┐           ┌──────────▼──────────────┐
│  AI 감정 분석    │           │    생성형 AI (GPT-4o)    │
│  Python + KoBERT│           │    OpenAI GPT API        │
│  · 감정 분류    │           │    · 공감 메시지 생성     │
│  · 형태소 분석  │           │    · 데일리 질문 생성     │
│  · 신뢰도 산출  │           │    · 감정 요약 리포트     │
└──────┬──────────┘           └──────────┬──────────────┘
       │                                  │
┌──────▼──────────────────────────────────▼──────────────┐
│              Firebase Realtime Database                  │
│   Users │ Emotions │ Questions │ Garden │ Timecapsules  │
└─────────────────────────────────────────────────────────┘
```

**데이터 흐름:**  
`사용자 입력` → `KoBERT 감정 분석` → `GPT-4o 응답 생성` → `Firebase 저장` → `피드백 제공`

<br/>

## 🛠️ 기술 스택

### Frontend
- **Framework:** Flutter (iOS / Android)
- **Language:** Dart
- **State Management:** Provider / Riverpod

### Backend
- **Runtime:** Node.js, Python (FastAPI)
- **Serverless:** Firebase Cloud Functions
- **AI Inference:** Docker-based GPU Server

### Database & Storage
- **DB:** Cloud Firestore (NoSQL), Firebase Realtime DB
- **Storage:** Firebase Cloud Storage

### AI / ML
- **감정 분석:** KoBERT (HuggingFace Fine-tuning)
- **텍스트 생성:** OpenAI GPT-4o API
- **이미지 생성:** DALL·E 3 (정원 캐릭터)
- **데이터셋:** AI Hub 한국어 감정 데이터셋

### DevOps & Collaboration
- **VCS:** GitHub
- **CI/CD:** GitHub Actions, Codemagic
- **Design:** Figma
- **협업:** Notion, Slack

<br/>

## 👥 팀 구성

> **팀명:** 에이원하조 (A1HaJo)  
> **과목:** AI 캡스톤 디자인

<br/>

| 이름 | 역할 | 담당 업무 |
|------|------|-----------|
| 권유진 | 기획 / AI 모델링 | 프로젝트 관리, REST API 설계, KoBERT 모델 구조 설계 |
| 강민서 | 데이터 / AI 모델링 | AI Hub 데이터셋 수집·전처리, 형태소 분석, 모델 학습 파이프라인 구축 |
| 차은비 | AI 모델링 / 기획 | OpenAI GPT API 연동, 프롬프트 엔지니어링, Firebase 서버 기능 구현 |
| 정윤도 | UI/UX | Flutter 감정 입력 캘린더 화면 구현, API 연동, 캐릭터 성장 로직 구현 |
| 김란아 | UI/UX | 앱 와이어프레임·디자인 시스템 설계, 사용성 테스트, UI 컴포넌트·애니메이션 구현 |

<br/>

## 📊 성능 목표

| 지표 | 목표값 |
|------|--------|
| 감정 분석 응답 시간 | 5초 이내 |
| KoBERT F1-Score | 0.80 이상 |
| 서버 가용성 | 99.5% 이상 |
| 동시 사용자 처리 | 100명 이상 |
| 핵심 기능 접근 | 3회 클릭 이내 |

<br/>

## 🚀 시작하기

### 사전 요구사항
```bash
Flutter SDK >= 3.x
Dart >= 3.x
Node.js >= 18.x
Python >= 3.10
Firebase CLI
```

### 설치 및 실행

```bash
# 레포지토리 클론
git clone https://github.com/kikimiya0606/capstone-project.git
cd capstone-project

# Flutter 앱 의존성 설치
cd frontend
flutter pub get

# 백엔드 의존성 설치
cd ../backend
npm install

# Python AI 서버 의존성 설치
cd ../ai-server
pip install -r requirements.txt

# Flutter 앱 실행
cd ../frontend
flutter run
```

### 환경변수 설정
```bash
# .env 파일 생성 후 아래 항목 설정
OPENAI_API_KEY=your_openai_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
KOBERT_MODEL_PATH=your_model_path
```

> ⚠️ 모든 API 키는 환경변수로 관리하며, Firebase Security Rules를 통해 접근 제어 및 보안을 유지합니다.

<br/>

## 🌟 차별점

기존 가족·커플 앱과의 비교:

| | Between | Slowly | Sumone | **AI Family** ✨ |
|--|---------|--------|--------|----------------|
| 주요 타깃 | 커플/가족 | 개인/펜팔 | 커플 | **가족 전체** |
| 감정 분석 | ✗ | ✗ | ✗ | **✅ KoBERT** |
| 대화 유도 | 일정 중심 | 편지 형식 | 질문 기반 | **AI 맞춤 질문** |
| 게이미피케이션 | ✗ | ✗ | 캐릭터 성장 | **🌿 공유 정원 성장** |

<br/>

## 📁 레포지토리 구조

```
capstone-project/
├── frontend/          # Flutter 모바일 앱
│   ├── lib/
│   │   ├── screens/   # 화면 구성
│   │   ├── widgets/   # UI 컴포넌트
│   │   └── services/  # API 연동
├── backend/           # Node.js + Firebase Functions
│   ├── functions/
│   └── firestore.rules
├── ai-server/         # Python + KoBERT 감정 분석
│   ├── model/
│   ├── train/
│   └── api/
└── docs/              # 프로젝트 문서
```

<br/>

---

<div align="center">

**팀 에이원하조 A1HaJo** · AI 캡스톤 디자인 2026

*가족의 감정을 잇는 AI, AI Family*

</div>
