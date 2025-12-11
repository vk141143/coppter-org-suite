# Backend Requirements - Admin OTP Verification

## 🚨 Critical Missing Endpoint

The Flutter app is ready but cannot authenticate because this endpoint is missing or not working:

```
POST /api/auth/verify-login/admin
```

## 📝 Required Implementation

### Endpoint Details

**URL:** `http://43.205.99.220:8001/api/auth/verify-login/admin`

**Method:** `POST`

**Request Body:**
```json
{
  "phone_number": "1234567890",
  "otp": "123456"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "role": "admin",
  "admin": {
    "id": "uuid",
    "full_name": "Admin Name",
    "phone_number": "1234567890",
    "email": "admin@example.com",
    "is_active": true
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "error": {
    "status_code": 400,
    "error_message": "Invalid OTP"
  }
}
```

**Error Response (404):**
```json
{
  "success": false,
  "error": {
    "status_code": 404,
    "error_message": "Admin not found"
  }
}
```

## 🔧 Implementation Steps

### 1. Verify OTP from Redis

```python
# Pseudo-code
redis_key = f"admin_login_otp:{phone_number}"
stored_otp = redis.get(redis_key)

if not stored_otp or stored_otp != otp:
    raise HTTPException(status_code=400, detail="Invalid OTP")

# Delete OTP after verification
redis.delete(redis_key)
```

### 2. Generate JWT Token

```python
from datetime import datetime, timedelta
import jwt

SECRET_KEY = "your-secret-key"  # From environment variable
ALGORITHM = "HS256"

def create_access_token(admin_id: str, role: str):
    expire = datetime.utcnow() + timedelta(days=7)
    payload = {
        "sub": admin_id,
        "role": role,
        "exp": expire
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    return token
```

### 3. Return Response

```python
token = create_access_token(admin.id, "admin")

return {
    "success": True,
    "message": "Login successful",
    "access_token": token,
    "token_type": "bearer",
    "role": "admin",
    "admin": {
        "id": str(admin.id),
        "full_name": admin.full_name,
        "phone_number": admin.phone_number,
        "email": admin.email,
        "is_active": admin.is_active
    }
}
```

## 🔐 Protected Routes

All admin routes must verify the JWT token:

```python
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt

security = HTTPBearer()

async def get_current_admin(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        admin_id = payload.get("sub")
        role = payload.get("role")
        
        if role != "admin":
            raise HTTPException(status_code=403, detail="Not authorized")
        
        # Get admin from database
        admin = db.query(Admin).filter(Admin.id == admin_id).first()
        if not admin:
            raise HTTPException(status_code=404, detail="Admin not found")
        
        return admin
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.JWTError:
        raise HTTPException(status_code=403, detail="Invalid token")

# Use in routes:
@router.get("/admin/categories/")
async def get_categories(current_admin: Admin = Depends(get_current_admin)):
    # Only accessible with valid admin token
    return categories
```

## 🧪 Testing

### Test 1: Verify OTP Endpoint Exists
```bash
curl -X POST http://43.205.99.220:8001/api/auth/verify-login/admin \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"1234567890","otp":"123456"}'
```

**Expected:** 200 with JWT token
**Current:** 404 "Admin not found"

### Test 2: Verify Token Works
```bash
# Get token from step 1, then:
curl -X GET http://43.205.99.220:8001/api/admin/categories/ \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected:** 200 with categories array
**Current:** 403 "Not authenticated"

## ✅ Checklist

- [ ] `/api/auth/verify-login/admin` endpoint created
- [ ] OTP verification from Redis implemented
- [ ] JWT token generation implemented
- [ ] Token includes: sub (admin_id), role, exp
- [ ] Token expires in 7 days
- [ ] Response includes `access_token` field
- [ ] Protected routes verify JWT token
- [ ] 403 returned when token is invalid/missing
- [ ] Tested with cURL/Postman
- [ ] CORS allows Flutter web domain

## 🚀 Once Implemented

1. Test with cURL first
2. Verify token is returned
3. Verify protected routes accept token
4. Flutter app will automatically work
5. No Flutter code changes needed

## 📞 Contact

If you need help implementing this in FastAPI, please contact your backend developer with this document.

---

**Flutter app is 100% ready. Waiting for backend implementation.**
