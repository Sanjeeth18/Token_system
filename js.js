fetchRecipes = async (searchQuery) => {
  try {
    const response = await axios.get(
      `https://api.apilayer.com/spoonacular/recipes/complexSearch?query=${searchQuery}`,
      {
        headers: {
          apikey: "V41UEkZYz0GjaAxzBgILrWJeyJ9GiGGR",
        },
      }
    );
    setRecipes(response.data.results || []);
  } catch (err) {
    console.error("Error fetching recipes", err);
  }
};

const fetchCryptoNews = async () => {
  try {
    const response = await axios.get(
      "https://cryptocurrency-news2.p.rapidapi.com/v1/cryptodaily",
      {
        headers: {
          "x-rapidapi-key": "ef935326bfmshfb8ab2f8c3edea5p159c91jsnf49eb3a31644",
          "x-rapidapi-host": "cryptocurrency-news2.p.rapidapi.com",
        },
      }
    );
    console.log("Crypto News:", response.data);
    setCryptoNews(response.data.data || []); 
  } catch (err) {
    setError(
      `Error fetching crypto news: ${err.response?.status} - ${
        err.response?.data?.message || err.message
      }`
    );
  }
};
