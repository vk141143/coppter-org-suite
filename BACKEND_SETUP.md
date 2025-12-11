# Backend Connection Setup

## Issue: ERR_CONNECTION_REFUSED

The error `net::ERR_CONNECTION_REFUSED` means your backend server is not running or not accessible.

## Solutions:

### Option 1: Start Your Backend Server
Make sure your Django/FastAPI backend is running on `http://localhost:8000`

```bash
# For Django
python manage.py runserver

# For FastAPI
uvicorn main:app --reload --port 8000
```

### Option 2: Update Backend URL
If your backend is running on a different URL, update the `.env` file:

```env
# Change this to your actual backend URL
BASE_URL=http://localhost:8000/api/v1

# Or if deployed
BASE_URL=https://your-backend-domain.com/api/v1
```

### Option 3: Use Mock Data (Temporary)
If you don't have a backend yet, you can temporarily disable the API call by modifying the auth service to return mock data.

## Testing Backend Connection

1. Open browser and visit: `http://localhost:8000/api/v1/auth/register/customer/`
2. You should see an API response (not connection refused)
3. If you see connection refused, your backend is not running

## CORS Configuration (Important for Web)

Make sure your backend allows requests from your Flutter web app:

### Django (settings.py)
```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:8080",
]
```

### FastAPI (main.py)
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```
