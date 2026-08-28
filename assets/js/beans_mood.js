require('dotenv').config();
const api_key = processFetch.env.API_KEY;

async function getBeans() {
  const params = new URLSearchParams({
    api_key: api_key,
    q: "cat",
    limit: 1,
    rating: "pg",
    lang: "en"
  });
  const url = `https://api.giphy.com/v1/gifs/search?${params}`;

  try {
    const response = await fetch(url);
    if(!response.ok) {
      throw new Error(`Response status: ${response.status}`);
    }

    const result = await res.json();
    console.log(result);
    return result
  } catch(error) {
    console.error(error.message)
  }
}