from newspaper import Article
import numpy as np
import pandas as pd
from bs4 import BeautifulSoup
import re

prefix = "https://dx.doi.org/"

de = pd.read_csv("Data/DiscoveryEngine/DiscoveryEngine_Dataset_2_28_2018.csv")
dois = de["manuscript_DOI"].unique()

authors = pd.Series(name = "authors")
abstracts = pd.Series(name = "abstract")

for doi in dois[0:20]:
	url = prefix + doi
	print("getting " + url)
	article = Article(url)
	article.download()
	article.parse()
	authors = authors.append(pd.Series([article.authors]))
	abstracts = abstracts.append(pd.Series([re.sub("\n", "\n", re.sub(",", "", article.text))]))

abstracts_table = pd.DataFrame(data = { "doi" : dois[0:20], "authors" : authors, "abstract" : abstracts })

abstracts_table.to_csv("test.csv")