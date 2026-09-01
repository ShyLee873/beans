async function getBeans(query, apiKey) {
  const params = new URLSearchParams({
    api_key: apiKey,
    q: query,
    limit: 5,
    rating: "pg",
    lang: "en"
  });
  const url = `https://api.giphy.com/v1/gifs/search?${params}`;

  try {
    const response = await fetch(url);
    if(!response.ok) {
      throw new Error(`Response status: ${response.status}`);
    }
    console.log(params)
    const result = await response.json();

    const gifs = result.data;
    const randomGif = gifs[Math.floor(Math.random() * gifs.length)];

    return randomGif;
  } catch (error) {
    console.error(error.message)
  }
}

const BeansMood = {
  async mounted() {
    await this.updateBeans();
  },

  async updated() {
    await this.updateBeans();
  },

  async updateBeans() {
    const query = this.el.dataset.query;
    const apiKey = this.el.dataset.apiKey
    const gif = await getBeans(query, apiKey);

    if (gif) {
      this.el.innerHTML = `
        <img 
          src ="${gif.images.fixed_height.url}"
          alt="${query}"
        />
      `
    }
  }
};

export default BeansMood;