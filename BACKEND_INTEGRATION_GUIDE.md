# Backend Integration Guide - Admin Authentication

## 🚨 Current Issue
Your Flutter app is ready, but the backend admin authentication endpoints are returning **404 "Admin not found"**.

## ✅ Flutter App Status
- ✅ Token storage implemented (Web + Mobile)
- ✅ Admin login flow ready
- ✅ Admin OTP verification ready
- ✅ Category management ready
- ✅ Error handling for 403/404

## ❌ Backend Issues
The following endpoints are **NOT WORKING**:
1. `POST /api/auth/login/admin` → 404
2. `POST /api/auth/verify-login/admin` → 404
3. `GET /api/admin/categories/` → 403 (no token)

## 🔧 Required Backend Endpoints

### 1. Admin Login - Send OTP
```
POST http://43.205.99.220:8001/api/auth/login/admin
Content-Type: application/json

{
  "phone_number": "1234567890"
}

Expected Response (200):
{
  "success": true,
  "message": "OTP sent for login"
}
```

### 2. Verify Admin Login OTP - Return Token
```
POST http://43.205.99.220:8001/api/auth/verify-login/admin
Content-Type: application/json

{
  "phone_number": "1234567890",
  "otp": "123456"
}

Expected Response (200):
{
  "success": true,
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### 3. Get Categories (Protected)
```
GET http://43.205.99.220:8001/api/admin/categories/
Authorization: Bearer <token>
Accept: application/json

Expected Response (200):
[
  {
    "id": 1,
    "name": "Household Waste",
    "image_url": "https://example.com/image.png",
    "is_active": true,
    "created_at": "2024-01-01T00:00:00"
  }
]
```

## 🧪 Testing Your Backend

### Test 1: Check if admin login endpoint exists
```bash
curl -X POST http://43.205.99.220:8001/api/auth/login/admin \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"1234567890"}'
```

**Current Result:** 404 "Admin not found"
**Expected Result:** 200 with "OTP sent" message

### Test 2: Check if verify endpoint exists
```bash
curl -X POST http://43.205.99.220:8001/api/auth/verify-login/admin \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"1234567890","otp":"123456"}'
```

**Current Result:** 404 "Admin not found"
**Expected Result:** 200 with JWT token

### Test 3: Check categories endpoint
```bash
curl -X GET http://43.205.99.220:8001/api/admin/categories/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Current Result:** 403 "Not authenticated"
**Expected Result:** 200 with categories array

## 🛠️ Backend Implementation Checklist

Your backend developer needs to:

- [ ] Create Admin model in database
- [ ] Implement `/auth/login/admin` endpoint
- [ ] Implement `/auth/verify-login/admin` endpoint
- [ ] Set up Redis for OTP storage
- [ ] Generate JWT tokens with admin role
- [ ] Protect `/admin/*` routes with JWT middleware
- [ ] Create seed script to add first admin
- [ ] Test all endpoints with Postman/cURL

## 📝 Minimal Backend Code Structure Needed

```python
# FastAPI Backend Structure

# 1. Admin Model (models/admin.py)
class Admin(Base):
    __tablename__ = "admins"
    id = Column(UUID, primary_key=True)
    full_name = Column(String)
    phone_number = Column(String, unique=True)
    email = Column(String, unique=True)
    password = Column(String)
    address = Column(String)
    is_active = Column(Boolean, default=True)
    date_joined = Column(DateTime, default=datetime.utcnow)

# 2. Login Endpoint (routers/auth.py)
@router.post("/auth/login/admin")
async def admin_login(phone: str):
    # Check admin exists
    # Generate OTP
    # Store in Redis: admin_login_otp:{phone}
    # Return success message

# 3. Verify OTP Endpoint (routers/auth.py)
@router.post("/auth/verify-login/admin")
async def verify_admin_login(phone: str, otp: str):
    # Validate OTP from Redis
    # Generate JWT token
    # Return token

# 4. Protected Route (routers/admin.py)
@router.get("/admin/categories/")
async def get_categories(current_admin: Admin = Depends(get_current_admin)):
    # Return categories
```

## 🔑 JWT Token Format Required

Your backend must return JWT with these claims:
```json
{
  "sub": "admin_id",
  "role": "admin",
  "exp": 1234567890
}
```

## 🚀 Quick Fix Options

### Option A: Ask Backend Developer
Share this document with your backend developer and ask them to implement the missing endpoints.

### Option B: Use Mock Data (Development Only)
I can create a mock admin authentication for Flutter development until backend is ready.

### Option C: Check Existing Endpoints
Maybe the endpoints exist with different paths? Check:
- `/api/v1/auth/login/admin`
- `/auth/admin/login`
- `/admin/auth/login`

## 📞 Next Steps

1. **Contact your backend developer** with this document
2. **Ask them to implement** the 3 missing endpoints
3. **Test with cURL** before testing in Flutter
4. **Once working**, your Flutter app will automatically work

## 🐛 Current Flutter Error Messages

When you try to login as admin, you'll see:
```
❌ Admin authentication not configured on server. Please contact administrator.
```

This is expected because the backend endpoints don't exist yet.

## ✅ When Backend is Fixed

Once your backend developer implements the endpoints:
1. Restart your Flutter app
2. Login as admin
3. You should see:
   ```
   ✅ TOKEN SAVED SUCCESSFULLY (XXX chars)
   ```
4. Navigate to Categories
5. Categories will load successfully

---

**Your Flutter app is 100% ready. The issue is purely backend.**
