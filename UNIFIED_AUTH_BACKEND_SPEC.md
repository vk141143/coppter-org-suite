# 🔐 Unified Authentication Backend Specification

## 📋 Overview

This document specifies the **EXACT** authentication flow required for both backend services.

### Services Architecture
- **PORT 8000**: Customer Service
- **PORT 8001**: Admin + Driver Service (shared)

---

## 🎯 Critical Requirements

### 1. Unified Response Structure

**ALL** OTP verification endpoints MUST return this exact structure:

```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "customer|admin|driver",
  "user": {
    "id": "uuid-or-number",
    "full_name": "John Doe",
    "email": "john@example.com",
    "phone_number": "9876543210",
    "gender": "male|female|other",
    "address": "123 Street",
    "profile_image": "https://...",
    "is_verified": true,
    "is_active": true,
    "created_at": "2025-01-01T10:20:30Z",
    "updated_at": "2025-02-15T12:00:00Z",
    
    // Driver-specific (if role=driver)
    "driver_license": "KA05-2022-XXXX",
    "vehicle_number": "KA05MM1234",
    "vehicle_type": "Bike",
    "zone": "Koramangala",
    
    // Admin-specific (if role=admin)
    "admin_level": "super_admin"
  }
}
```

### 2. Phone Number Format (CRITICAL)

**MUST** use consistent format everywhere:
- ✅ Correct: `"9876543210"` (digits only, no +)
- ❌ Wrong: `"+919876543210"` or `"91-9876543210"`

**Apply to:**
- Registration
- Login
- OTP verification
- Database storage
- Redis keys

---

## 🔌 API Endpoints Specification

### PORT 8000 - Customer Service

#### 1. Customer Login - Send OTP
```http
POST http://43.205.99.220:8000/api/auth/login/customer
Content-Type: application/json

{
  "phone_number": "9876543210"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent to your phone"
}
```

#### 2. Customer Login - Verify OTP
```http
POST http://43.205.99.220:8000/api/auth/verify-login/customer
Content-Type: application/json

{
  "phone_number": "9876543210",
  "otp": "123456"
}
```

**Response:** (MUST include token + role + user)
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "customer",
  "user": {
    "id": "123",
    "full_name": "John Doe",
    "phone_number": "9876543210",
    "email": "john@example.com",
    "is_verified": true,
    "is_active": true
  }
}
```

#### 3. Customer Registration - Send OTP
```http
POST http://43.205.99.220:8000/api/auth/register/customer
Content-Type: application/json

{
  "full_name": "John Doe",
  "phone_number": "9876543210",
  "email": "john@example.com",
  "password": "password123",
  "address": "123 Street"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent for verification"
}
```

#### 4. Customer Registration - Verify OTP
```http
POST http://43.205.99.220:8000/api/auth/verify-registration/customer
Content-Type: application/json

{
  "phone_number": "9876543210",
  "otp": "123456"
}
```

**Response:** (MUST include token + role + user)
```json
{
  "success": true,
  "message": "Registration successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "customer",
  "user": { ... }
}
```

---

### PORT 8001 - Admin + Driver Service

#### 1. Admin/Driver Login - Send OTP
```http
POST http://43.205.99.220:8001/api/auth/login
Content-Type: application/json

{
  "phone_number": "9876543210"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent to your phone"
}
```

**Backend Logic:**
```python
# Check if phone exists in Admin table OR Driver table
admin = db.query(Admin).filter(Admin.phone_number == phone).first()
driver = db.query(Driver).filter(Driver.phone_number == phone).first()

if not admin and not driver:
    raise HTTPException(404, "User not found")

# Generate OTP
otp = generate_otp()

# Store in Redis with phone as key
redis.setex(f"login_otp:{phone}", 300, otp)  # 5 min expiry

# Send OTP via SMS
send_sms(phone, otp)
```

#### 2. Admin/Driver Login - Verify OTP
```http
POST http://43.205.99.220:8001/api/auth/verify-login
Content-Type: application/json

{
  "phone_number": "9876543210",
  "otp": "123456"
}
```

**Response for Admin:**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "admin",
  "user": {
    "id": "456",
    "full_name": "Admin User",
    "phone_number": "9876543210",
    "email": "admin@example.com",
    "admin_level": "super_admin",
    "is_verified": true,
    "is_active": true
  }
}
```

**Response for Driver:**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "driver",
  "user": {
    "id": "789",
    "full_name": "Driver User",
    "phone_number": "9876543210",
    "driver_license": "KA05-2022-XXXX",
    "vehicle_number": "KA05MM1234",
    "vehicle_type": "Bike",
    "zone": "Koramangala",
    "is_verified": true,
    "is_active": true
  }
}
```

**Backend Logic:**
```python
# Verify OTP from Redis
stored_otp = redis.get(f"login_otp:{phone}")
if not stored_otp or stored_otp != otp:
    raise HTTPException(400, "Invalid OTP")

# Delete OTP
redis.delete(f"login_otp:{phone}")

# Check if admin or driver
admin = db.query(Admin).filter(Admin.phone_number == phone).first()
driver = db.query(Driver).filter(Driver.phone_number == phone).first()

if admin:
    role = "admin"
    user = admin
elif driver:
    role = "driver"
    user = driver
else:
    raise HTTPException(404, "User not found")

# Generate JWT token
token = create_jwt_token(user.id, role)

