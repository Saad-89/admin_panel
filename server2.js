// const express = require('express');
// const axios = require('axios');
// const cors = require('cors');

// const app = express();
// const port = process.env.PORT || 3000;

// app.use(express.json());
// app.use(cors());

// app.get('/places/details', async (req, res) => {
//   try {
//     const placeId = req.query.placeId;
//     const apiKey = 'AIzaSyBMfLAQ0VJVMikgS7RsJz5pGmDVd6Dt6lE'; // Replace with your actual Google API key
//     const apiUrl = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&fields=geometry&key=${apiKey}`;
    
//     const response = await axios.get(apiUrl);
//     if (response.status === 200) {
//       const data = response.data;
//       if (data.status === 'OK') {
//         const lat = data.result.geometry.location.lat;
//         const lng = data.result.geometry.location.lng;
//         console.log(`LatLng: ${lat} ${lng}`);
//         res.json({ lat, lng });
//       } else {
//         res.status(400).json({ error: 'Place details not found' });
//       }
//     } else {
//       res.status(500).json({ error: 'An error occurred' });
//     }
//   } catch (error) {
//     console.error('Error:', error.message);
//     res.status(500).json({ error: 'An error occurred' });
//   }
// });

// app.listen(port, () => {
//   console.log(`Server is running on port ${port}`);
// });
