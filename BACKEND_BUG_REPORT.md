# 🐛 CRITICAL BUG: Wrong Role in JWT Token

## 🚨 Issue Summary

**PORT 8001** (Admin/Driver service) is returning `role="customer"` in JWT token and response, causing **403 Forbidden** errors on all admin/driver APIs.

---

## 🔍 Problem Details

### Current Behavior (WRONG):
```http
POST http://43.205.99.220:8001/api/auth/verify-login
Body: {"phone_number": "9876543210", "otp": "123456"}

Response:
{
  "success": true,
  "token": "eyJhbGci...",
  "role": "customer",  ← WRONG! Should be "admin" or "driver"
  "user": {...}
}
```

### JWT Token Payload (WRONG):
```json
{
  "sub": "admin_id",
  "role": "customer",  ← WRONG!
  "exp": 1234567890
}
```

### Result:
When Flutter calls admin APIs:
```http
GET http://43.205.99.220:8001/api/admin/categories/
Authorization: Bearer <token_with_role_customer>

Response: 403 Forbidden
Error: "Not authorized as admin"
```

---

## ✅ Expected Behavior

### For Admin Login:
```http
POST http://43.205.99.220:8001/api/auth/verify-login
Body: {"phone_number": "9876543210", "otp": "123456"}

Response:
{
  "success": true,
  "token": "eyJhbGci...",
  "role": "admin",  ← CORRECT
  "user": {
    "id": "123",
    "full_name": "Admin User",
    ...
  }
}
```

### JWT Token Payload (CORRECT):
```json
{
  "sub": "admin_id",
  "role": "admin",  ← CORRECT
  "exp": 1234567890
}
```

### For Driver Login:
```json
{
  "success": true,
  "token": "eyJhbGci...",
  "role": "driver",  ← CORRECT
  "user": {...}
}
```

---

## 🔧 Root Cause Analysis

The backend is likely:
1. Not checking which table the user belongs to (Admin vs Driver)
2. Hardcoding `role="customer"` in JWT generation
3. Not passing correct role to JWT signing function

---

## 💡 Required Fix

### Step 1: Identify User Type
```python
# In verify-login endpoint
phone = normalize_phone(request.phone_number)

# Check which table user belongs to
admin = db.query(Admin).filter(Admin.phone_number == phone).first()
driver = db.query(Driver).filter(Driver.phone_number == phone).first()

if admin:
    user = admin
    role = "admin"  # ← Set correct role
elif driver:
    user = driver
    role = "driver"  # ← Set correct role
else:
    raise HTTPException(404, "User not found")
```

### Step 2: Generate JWT with Correct Role
```python
def create_jwt_token(user_id: str, role: str):
    payload = {
        "sub": user_id,
        "role": role,  # ← Use the role from Step 1
        "exp": datetime.utcnow() + timedelta(days=7)
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
    return token

# Generate token
token = create_jwt_token(user.id, role)  # ← Pass correct role
```

### Step 3: Return Correct Role in Response
```python
return {
    "success": True,
    "message": "Login successful",
    "token": token,
    "role": role,  # ← Return correct role
    "user": serialize_user(user)
}
```

---

## 🧪 Testing

### Test Admin Login:
```bash
# Step 1: Send OTP
curl -X POST http://43.205.99.220:8001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"9876543210"}'

# Step 2: Verify OTP
curl -X POST http://43.205.99.220:8001/api/auth/verify-login \
  -H "Content-Type: application/json" \
  -d '{"phone_number":"9876543210","otp":"123456"}'

# Expected response:
# {
#   "success": true,
#   "token": "eyJhbGci...",
#   "role": "admin",  ← Check this!
#   "user": {...}
# }
```

### Decode JWT Token:
```bash
# Copy token from response
# Go to https://jwt.io
# Paste token
# Check payload:
# {
#   "sub": "admin_id",
#   "role": "admin",  ← Should be "admin" not "customer"
#   "exp": 1234567890
# }
```

### Test Admin API:
```bash
# Use token from above
curl -X GET http://43.205.99.220:8001/api/admin/categories/ \
  -H "Authorization: Bearer <token>"

# Expected: 200 OK with categories
# Current: 403 Forbidden
```

---

## 📋 Verification Checklist

- [ ] Admin login returns `role="admin"` in response
- [ ] Admin JWT token contains `role="admin"` in payload
- [ ] Driver login returns `role="driver"` in response
- [ ] Driver JWT token contains `role="driver"` in payload
- [ ] Admin APIs accept admin token (no 403)
- [ ] Driver APIs accept driver token (no 403)
- [ ] Customer APIs still work on port 8000

---

## 🎯 Impact

**HIGH PRIORITY** - Blocking all admin and driver functionality.

Without this fix:
- ❌ Admin cannot access admin dashboard
- ❌ Admin cannot manage categories
- ❌ Admin cannot view complaints
- ❌ Driver cannot access driver dashboard
- ❌ Driver cannot accept jobs

---

## 🔄 Workaround (Temporary)

Flutter app now uses `userType` parameter to override incorrect role from backend:
```dart
// If backend returns role="customer" but userType="admin"
// Flutter will save role="admin" instead
```

This allows development to continue, but **backend must be fixed** for production.

---

## 📞 Action Required

**Backend Team:** Please fix the role assignment in JWT token generation on port 8001.

**Priority:** CRITICAL
**Estimated Fix Time:** 30 minutes
**Testing Time:** 15 minutes

---

## ✅ Success Criteria

After fix, this should work:
1. Admin logs in → receives `role="admin"` token
2. Admin calls `/api/admin/categories/` → 200 OK
3. Driver logs in → receives `role="driver"` token
4. Driver calls `/api/driver/jobs/` → 200 OK
5. No more 403 errors for correct user types
