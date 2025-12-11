# Waste Management Backend API

AI-powered pricing engine for waste pickup requests using OpenAI GPT-4o-mini.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Environment variables are already configured in `.env`:
- `OPENAI_API_KEY`: Your OpenAI API key
- `PORT`: Server port (default: 3000)

3. Start the server:
```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

## API Endpoints

### POST /api/estimate-price

Calculates AI-powered pricing for waste pickup.

**Request Body:**
```json
{
  "category": "Plastic Waste",
  "quantity": "2 bags",
  "location": "123 Main Street",
  "distance_km": 3.5,
  "urgency": "Standard",
  "floor_info": "2nd Floor",
  "city": "Mumbai",
  "zone": "South Mumbai",
  "vehicle_size": "Auto"
}
```

**Response:**
```json
{
  "estimated_price_min": 150,
  "estimated_price_max": 250,
  "recommended_price": 200,
  "breakdown": {
    "base_fare": 80,
    "distance_charge": 52,
    "urgency_charge": 0,
    "vehicle_charge": 0,
    "floor_charge": 40,
    "category_charge": 28
  },
  "assumptions": [
    "Standard urgency with no rush charges",
    "Auto vehicle suitable for 2 bags",
    "2nd floor requires manual carrying"
  ],
  "customer_notes": "Fair price for your waste pickup",
  "driver_notes": "2nd floor pickup, prepare accordingly"
}
```

## Pricing Rules

The AI uses these base rules:

- **Base fare**: ₹50-100
- **Distance**: ₹10-15 per km
- **Urgency**: Standard (0%), Fast (+30%), Emergency (+60%)
- **Vehicle**: Auto (base), Mini Truck (+₹100-200)
- **Floor**: Ground (0%), 1st (+₹20), 2nd (+₹40), 3+ (+₹60)
- **Category multipliers**: Household (1.0x), E-Waste (1.5x), Medical (2.0x)

## Security

- API key is stored in `.env` (never committed to git)
- CORS enabled for Flutter web app
- Structured JSON responses using OpenAI JSON Schema mode
