const express = require('express');
const cors = require('cors');
const OpenAI = require('openai');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

const PRICING_SYSTEM_PROMPT = `You are an AI pricing engine for a waste management service. Calculate fair pricing based on:

BASE PRICING RULES:
- Base fare: ₹50-100 (depends on city/zone)
- Distance: ₹10-15 per km
- Urgency: Standard (0%), Fast (+30%), Emergency (+60%)
- Vehicle: Auto (base), Mini Truck (+₹100-200)
- Floor/Stairs: Ground (0%), 1st (+₹20), 2nd (+₹40), 3+ (+₹60), Elevator (-₹10)

CATEGORY MULTIPLIERS:
- Household/Organic: 1.0x
- Plastic/Paper: 1.1x
- E-Waste: 1.5x (hazardous handling)
- Medical/Chemical: 2.0x (special disposal)
- Construction: 1.3x (heavy)

QUANTITY IMPACT:
- Small (1-2 bags): base
- Medium (3-5 bags): +20%
- Large (6+ bags or >50kg): +40%

Calculate min, max, and recommended price. Provide breakdown and assumptions.`;

app.post('/api/estimate-price', async (req, res) => {
  try {
    const {
      category,
      quantity,
      location,
      distance_km,
      urgency,
      floor_info,
      city,
      zone,
      vehicle_size,
    } = req.body;

    const userPrompt = `Calculate pricing for:
Category: ${category}
Quantity: ${quantity}
Location: ${location}
Distance: ${distance_km} km
Urgency: ${urgency}
Floor: ${floor_info}
City: ${city}
Zone: ${zone}
Vehicle: ${vehicle_size}`;

    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: PRICING_SYSTEM_PROMPT },
        { role: 'user', content: userPrompt },
      ],
      response_format: {
        type: 'json_schema',
        json_schema: {
          name: 'price_estimate',
          strict: true,
          schema: {
            type: 'object',
            properties: {
              estimated_price_min: { type: 'number' },
              estimated_price_max: { type: 'number' },
              recommended_price: { type: 'number' },
              breakdown: {
                type: 'object',
                properties: {
                  base_fare: { type: 'number' },
                  distance_charge: { type: 'number' },
                  urgency_charge: { type: 'number' },
                  vehicle_charge: { type: 'number' },
                  floor_charge: { type: 'number' },
                  category_charge: { type: 'number' },
                },
                required: ['base_fare', 'distance_charge', 'urgency_charge', 'vehicle_charge', 'floor_charge', 'category_charge'],
                additionalProperties: false,
              },
              assumptions: {
                type: 'array',
                items: { type: 'string' },
              },
              customer_notes: { type: 'string' },
              driver_notes: { type: 'string' },
            },
            required: ['estimated_price_min', 'estimated_price_max', 'recommended_price', 'breakdown', 'assumptions', 'customer_notes', 'driver_notes'],
            additionalProperties: false,
          },
        },
      },
    });

    const result = JSON.parse(completion.choices[0].message.content);
    res.json(result);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to estimate price', details: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
