# 📝 Trov-Tver Todo Application

A modern, full-stack todo application with React frontend, Express.js backend, and MongoDB database. Deployed on Google Cloud Run with CI/CD automation via GitHub Actions.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-18.x-green.svg)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-18.x-blue.svg)](https://reactjs.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.x-green.svg)](https://www.mongodb.com/)

---

## 🚀 Features

- ✅ **Full CRUD Operations** - Create, Read, Update, Delete todos
- ✅ **Task Management** - Mark tasks as complete/incomplete
- ✅ **Inline Editing** - Edit titles and descriptions seamlessly
- ✅ **MongoDB Persistence** - Reliable NoSQL database storage
- ✅ **RESTful API** - Clean, well-structured backend architecture
- ✅ **Responsive Design** - Works flawlessly on all devices
- ✅ **Cloud Deployment** - Automated deployment to Google Cloud Run
- ✅ **CI/CD Pipeline** - Automated testing and deployment with GitHub Actions

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Google Cloud Run                          │
│  ┌───────────────────┐          ┌────────────────────────┐  │
│  │  React Frontend   │  ────▶   │  Express.js Backend    │  │
│  │  (Static Build)   │          │  (REST API)            │  │
│  └───────────────────┘          └────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │   MongoDB Atlas      │
                              │   (Cloud Database)   │
                              └──────────────────────┘
```

---

## 📦 Tech Stack

### Frontend
- **React 18.x** - Modern UI library
- **CSS3** - Custom styling with responsive design
- **Fetch API** - Native HTTP client

### Backend
- **Node.js 18.x** - JavaScript runtime
- **Express.js 4.x** - Web framework
- **Mongoose 9.x** - MongoDB ODM
- **CORS** - Cross-origin resource sharing
- **dotenv** - Environment variable management

### Database
- **MongoDB 7.x** - NoSQL database
- **MongoDB Atlas** - Cloud-hosted database (Production)

### DevOps
- **Docker** - Containerization
- **Google Cloud Run** - Serverless deployment
- **GitHub Actions** - CI/CD automation
- **Docker Hub** - Container registry

---

## 🗂️ Project Structure

```
trov-tver/
├── .github/
│   └── workflows/
│       ├── ci-pipeline.yml      # Continuous Integration
│       └── cd-pipeline.yml      # Continuous Deployment
├── backend/
│   ├── config/
│   │   └── dbconnect.js        # MongoDB connection
│   ├── schema.js               # Todo data model
│   ├── server.js               # Express API server
│   ├── package.json
│   └── .env.example           # Environment template
├── frontend/
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── App.js             # Main React component
│   │   ├── App.css            # Application styles
│   │   ├── index.js           # React entry point
│   │   └── setupProxy.js      # Dev proxy configuration
│   └── package.json
├── Dockerfile                  # Multi-stage Docker build
├── .dockerignore
├── start-dev.ps1              # Start development servers
├── stop-dev.ps1               # Stop development servers
├── test.ps1                   # Comprehensive test suite
└── README.md
```

---

## 🚦 Getting Started

### Prerequisites

- **Node.js** v18 or higher ([Download](https://nodejs.org/))
- **MongoDB** (Local or [Atlas account](https://www.mongodb.com/cloud/atlas))
- **npm** (comes with Node.js)
- **Git** ([Download](https://git-scm.com/))

### 1️⃣ Clone Repository

```bash
git clone https://github.com/poVvisal/trov-tver.git
cd trov-tver
```

### 2️⃣ Configure Environment

Create a `.env` file in the `backend` directory:

```bash
cp backend/.env.example backend/.env
```

Edit `backend/.env` with your MongoDB connection:

```env
# For local MongoDB
MONGO_URI=mongodb://localhost:27017/notes

# For MongoDB Atlas
# MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/notes

PORT=3001
NODE_ENV=development
```

### 3️⃣ Install Dependencies

```powershell
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install
```

### 4️⃣ Start Development Servers

**Option A: Automated (Recommended)**
```powershell
# From root directory
.\start-dev.ps1
```
This starts both backend (port 3001) and frontend (port 3000) and opens your browser.

**Option B: Manual**
```powershell
# Terminal 1 - Backend
cd backend
npm start

# Terminal 2 - Frontend
cd frontend
npm start
```

🎉 **Application running at:** http://localhost:3000

---

## 🧪 Testing

Run the comprehensive API test suite:

```powershell
.\test.ps1
```

This tests:
- Server health checks
- GET all todos
- POST create todo
- GET single todo
- PUT update todo
- DELETE todo
- Error handling

---

## 🐳 Docker Deployment

### Build & Run Locally

```bash
# Build image
docker build -t trov-tver:latest .

# Run container
docker run -p 3001:3001 \
  -e MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/notes \
  trov-tver:latest
```

Access at: http://localhost:3001

---

## ☁️ Production Deployment

### Google Cloud Run

The application automatically deploys to staging/production via GitHub Actions.

**Staging:** Triggered on push to `staging` branch  
**Production:** Triggered on GitHub release

#### Required GitHub Secrets:
- `GCP_SERVICE_ACCOUNT` - GCP service account JSON
- `GCP_PROJECT_ID` - Google Cloud project ID
- `DOCKER_USER` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub access token
- `MONGO_URI_STAGING` - MongoDB connection for staging
- `MONGO_URI_PRODUCTION` - MongoDB connection for production

#### Required GitHub Variables:
- `IMAGE` - Docker image name (e.g., `username/trov-tver`)
- `GCR_STAGING_PROJECT_NAME` - Cloud Run service name for staging
- `GCR_PRODUCTION_PROJECT_NAME` - Cloud Run service name for production
- `GCR_REGION` - GCP region (e.g., `asia-southeast1`)

### Manual Cloud Run Deployment

```bash
# Build and push
docker build -t gcr.io/PROJECT_ID/trov-tver:latest .
docker push gcr.io/PROJECT_ID/trov-tver:latest

# Deploy to Cloud Run
gcloud run deploy trov-tver \
  --image gcr.io/PROJECT_ID/trov-tver:latest \
  --platform managed \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --set-env-vars MONGO_URI=mongodb+srv://...
```

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/health` | Health check |
| `GET` | `/api/todos` | Get all todos |
| `GET` | `/api/todos/:id` | Get single todo |
| `POST` | `/api/todos` | Create new todo |
| `PUT` | `/api/todos/:id` | Update todo |
| `DELETE` | `/api/todos/:id` | Delete todo |

### Example Requests

**Create Todo:**
```bash
curl -X POST http://localhost:3001/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Buy groceries","description":"Milk, eggs, bread"}'
```

**Get All Todos:**
```bash
curl http://localhost:3001/api/todos
```

**Update Todo:**
```bash
curl -X PUT http://localhost:3001/api/todos/123abc \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
```

---

## 🛠️ Development

### File Structure

**Backend:**
- `server.js` - Express server and API routes
- `schema.js` - Mongoose Todo model
- `config/dbconnect.js` - Database connection logic

**Frontend:**
- `App.js` - Main React component with state management
- `App.css` - Styling and responsive design
- `setupProxy.js` - Development proxy to backend

### Environment Variables

**Development:**
```env
MONGO_URI=mongodb://localhost:27017/notes
PORT=3001
NODE_ENV=development
```

**Production:**
```env
MONGO_URI=mongodb+srv://...
PORT=3001
NODE_ENV=production
```

---

## 🐛 Troubleshooting

### Backend won't start
- Check MongoDB is running: `mongod --version`
- Verify MONGO_URI in `.env`
- Check port 3001 is available: `netstat -an | findstr 3001`

### Frontend can't fetch todos
- Ensure backend is running on port 3001
- Check browser console for CORS errors
- Verify API_URL in `App.js` matches backend

### Docker build fails
- Ensure both frontend and backend `package.json` exist
- Check Docker daemon is running: `docker ps`
- Verify MongoDB connection string doesn't have special characters

### Cloud Run deployment fails
- Check GitHub Secrets are set correctly
- Verify MongoDB Atlas allows Cloud Run IPs (0.0.0.0/0)
- Check Cloud Run logs: Cloud Console → Cloud Run → Service → Logs

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Your Name**  
GitHub: [@poVvisal](https://github.com/poVvisal)

---

## 🙏 Acknowledgments

- React team for the amazing UI library
- MongoDB team for the robust database
- Google Cloud for serverless infrastructure
- GitHub Actions for seamless CI/CD

---

## 📞 Support

For issues, questions, or contributions:
- 🐛 [Open an issue](https://github.com/poVvisal/trov-tver/issues)
- 🔀 [Submit a pull request](https://github.com/poVvisal/trov-tver/pulls)
- 📧 Email: p.visal5927@gmail.com
---

**Made with ❤️ and ☕**

## Features tonight

- ✅ Create, read, update, and delete todos
- ✅ Mark todos as complete/incomplete
- ✅ Edit todo titles and descriptions
- ✅ MongoDB database for data persistence
- ✅ RESTful API backend
- ✅ Responsive React frontend

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (local or cloud instance)
- npm or yarn

## Project Structure

```
trov-tver/
├── backend/
│   ├── server.js           # Express API server
│   ├── schema.js           # MongoDB Todo schema
│   ├── config/
│   │   └── dbconnect.js    # Database connection
│   └── package.json
├── frontend/
│   ├── src/
│   │   ├── App.js          # Main React component
│   │   ├── App.css         # Styles
│   │   └── setupProxy.js   # API proxy config
│   ├── public/
│   └── package.json
├── start-dev.ps1           # Start both servers
├── stop-dev.ps1            # Stop all servers
├── test.ps1                # Comprehensive test suite
└── README.md
```

## Quick Start

### 1. Setup Environment

Create a `.env` file in the `backend` directory:

```env
MONGO_URI=mongodb://localhost:27017/todoapp
PORT=3001
```

### 2. Install Dependencies

```powershell
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install
```

### 3. Start Application

```powershell
# From root directory
.\start-dev.ps1
```

This will:
- Start the backend server on port 3001
- Start the frontend server on port 3000
- Automatically open your browser to http://localhost:3000

### 4. Stop Application

```powershell
.\stop-dev.ps1
```

## Manual Start

If you prefer to start servers manually:

```powershell
# Terminal 1 - Backend
cd backend
npm start

# Terminal 2 - Frontend
cd frontend
npm start
```

## Testing

Run the comprehensive test suite:

```powershell
.\test.ps1
```

This tests:
- Backend API endpoints
- CRUD operations
- Data validation
- Error handling
- Server connectivity
- Frontend-backend integration

## API Endpoints

| Method | Endpoint           | Description          |
|--------|-------------------|----------------------|
| GET    | /api/health       | Server health check  |
| GET    | /api/todos        | Get all todos        |
| GET    | /api/todos/:id    | Get single todo      |
| POST   | /api/todos        | Create new todo      |
| PUT    | /api/todos/:id    | Update todo          |
| DELETE | /api/todos/:id    | Delete todo          |

### Request/Response Examples

**Create Todo:**
```json
POST /api/todos
{
  "title": "Buy groceries",
  "description": "Milk, eggs, bread"
}
```

**Update Todo:**
```json
PUT /api/todos/:id
{
  "completed": true
}
```

## Technologies

### Backend
- Express.js - Web framework
- MongoDB - Database
- Mongoose - ODM
- Cors - Cross-origin support
- dotenv - Environment configuration

### Frontend
- React - UI library
- Create React App - Build tooling
- Fetch API - HTTP requests

## Development Scripts

### Backend (`backend/package.json`)
- `npm start` - Start server (production)
- `npm run dev` - Start with nodemon (development)

### Frontend (`frontend/package.json`)
- `npm start` - Start development server
- `npm run build` - Build for production
- `npm test` - Run tests

## Database Schema

Todo Model:
```javascript
{
  title: String (required),
  description: String (default: ""),
  completed: Boolean (default: false),
  createdAt: Date (auto),
  updatedAt: Date (auto)
}
```

## Troubleshooting

### Port Already in Use
```powershell
# Stop all Node processes
.\stop-dev.ps1
```

### MongoDB Connection Error
- Ensure MongoDB is running
- Check MONGO_URI in `.env` file
- Verify database permissions

### Frontend Not Loading
- Wait 30-60 seconds for initial compilation
- Clear browser cache (Ctrl+Shift+R)
- Check backend is running at http://localhost:3001/api/health

### Cannot Delete Todos
- Ensure you're using the latest code (MongoDB uses `_id` not `id`)
- Refresh browser after code changes
- Check browser console for errors

## Production Build

### Backend
```powershell
cd backend
npm start
```

### Frontend
```powershell
cd frontend
npm run build
# Serve the build folder with a static server
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly with `.\test.ps1`
5. Submit a pull request

## License

MIT

## Support

For issues or questions:
- Check the troubleshooting section
- Run `.\test.ps1` to diagnose problems
- Review browser console and terminal logs
