from newspaper import Article
import numpy as np
import pandas as pd
from bs4 import BeautifulSoup

prefix = "https://dx.doi.org/"

de = pd.read_csv("Data/DiscoveryEngine/DiscoveryEngine_Dataset_2_28_2018.csv")

abstracts = pd.Series(name = "abstract")

for doi in de["manuscript_DOI"]:
	url = prefix + doi
	