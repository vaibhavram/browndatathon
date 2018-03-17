# Brown Datathon 2018
Work from Brown Datathon 2018 by Jong Ha Lee and Vaibhav Ramamoorthy

## File Dictionary
### Scripts
spread_table.R - converts original dataset to wide form

get_abstracts.py - scrapes research paper abstracts from PubMed sources

getAltScore.ipynb - uses AltMetric API to retrieve AltMetric scores for each paper

together.R - combines original ratings data, abstract data, and AltMetric data into one table, removes duplicate ratings, and performs regression analyses

TextVisual.R - creates plotly visualization of keywords in abstracts

### Data
ratings.csv - contains wide form of original ratings data table

abstracts.csv - contains results of get_abstracts.py

AltScore.csv - contains results of getAltScore.ipynb

together_data.csv - contains fully-clean dataset from together.R

wordScoreMat.rds - contains keyword scores for TextVisual.R