# Return unified response
return {
    "success": True,
    "message": "Login successful",
    "token": token,
    "role": role,
    "user": serialize_user(user)
}
```

#### 3. Admin Registration - Send OTP
```http
POST http://43.205.99.220:8001/api/auth/register/admin
Content-Type: application/json

{
  "full_name": "Admin User",
  "phone_number": "9876543210",
  "email": "admin@example.com",
  "password": "password123",
  "address": "123 Street"
}
```

#### 4. Driver Registration - Send OTP
```http
POST http://43.205.99.220:8001/api/auth/register/driver
Content-Type: application/json

{
  "full_name": "Driver User",
  "phone_number": "9876543210",
  "driver_license": "KA05-2022-XXXX",
  "vehicle_number": "KA05MM1234",
  "vehicle_type": "Bike"
}
```

---

## 🔑 JWT Token Specification

### Token Payload
```json
{
  "sub": "user_id",
  "role": "customer|admin|driver",
  "phone_number": "9876543210",
  "exp": 1234567890
}
```

### Token Generation
```python
from datetime import datetime, timedelta
import jwt

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"

def create_jwt_token(user_id: str, role: str, phone: str):
    expire = datetime.utcnow() + timedelta(days=7)
    payload = {
        "sub": user_id,
        "role": role,
        "phone_number": phone,
        "exp": expire
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    return token
```

### Token Verification
```python
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(401, "Token expired")
    except jwt.JWTError:
        raise HTTPException(403, "Invalid token")

async def get_current_admin(payload: dict = Depends(verify_token)):
    if payload.get("role") != "admin":
        raise HTTPException(403, "Admin access required")
    return payload

async def get_current_driver(payload: dict = Depends(verify_token)):
    if payload.get("role") != "driver":
        raise HTTPException(403, "Driver access required")
    return payload
```

---

## 🐛 Critical Fixes Required

### Issue 1: Admin OTP Verification Returns 404

**Problem:**
```
POST /api/auth/verify-login
Body: {"phone_number": "9876543210", "otp": "123456"}
Response: 404 "Admin not found"
```

**Root Cause:**
- Phone number format mismatch in database
- Registration saves: `"+919876543210"`
- Verification searches: `"9876543210"`

**Fix:**
```python
# Normalize phone number before saving/searching
def normalize_phone(phone: str) -> str:
    # Remove all non-digits
    phone = re.sub(r'\D', '', phone)
    # Remove country code if present
    if phone.startswith('91') and len(phone) > 10:
        phone = phone[2:]
    return phone

# Use in all endpoints
phone = normalize_phone(request.phone_number)
```

### Issue 2: Missing Role in Response

**Problem:**
Response doesn't include `role` field

**Fix:**
Always include `role` in verify-login response:
```python
return {
    "success": True,
    "token": token,
    "role": "admin",  # ← MUST INCLUDE
    "user": user_data
}
```

### Issue 3: Inconsistent Response Structure

**Problem:**
- Customer service returns: `{"token": "..."}`
- Admin service returns: `{"access_token": "..."}`

**Fix:**
Use `"token"` consistently across both services

---

## 🧪 Testing Checklist

### Customer Service (PORT 8000)
- [ ] Login sends OTP
- [ ] Verify OTP returns token + role="customer" + user
- [ ] Registration sends OTP
- [ ] Verify registration returns token + role + user
- [ ] Phone format is consistent

### Admin Service (PORT 8001)
- [ ] Login sends OTP for admin
- [ ] Verify OTP returns token + role="admin" + user
- [ ] Registration sends OTP
- [ ] Verify registration returns token + role + user
- [ ] Phone format is consistent

### Driver Service (PORT 8001)
- [ ] Login sends OTP for driver
- [ ] Verify OTP returns token + role="driver" + user
- [ ] Registration sends OTP
- [ ] Verify registration returns token + role + user
- [ ] Phone format is consistent

### Protected Routes
- [ ] Admin routes verify JWT token
- [ ] Driver routes verify JWT token
- [ ] Customer routes verify JWT token
- [ ] 403 returned for invalid/missing token
- [ ] 401 returned for expired token

---

## 📱 Flutter Integration

Once backend is fixed, Flutter will automatically:

1. **Extract token** from response
2. **Save to localStorage** (web) or SharedPreferences (mobile)
3. **Extract role** and save
4. **Extract user** data and save
5. **Redirect** based on role:
   - `role="customer"` → Customer Dashboard
   - `role="admin"` → Admin Dashboard
   - `role="driver"` → Driver Dashboard
6. **Attach token** to all API requests:
   ```
   Authorization: Bearer <token>
   ```

---

## 🚀 Implementation Priority

### High Priority (Blocking Flutter)
1. ✅ Fix phone number format consistency
2. ✅ Add `role` field to verify-login response
3. ✅ Add `user` object to verify-login response
4. ✅ Fix "Admin not found" error
5. ✅ Return `token` (not `access_token`)

### Medium Priority
6. ✅ Implement JWT token generation
7. ✅ Implement token verification middleware
8. ✅ Protect admin/driver routes

### Low Priority
9. ✅ Add comprehensive error messages
10. ✅ Add logging for debugging

---

## 📞 Support

Share this document with your backend team. Flutter app is ready and waiting for these backend changes.

**No Flutter code changes needed once backend is fixed.**
