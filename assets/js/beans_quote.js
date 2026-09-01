const BeansQuote = {
  mounted() {
    this.getQuote();

    this.timer = setInterval(() => {
      this.getQuote();
    }, 30_000);
  },

  destroyed() {
    clearInterval(this.timer);
  },
  
  async getQuote() {
    const params = new URLSearchParams({
      "author": "dolly parton"
    });

    const url = `https://quoteslate.vercel.app/api/quotes/random?${params}`;

    try {
      const response = await fetch(url);

      if (!response.ok) {
        throw new Error(`Response status: ${response.status}`)
      }

      const result = await response.json();
      
      if (result) {
        this.el.textContent = `"${result.quote}" - ${result.author}`;
      }
    } catch (error) {
      console.error("Response status", error.message);
    }
  }
};

export default BeansQuote;