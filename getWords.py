
# coding: utf-8

# In[301]:

import pandas as pd
import numpy as np
import urllib.request, json 
import xmltodict
from collections import Counter
import pickle
import time


# In[293]:

mapper = pd.read_csv("Data/PMC-ids.csv")
mapper = mapper[pd.notnull(mapper['PMID'])]
mapper.head()
mapper.shape


# In[294]:

discovery = pd.read_csv("Data/DiscoveryEngine/DiscoveryEngine_Dataset_2_28_2018.csv")
discovery.shape


# In[295]:

discovery = discovery.merge(mapper, how = "left", left_on = "manuscript_DOI", right_on = "DOI")
discovery.shape


# In[296]:

havePMID = discovery.loc[~np.isnan(discovery['PMID'])]
havePMID['PMID'] = havePMID['PMID'].astype(int)
havePMID.shape


# In[304]:

baseurl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id="
retmode = "&retmode=xml&api_key=4253acd8482343f9a87e9563b1a14c873908"


# In[305]:

# VERSION 1
allYears = havePMID['Year'].astype(int)
BuzzDict = {}
MeshDict = {}
idDict = {}
np.random.seed(999)
for y in allYears:
    yearData = mapper.loc[(mapper["Year"] == y) & (~mapper["PMID"].isin(havePMID['PMID']))]
    
    ids = list(yearData['PMID'].unique().astype(int))
    ids = [str(i) for i in ids]
    ids = np.random.choice(ids, size = 1000, replace = False)
    
    allMesh = []
    allKey = []
    track = 1
    
    for i in ids:
        track += 1
        
        # Print line and save temporary changes:
        if track % 200 == 0:
            print("Starting PMID " + i + "....")
            BuzzDict[y] = Counter(allKey)
            idDict[y] = ids
            with open('BuzzwordData.pkl', 'wb') as output:
                pickle.dump(BuzzDict, output, pickle.HIGHEST_PROTOCOL)
                pickle.dump(MeshDict, output, pickle.HIGHEST_PROTOCOL)
                pickle.dump(idDict, output, pickle.HIGHEST_PROTOCOL)

        # Open URL, read data
        file = urllib.request.urlopen(baseurl + i + retmode)
        data = file.read()
        file.close()

        # Parse XML data
        data = xmltodict.parse(data)
        
        #Meshwords
        try:
            meshData = data['PubmedArticleSet']['PubmedArticle']['MedlineCitation']['MeshHeadingList']['MeshHeading']
            for di in meshData:
                word = di['DescriptorName']['#text']
                words = word.split(" ")
                allMesh.extend(words)     
        except KeyError:
            pass

        #Keywords
        try:
            keyData = data['PubmedArticleSet']['PubmedArticle']['MedlineCitation']['KeywordList']['Keyword']
            for k in keyData:
                word = k['#text']
                words = word.split(" ")
                allKey.extend(words)        
        except KeyError:
            continue
        time.sleep(0.1 + np.random.uniform(0,0.1))

    BuzzDict[y] = Counter(allKey)
    MeshDict[y] = Counter(allMesh)
    idDict[y] = ids


# In[290]:

with open('BuzzwordData.pkl', 'wb') as output:
    pickle.dump(BuzzDict, output, pickle.HIGHEST_PROTOCOL)
    pickle.dump(MeshDict, output, pickle.HIGHEST_PROTOCOL)
    pickle.dump(idDict, output, pickle.HIGHEST_PROTOCOL)


# In[237]:

# VERSION 2 

# allYears = havePMID['Year'].astype(int)
# allDf = pd.DataFrame()
# #y = 2007
# for y in allYears:
#     yearData = mapper.loc[(mapper["Year"] == y) & (~mapper["PMID"].isin(havePMID['PMID']))]
    
#     ids = list(yearData['PMID'].unique())
#     ids = [str(i) for i in ids]
    
#     yrVec = [y] * len(ids)
#     WordDf = pd.DataFrame({'PMID': ids, 'Year': yrVec})
    
#     allMesh = []
#     allKey = []
#     track = 1
#     for i in ids[:100]:
#         # Print line:
#         #if track % 10 == 0:
#         print("Starting PMID " + i + "....")

#         # Open URL, read data
#         file = urllib.request.urlopen(baseurl + i + retmode)
#         data = file.read()
#         file.close()

#         # Parse XML data
#         data = xmltodict.parse(data)

#         #Meshwords
#         meshWords = []
#         try:
#             meshData = data['PubmedArticleSet']['PubmedArticle']['MedlineCitation']['MeshHeadingList']['MeshHeading']
#             for di in meshData:
#                 word = di['DescriptorName']['#text']
#                 words = word.split(" ")
#                 meshWords.extend(words)     
#         except KeyError:
#             pass
#         allMesh.append(meshWords)

#         #Keywords
#         keyWords = []
#         try:
#             keyData = data['PubmedArticleSet']['PubmedArticle']['MedlineCitation']['KeywordList']['Keyword']
#             for k in keyData:
#                 word = k['#text']
#                 words = word.split(" ")
#                 keyWords.extend(words)        
#         except KeyError:
#             pass
#         allKey.append(keyWords)
#         track += 1
        
#     WordDf['Meshwords'] = allMesh
#     WordDf['Keywords'] = allKey
#     allDf = pd.concat([allDf, WordDf], axis = 1)


# In[ ]:

# JSON PARSING TEST
# with urllib.request.urlopen(baseurl + "17913979" + retmode) as url:
#     data = json.loads(url.read().decode())
#     test = pd.read_json(data['result'], orient = "index")


# MANUAL STRING PARSING TEST
# testURL = urllib.request.urlopen(baseurl + "17913979" + retmode)
# impLines = []
# for line in testURL:
#     if ("b'OT" in str(line)) or ("b'MH" in str(line)):
#         impLines.append(line)
# impLines
# hi = [''.join(e for e in str(string) if e.isalnum()) for string in impLines]
# hi

