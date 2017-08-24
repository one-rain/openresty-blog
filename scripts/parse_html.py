# coding=utf-8

import sys
import MySQLdb
from datetime import *

filepath = sys.argv[1]
array = filepath.split("/")
category = array[1]
filename = array[3]

print "filepath: " + filepath

dict = {'id': '', 'name': filename, 'category': category, 'tag': '', 'title': '', 'img': '',
        'intro': '', 'tag_id': '', 'tag_name': '', 'body': ''}


def getIntro(line, bodyDict, markDict):
    for k in markDict:
        if markDict[k] < 2:
            se = "<" + k + ">"
            ee = "</" + k + ">"

            if line.find(se) >= 0:
                if line.find(ee) > 0:
                    bodyDict[k] = line[len(se):(len(line) - len(ee) - 1)]
                    markDict[k] = 2
                else:
                    bodyDict[k] = bodyDict[k] + line[len(se):len(line)]
                    markDict[k] = 1
            elif line.find(ee) >= 0:
                bodyDict[k] = bodyDict[k] + line[0:(len(line) - len(ee) - 1)]
                markDict[k] = 2
            else:
                if markDict[k] == 1:
                    bodyDict[k] = bodyDict[k] + line
                    markDict[k] = 1


def parse_html():
    file_html = open("/opt/apps/nginx-apps/blog/" + filepath)
    body = ''
    flag_body = False
    flag_note = False
    markDict = {"id": 0, "tag": 0, "title": 0, "img": 0, "intro": 0}
    for line in file_html.xreadlines():
        #line = line.strip('\n')
        if line.find("<body>") >= 0:
            flag_body = True
        elif flag_body:
            if line.find("<!--intro") >= 0:
                flag_note = True
            elif line.find("intro-->") >= 0:
                flag_note = False

            if flag_note:
                getIntro(line, dict, markDict)

            body = body + line

    dict['body'] = body

    #print "id: " + dict['id']
    #print "tag: " + dict['tag']
    #print "title: " + dict['title']
    #print "img: " + dict['img']
    #print "intro: " + dict['intro']
    #print "body: " + dict['body']
    return dict

def update_data(dict):
    conn = MySQLdb.connect(host='127.0.0.1', user='mysql_blog', passwd='mysqBlogPWD2016', db='blog', charset='utf8')
    cur = conn.cursor()
    try:
        tag_id = []
        # update tag
        tag_arr = dict['tag'].split(",")
        for tag in tag_arr:
            tag = tag.strip()
            sql = "SELECT id FROM t_tag WHERE lower(tag) = %s"
            print sql
            cur.execute(sql, (tag.lower(),))
            results = cur.fetchone()
            if not results:
                sql = "INSERT INTO t_tag(tag, type, status) VALUES(%s, %s, %s)"
                print sql
                cur.execute(sql, (tag, "2", "1"))
                # time.sleep(1)
                ido = conn.insert_id()
                ids = str(ido)
                tag_id.append(ids)
            else:
                tag_id.append(str(results[0]))

        sql = "SELECT COUNT(1) FROM t_article WHERE id = %s"
        print sql
        cur.execute(sql, (int(dict['id']),))
        results = cur.fetchone()
        now_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        tag_ids = ",".join(tag_id)
        #intro = dict['intro'].replace('<br />', '').replace('<br>', '').replace('\n', '').replace('\r', '')
        intro = dict['intro'].replace('\n', '').replace('\r', '')
        if results[0] <= 0:
            sql = "INSERT INTO t_article(id, title, content, html, tag_id, tag_name, img_path, " \
                  "status, create_time) VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s)"
            print sql
            cur.execute(sql, (int(dict['id']), dict['title'], intro, dict['body'], tag_ids, dict['tag'],
                              dict['img'], '1', now_time))
            cur.execute(create_sql(tag_id, int(dict['id'])))
        else:
            sql = "UPDATE t_article SET title=%s, content=%s, html=%s, tag_id=%s, tag_name=%s, " \
                  "img_path=%s, update_time=%s WHERE id = %s"

            print sql
            cur.execute(sql, (dict['title'], intro, dict['body'], tag_ids, dict['tag'],
                              dict['img'], now_time, int(dict['id'])))

            sql = "DELETE FROM t_article_tag WHERE aid = %s"
            print sql
            cur.execute(sql, (int(dict['id']),))
            cur.execute(create_sql(tag_id, int(dict['id'])))

        conn.commit()
    except Exception, e:
        raise e
    finally:
        cur.close()
        conn.close()

def create_sql(tag_id, aid):
    sql = "INSERT INTO t_article_tag(aid, tagid) VALUES"
    values = []
    for tag in tag_id:
        values.append('(' + str(aid) + ',' + str(tag) + ')')

    sql = sql + ",".join(values)
    print sql
    return sql


data = parse_html()
update_data(data)

