import psycopg2
import findspark
findspark.init()
import pyspark
from pyspark import SparkContext
from pyspark.sql import SQLContext
from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from pyspark import SparkConf
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import re
from lxml import html
import csv
import grequests

def content_clean(content):
    '''remove unicode characters'''

    joined = " ".join(content)
    content_ascii = re.sub(r'[^\x00-\x7f]',r'', joined).replace('\r', '').replace('\n', '').replace('\t', '')

    return content_ascii

def get_content(url, session):
    '''retrieve article content and add it to row, using novetta  csv schema'''
    
    #add "content" to columns if it isn't already there

  
    
    try: #handle HTTP request errors
 
        page = session.get(url,timeout=2)
        page.raise_for_status()
        tree = html.fromstring(page.content)
        paras_anchors = tree.xpath('/html/head/title/text()|//p/a/text()|//p/text()')

        content = content_clean(paras_anchors)
        return content
    
    except requests.exceptions.ConnectionError:
       # r.status_code = "Connection refused"
        return "NA"
    except requests.exceptions.HTTPError as e:
       	 return "NA"
    except:
        return "NA"
def my_map(row):
  with  requests.Session() as session:
      retry = Retry(connect=1, backoff_factor=0.5)
      user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'
      adapter = HTTPAdapter(max_retries=retry)

      session.mount('http://', adapter)
      session.mount('https://', adapter)
      session.headers.update({'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36'})
      return (row[0], get_content(row[0], session))



def handler(request, exception):
    return "NA"


def toCSVLine(data):
  return ','.join([str(d) for d in data])

conn = psycopg2.connect("dbname=gdelt user=daavid")
cur = conn.cursor() #(The cursor object allows interaction with the database.)
#cur.execute("select sourceurl from florida where sourceurl != 'unspecified' and sourceurl not like '%,%';")
#cur.execute("select sourceurl from good_florida_urls where sourceurl not like '%unrealitytv%' and sourceurl not like '%100freeclassifieds%' limit 100000;")
cur.execute("select sourceurl from random_sample where sourceurl not like '%unrealitytv%' and sourceurl not like '%100freeclassifieds%' limit 100;")
t = cur.fetchall()
parts = [t[i:i + 10] for i in range(0, len(t), 10)]


rs = (grequests.get(url[0]) for url in t) 
#my_content = grequests.map(rs)
print(my_content)

#for r in my_content:
#    print(r.text)
#print(grequests.map(rs1))
