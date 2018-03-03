import numpy as np
import pandas as pd
import urllib.request
from bs4 import BeautifulSoup
import re

prefix = "https://www.ncbi.nlm.nih.gov/pubmed/?term="
suffix = "&report=abstract&format=text"

de = pd.read_csv("Data/DiscoveryEngine/DiscoveryEngine_Dataset_2_28_2018.csv")
dois = de["manuscript_DOI"].unique()

# authors = pd.Series(name = "authors")
abstracts = pd.Series(name = "abstract")

for i in range(len(dois)):
	d = re.sub("/", "%2F", dois[i])
	url = prefix + d + suffix
	print(str(i) + " / " + str(len(dois)) + ": " + url)
	page = urllib.request.urlopen(url)
	soup = BeautifulSoup(page, "html.parser")
	soup_split = soup.text.split("\n\n")

	count = 0
	for i in soup_split:
		if i.split(" ")[0] == "DOI:":
			count += 1
	if len(soup_split) < 3 or count > 1:
		abstract = ""
	else:
		abstract = soup_split[5]
		if abstract.split(" ")[0] == "Comment" or abstract.split(" ")[0] == "Erratum":
			abstract = soup_split[6]
			if abstract.split(" ")[0] == "Update":
				abstract = soup_split[7]
		if abstract.split(" ")[0] == "DOI:":
			abstract = soup_split[4]
	abstract = re.sub("\n", " ", abstract)
	# authors = authors.append(pd.Series([article.authors]))
	abstracts = abstracts.append(pd.Series([re.sub(",", "", abstract)]))

abstracts_table = pd.DataFrame(data = { "doi" : dois, "abstract" : abstracts })

abstracts_table.to_csv("abstracts.csv")