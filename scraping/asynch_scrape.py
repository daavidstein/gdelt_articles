import grequests
import psycopg2
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import re
from lxml import html
import csv
from pyspark.sql import Row

def clean(page):

        try:
            tree = html.fromstring(page)
        except:
            return "NA"
        try:
            paras_anchors = tree.xpath('/html/head/title/text()|//p/a/text()|//p/text()')
        except:
            return "NA"
        try:
            content = content_clean(paras_anchors)
        except:
            return "NA"
        return content


def handler(request, exception):
     print("NA")

def asynch(batch):
    rs = (grequests.get(url[0], timeout=0.5) for url in batch)
    urls = [url[0] for url in batch]
    my_content = grequests.map(rs, exception_handler = handler)
    tuples = zip(urls,my_content)
    articles = [(tup[0],clean(tup[1].content)) for tup in tuples if tup[1]]

    return articles

def write_csv(collection):
    with open(r'linear3.csv','a', newline = '') as f:
        writer = csv.writer(f)
        for tup in collection:
            writer.writerow(Row(tup[0],tup[1]))


conn = psycopg2.connect("dbname=gdelt user=daavid")
cur = conn.cursor() 
cur.execute("select sourceurl from random_sample where sourceurl not like '%unrealitytv%' and sourceurl not like '%100freeclassifieds%';")
#the table random_sample consists of 2 million rows from gdelt, randomly sampled, and is identical with the file gdelt_sample.csv we have provided 
# here unrealitytv and 100freeclassifieds were simply two inactive domains which we identified

t = cur.fetchall()
cur.close()
#break the urls up into batches of 10 for making asynchronous requests
parts = [t[i:i + 10] for i in range(0, len(t), 10)]

collection =[]
count = 0

for part in parts:
    print("partition ", count , " of ", len(parts))
    count += 1
    collection.extend(asynch(part)) #make asynchronous requests using the batch
    if count % 200 == 0: #update csv every 200 batches
        write_csv(collection)
        collection = []
