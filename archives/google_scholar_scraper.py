import numpy as np
import pandas as pd
import urllib.request
from bs4 import BeautifulSoup
import re

prefix = "https://scholar.google.com/scholar?hl=en&as_sdt=0%2C40&q="
suffix = "&btnG="