# Category ID Fix Summary

## Problem
The UI was sending `category_id = -1` to `POST /api/customer/issue`, causing a 500 error because the backend requires a valid category_id (foreign key).

## Root Cause
The Flutter app was using `AppConstants.wasteCategories.indexWhere()` which:
1. Returns the **index** in a local hardcoded array (0-9)
2. Returns **-1** when no match is found
3. Does NOT use the actual database category IDs from the backend

## Solution Applied

### Frontend Changes (Flutter)

#### 1. Updated `raise_complaint_mobile.dart`
- Added `CategoryService` to fetch real categories from backend
- Added `_selectedCategoryId` to store the actual database ID
- Changed category selection to use real category IDs instead of array indices
- Added validation to ensure category_id is never null before submission

#### 2. Updated `raise_complaint_web.dart`
- Same changes as mobile version
- Updated `WebCategorySelector` to pass both category name and ID

#### 3. Updated `web_category_selector.dart`
- Modified to accept categories as props from parent
- Updated callback to pass both `categoryName` and `categoryId`
- Removed internal category fetching (now handled by parent)

### Key Changes

**Before:**
```dart
final categoryIndex = AppConstants.wasteCategories.indexWhere(
  (cat) => cat['name'] == _selectedCategory,
);

final response = await _issueService.createIssue(
  categoryId: categoryIndex,  // Could be -1!
  ...
);
```

**After:**
```dart
if (_selectedCategoryId == null) {
  throw Exception('Please select a valid category');
}

final response = await _issueService.createIssue(
  categoryId: _selectedCategoryId!,  // Real database ID
  ...
);
```

### Backend Recommendation

Add better error logging in the Python backend:

```python
@app.post("/api/customer/issue")
async def create_issue(issue_data: IssueCreate):
    try:
        # Validate category_id exists
        if issue_data.category_id < 1:
            raise HTTPException(400, "Invalid category_id. Must be a positive integer.")
        
        # Check if category exists
        category = db.query(Category).filter(Category.id == issue_data.category_id).first()
        if not category:
            raise HTTPException(404, f"Category with id {issue_data.category_id} not found")
        
        # Create issue
        new_issue = Issue(**issue_data.dict())
        db.add(new_issue)
        db.commit()
        db.refresh(new_issue)
        return new_issue
        
    except Exception as e:
        print(f"❌ Issue creation error: {type(e).__name__}: {str(e)}")
        print(f"📦 Request data: {issue_data.dict()}")
        raise HTTPException(500, f"Failed to create issue: {str(e)}")
```

## Request Body Format

The UI now sends the correct format:

```json
{
  "category_id": 1,
  "description": "Large furniture items for pickup",
  "pickup_location": "123 Main Street, City",
  "images": ["path/to/image1.jpg", "path/to/image2.jpg"],
  "amount": 45.50
}
```

## Testing Checklist

- [x] UI fetches categories from `GET /api/admin/categories/`
- [x] UI stores real category IDs from backend
- [x] UI validates category is selected before submission
- [x] UI sends valid category_id (never -1)
- [ ] Backend validates category_id > 0
- [ ] Backend checks category exists in database
- [ ] Backend logs detailed error messages
- [ ] Backend returns clear error messages to UI

## Files Modified

1. `lib/features/raise_complaint/screens/raise_complaint_mobile.dart`
2. `lib/features/raise_complaint/screens/raise_complaint_web.dart`
3. `lib/features/raise_complaint/widgets/web_category_selector.dart`

## No Changes Needed

- `lib/core/services/issue_service.dart` - Already sends correct format
- `lib/core/services/category_service.dart` - Already fetches from backend
- Backend timestamp handling - Backend auto-generates `created_at`
