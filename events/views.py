# Django imports
from django.http import HttpResponse, Http404, HttpResponseRedirect
from django.shortcuts import render_to_response, get_object_or_404
from django.db.models import Q
from django.db import transaction
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required
from django.db import connection

# Mako imports
from mako.template import Template
from mako import exceptions
from mako.lookup import TemplateLookup

# Standard library imports
import time, datetime, os, timeit
from itertools import *

# Project-specific imports
from models import *
from tsa.config import *

def get_template(name):
    mylookup = TemplateLookup(directories=[TEMPLATE_DIR])
    return mylookup.get_template(name)

def render_template(name,**kwds):
    try:
        t = get_template(name)
        txt = t.render(**kwds)
    except:
        return HttpResponse(exceptions.html_error_template().render() )
    return HttpResponse(txt)



@login_required
def index(request):
    return render_template('index.mako',user=request.user,events=Event.objects.all())

@login_required
def update_indi(request):
    if request.method == 'POST':
        eid = int(request.POST['add_indi_event'])
        if eid != -1:
            e = Event.objects.get(id=eid)
            e.entrants.add(request.user)
        for key in [k for k in request.POST.keys() if k.startswith('remove')]:
            junk, eid = key.split('_')
            e = Event.objects.get(id=int(eid))
            e.entrants.remove(request.user)
    return index(request)

@login_required
def join_team(request):
    eid = request.REQUEST['event_id']
    e = Event.objects.get(id=eid)
    if request.method == 'POST':
        t = Team(event=e)
        t.save()
        t.members.add(request.user)
        return HttpResponseRedirect('/teams/%d' % t.id)
    return render_template('join_team.mako',user=request.user, teams=Team.objects.filter(event=e), event=e)

@login_required
def view_team(request, tid):
    return render_template('view_team.mako', team=Team.objects.get(id=tid), user=request.user)

@login_required
def update_team(request, tid):
    action = request.REQUEST['action']
    team = Team.objects.get(id=tid)
    if action == 'join':
        if team.entry_locked:
            return HttpResponse('Error: Team is locked; nobody may join')
        team.members.add(request.user)
        team.save()
        return HttpResponseRedirect('/teams/%d/' % team.id)
    if request.user not in team.members.all() and not request.user.is_superuser:
        return HttpResponse('ACCESS DENIED: You are not in the team you are trying to update.')
    if action == 'lock_team':
        team.entry_locked = not team.entry_locked
        team.save()
    if action == 'Add Member':
        u = User.objects.get(id=int(request.REQUEST['user_id']))
        team.members.add(u)
        team.save()
    if action == 'remove_member':
        u = User.objects.get(id=int(request.REQUEST['user_id']))
        team.members.remove(u)
        team.save()
    if action == 'delete_team':
        team.delete()
        return HttpResponseRedirect('/')
    #return view_team(request, tid)
    return HttpResponseRedirect('/teams/%d/' % team.id)

@login_required
def event_list(request):
    if request.REQUEST.get('action','') == 'lock_event':
        if not request.user.is_superuser:
            return render_template('event_list.mako',user=request.user,events=Event.objects.all(),
                msg='You do not have permission to lock and unlock events')
        e = Event.objects.get(id=int(request.REQUEST['event_id']))
        e.entry_locked = not e.entry_locked
        e.save()
    return render_template('event_list.mako',user=request.user,events=Event.objects.all())
    
@login_required
def member_list(request):
    return render_template('member_list.mako',user=request.user,members=User.objects.all())