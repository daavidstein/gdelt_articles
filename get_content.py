import pandas as pd
import requests
import re
from lxml import html

def get_content(row):
    '''retrieve article content and add it to row'''
    
    #add "content" to columns if it isn't already there
    if "content" not in row.index:
       row = row.reindex(list(row.index) +["content"])

    url = row["source"]
    page = requests.get(url)
    
    try: #handle HTTP request errors
        page.raise_for_status()
        tree = html.fromstring(page.content)
        paras_anchors = tree.xpath('/html/head/title/text()|//p/a/text()|//p/text()')

        row.loc['content'] = content_clean(paras_anchors)
        return row
    
    except requests.exceptions.HTTPError as e:
        return "NA"
    


def content_clean(content):
    '''remove unicode characters'''

    joined = " ".join(content)
    content_ascii = re.sub(r'[^\x00-\x7f]',r'', joined).replace('\r', '').replace('\n', '').replace('\t', '')

    return content_ascii



def scrap(df):
    '''apply get_content to every row of given dataframe and return the resulting dataframe'''

    new_df = df.apply(get_content, axis = 1)
    
    return new_df


if __name__ == "__main__":

    gdelt = pd.read_csv("GDELT_events.csv")
    #articles = gdelt.head(10).apply(get_content, axis = 1)["content"]
    articles = scrap(gdelt.head(10))
    print(articles.loc["content"])
    print(articles.iloc[6]["content"])

