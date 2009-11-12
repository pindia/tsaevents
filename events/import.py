import os, random, csv
os.environ['DJANGO_SETTINGS_MODULE'] = 'tsa.settings'
from tsa.config import *

from tsa.events.models import Event

#Event.objects.all().delete()

reader = csv.reader(file('events.csv'))
reader.next()
for line in reader:
    print line
    n = int(line[0])
    team = n != 1
    name = line[1]
    short_name = line[5]
    if line[2] == '?':
        reg = -1
    elif line[2] == ' ' or line[2] == '':
        reg = 0
    else:
        reg = int(line[2])
    if line[3].strip() == 'Q':
        state = -1
    elif line[3] == ' ':
        state = 0
    else:
        state = int(line[3])
    if len(line) < 5:
        nation = 0
    elif line[4] == ' ' or line[4] == '':
        nation = 0
    elif len(line[4]) > 2:
        nation = -int(line[4][0])
    else:
        nation = int(line[4])
    e = Event(name=name, is_team = team, team_size=n, max_region=reg, max_state=state, max_nation=nation, short_name=short_name)
    e.save()
   