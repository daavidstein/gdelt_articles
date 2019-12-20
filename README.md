# gdelt_articles
Project for Practical Data Science involving the GDELT dataset
 
 
<pre>
.
├── README.md
├── final_product
│   ├── ml
│   │   └── models.ipynb
│   ├── scraping
│   │   └── asynch_scrape.py #retrieves articles corresponding to SOURCEURL in GDELT events using asynchronous HTTP requests
│   └── shiny # this shiny app allows users to look at article sentiments and locations for the entire or filtered subset of the sample data.    
│       ├── server.R
│       └── ui.R
└── not_final_product
    ├── DataExploration # contains several R markdown files that explore the data, as well as the locations of events from a subset of GDELT articles.
    │   ├── EDA.Rmd
    │   ├── EDA.html
    │   ├── EDA_Maps.Rmd
    │   └── images
    │       └── newplot.png
    ├── notebooks
    │   ├── Untitled.ipynb
    │   ├── Untitled1.ipynb
    │   ├── Untitled2.ipynb
    │   ├── exploring_FLAIR.ipynb
    │   ├── gdelt_models_test.ipynb
    │   ├── get_entities.ipynb
    │   ├── map.ipynb
    │   ├── map2.ipynb
    │   ├── map3.ipynb
    │   ├── person_centrality.ipynb
    │   └── scraping_example-Copy1.ipynb
    ├── person_to_person_weight_matrix.npy
    └── scraping
        ├── gdelt_api.ipynb
        ├── get_content.py
        ├── psyco3.py
        ├── scrape_sample.html
        └── scraping_example.ipynb

9 directories, 26 files
</pre>
