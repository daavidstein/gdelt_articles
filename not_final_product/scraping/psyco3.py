import psycopg2
import findspark
findspark.init()
import pyspark
from pyspark import SparkContext
from pyspark.sql import SQLContext
from pyspark.sql import SparkSession
import requests
import re
from lxml import html
import csv

def content_clean(content):
    '''remove unicode characters'''

    joined = " ".join(content)
    content_ascii = re.sub(r'[^\x00-\x7f]',r'', joined).replace('\r', '').replace('\n', '').replace('\t', '')

    return content_ascii

def get_content(url):
    '''retrieve article content and add it to row, using novetta  csv schema'''
    
    #add "content" to columns if it isn't already there

  
    page = requests.get(url)
    
    try: #handle HTTP request errors
        page.raise_for_status()
        tree = html.fromstring(page.content)
        paras_anchors = tree.xpath('/html/head/title/text()|//p/a/text()|//p/text()')

        content = content_clean(paras_anchors)
        return content
    
    except requests.exceptions.HTTPError as e:
        return "NA"

def my_map(row):
  return (row[0], get_content(row[0]))

def toCSVLine(data):
  return ','.join([str(d) for d in data])

conn = psycopg2.connect("dbname=gdelt user=daavid")
cur = conn.cursor() #(The cursor object allows interaction with the database.)
cur.execute("select sourceurl from florida where sourceurl != 'unspecified' and sourceurl not like '%,%';")
t = cur.fetchall()

sc = SparkContext("local[*]", "My App")
urls = sc.parallelize(t)
cur.close()
url_content = urls.map(my_map)
spark = SparkSession \
    .builder \
    .appName("Python Spark SQL basic example") \
    .config("spark.some.config.option", "some-value") \
    .getOrCreate()

df = url_content.toDF(['sourceurl','content']).dropDuplicates()
df.createGlobalTempView("gdelt_df")
my_head = spark.sql("select * from global_temp.gdelt_df limit 10")
results = my_head.collect()
