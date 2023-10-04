// const express = require('express');
// const axios = require('axios');
// const cors = require('cors'); // Import the cors package

// const app = express();
// const port = process.env.PORT || 5000;

// app.use(express.json());

// // Use the cors middleware
// app.use(cors());

// app.get('/places/autocomplete', async (req, res) => {
//   try {
//     const input = req.query.input;
//     const apiKey = 'AIzaSyBMfLAQ0VJVMikgS7RsJz5pGmDVd6Dt6lE'; // Replace with your actual Google API key
//     const apiUrl = `https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${input}&key=${apiKey}`;
    
//     const response = await axios.get(apiUrl);
//     res.json(response.data);
//   } catch (error) {
//     console.error('Error:', error.message);
//     res.status(500).json({ error: 'An error occurred' });
//   }
// });

// app.listen(port, () => {
//   console.log(`Server is running on port ${port}`);
// });



