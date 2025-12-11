# LiftAway - Brand Identity & Design System

## 🎨 Brand Identity

### App Name
**LiftAway**

### Tagline
**Fast. Simple. Reliable Waste Removal.**

### Brand Style
Premium, clean, modern

---

## 🎨 Color Palette

### Primary Colors
- **Deep Forest Green**: `#0F5132` - `Color(0xFF0F5132)`
  - Used for: Primary buttons, headers, key UI elements
  - Represents: Trust, sustainability, nature

- **Sage Green**: `#D1E7DD` - `Color(0xFFD1E7DD)`
  - Used for: Secondary elements, backgrounds, cards
  - Represents: Calm, freshness, eco-friendly

### Accent Colors
- **Soft Beige**: `#FAF7F2` - `Color(0xFFFAF7F2)`
  - Used for: Page backgrounds, light surfaces
  - Represents: Cleanliness, simplicity, premium feel

### Text Colors
- **Dark Charcoal**: `#1F1F1F` - `Color(0xFF1F1F1F)`
  - Used for: Body text, headings, primary content
  - Ensures: High readability, professional appearance

### Alert Colors
- **Orange**: `#FF6F00` - `Color(0xFFFF6F00)`
  - Used for: Notifications, alerts, warnings
  - Represents: Attention, urgency, action needed

---

## 🎨 Gradient Buttons (CTA)

### Primary Gradient
```dart
LinearGradient(
  colors: [
    Color(0xFF0F5132), // Deep Forest Green
    Color(0xFF198754), // Lighter Green
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

**Usage**: Primary action buttons, CTAs, important interactions

---

## 📐 Design Principles

### 1. Premium Feel
- Clean layouts with ample white space
- Subtle shadows and depth
- High-quality imagery
- Smooth animations

### 2. Simplicity
- Clear hierarchy
- Minimal clutter
- Intuitive navigation
- Easy-to-read typography

### 3. Reliability
- Consistent design patterns
- Clear feedback
- Professional appearance
- Trustworthy visual language

---

## 🔤 Typography

### Headings
- **Font Weight**: Bold (700-800)
- **Color**: Dark Charcoal (#1F1F1F)
- **Letter Spacing**: -0.5px (tight)
- **Style**: Clean, modern, impactful

### Body Text
- **Font Weight**: Regular (400)
- **Color**: Dark Charcoal (#1F1F1F)
- **Line Height**: 1.5
- **Style**: Readable, comfortable

### Tagline
- **Font Weight**: Semi-bold (600)
- **Color**: Deep Forest Green (#0F5132)
- **Letter Spacing**: 0.5px
- **Style**: Distinctive, memorable

---

## 📏 Spacing System

- **XS**: 4px - Tight spacing
- **S**: 8px - Small gaps
- **M**: 16px - Standard spacing
- **L**: 24px - Section spacing
- **XL**: 32px - Large gaps

---

## 🔲 Border Radius

- **S**: 8px - Small elements
- **M**: 12px - Buttons, inputs
- **L**: 16px - Cards, containers
- **XL**: 24px - Large cards, modals

---

## 🌟 Shadows

### Premium Shadow
```dart
BoxShadow(
  color: Color(0xFF0F5132).withOpacity(0.1),
  blurRadius: 20,
  offset: Offset(0, 4),
)
```
**Usage**: Important cards, elevated elements

### Soft Shadow
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 10,
  offset: Offset(0, 2),
)
```
**Usage**: Standard cards, subtle elevation

---

## 🎯 Component Guidelines

### Buttons
- **Primary**: Gradient green background, white text
- **Secondary**: Sage green background, dark text
- **Outline**: Border with deep forest green, transparent background
- **Border Radius**: 12px
- **Padding**: 16px horizontal, 12px vertical

### Cards
- **Background**: White or Soft Beige
- **Border Radius**: 16px
- **Shadow**: Soft shadow
- **Padding**: 16-24px

### Inputs
- **Background**: Soft Beige or light gray
- **Border**: None (filled style)
- **Border Radius**: 12px
- **Focus**: Deep Forest Green border

### Icons
- **Primary**: Deep Forest Green
- **Secondary**: Sage Green
- **Size**: 20-24px standard, 32-48px for featured

---

## 🌐 Web-Specific

### Meta Tags
```html
<meta name="theme-color" content="#0F5132">
<meta name="description" content="LiftAway - Fast. Simple. Reliable Waste Removal.">
```

### Manifest
```json
{
  "name": "LiftAway - Waste Management",
  "short_name": "LiftAway",
  "theme_color": "#0F5132",
  "background_color": "#FAF7F2"
}
```

---

## 📱 Implementation

### Flutter Theme
Located in: `lib/core/theme/app_theme.dart`

### Brand Constants
Located in: `lib/core/constants/brand_constants.dart`

### Usage Example
```dart
import 'package:waste_management_app/core/constants/brand_constants.dart';

// Using brand colors
Container(
  decoration: BoxDecoration(
    gradient: BrandConstants.ctaGradient,
    borderRadius: BorderRadius.circular(BrandConstants.radiusM),
    boxShadow: BrandConstants.premiumShadow,
  ),
  child: Text(
    BrandConstants.tagline,
    style: BrandConstants.taglineStyle,
  ),
)
```

---

## ✅ Brand Checklist

- [x] Color palette defined
- [x] Typography system established
- [x] Spacing system created
- [x] Component guidelines documented
- [x] Web meta tags updated
- [x] App manifest updated
- [x] Theme files updated
- [x] Brand constants created

---

## 🚀 Next Steps

1. Update app icons with LiftAway branding
2. Create branded splash screen
3. Design marketing materials
4. Update screenshots for app stores
5. Create brand guidelines PDF
6. Design email templates
7. Create social media assets

---

**Brand Version**: 1.0  
**Last Updated**: 2024  
**Maintained By**: LiftAway Team
