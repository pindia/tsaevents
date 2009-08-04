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
import tsa.settings

def get_template(name):
    mylookup = TemplateLookup(directories=[TEMPLATE_DIR])
    return mylookup.get_template(name)

def render_template(name,request,**kwds):
    try:
        kwds.update(dict(
            user=request.user,
            messages=request.user.get_and_delete_messages(),
            MODE = tsa.settings.MODE
        ))
        t = get_template(name)
        txt = t.render(**kwds)
    except:
        return HttpResponse(exceptions.html_error_template().render() )
    return HttpResponse(txt)
    
def message(request, msg):
    request.user.message_set.create(message=msg)



@login_required
def index(request):
    for user in User.objects.all():
        try:
            user.profile
        except UserProfile.DoesNotExist:
            UserProfile(user=user, is_member=True, senior=False).save()
    return render_template('index.mako',request, events=Event.objects.all())

@login_required
def update_indi(request):
    if request.method == 'POST':
        eid = int(request.POST['add_indi_event'])
        if eid != -1:
            e = Event.objects.get(id=eid)
            if e.entry_locked:
                message(request, 'Error: Event is locked')
            elif request.user in e.entrants.all():
                message(request, 'Error: You are already in that event.')
            else:
                e.entrants.add(request.user)
                message(request, 'Individual event "%s" added.' % e.name)
    if 'delete_event' in request.GET:
        eid = int(request.GET['delete_event'])
        e = Event.objects.get(id=eid)
        e.entrants.remove(request.user)
        message(request, 'Individual event "%s" removed.' % e.name)
    return index(request)

@login_required
def join_team(request):
    eid = request.REQUEST['event_id']
    e = Event.objects.get(id=eid)
    if request.method == 'POST':
        t = Team(event=e)
        t.captain = request.user
        t.senior = request.user.profile.senior
        t.save()
        t.members.add(request.user)
        message(request, 'New team created.')
        return HttpResponseRedirect('/teams/%d' % t.id)
    return render_template('join_team.mako',request, teams=Team.objects.filter(event=e), event=e)

@login_required
def view_team(request, tid):
    return render_template('view_team.mako',request, team=Team.objects.get(id=tid))

@login_required
def update_team(request, tid):
    action = request.REQUEST['action']
    team = Team.objects.get(id=tid)
    
    if action == 'join':
        if team.entry_locked:
            return HttpResponse('Error: Team is locked; nobody may join')
        team.members.add(request.user)
        team.save()
        message(request, 'You have joined this team.')
        return HttpResponseRedirect('/teams/%d/' % team.id)
        
    if action == 'remove_member' and int(request.REQUEST['user_id']) == request.user.id:
        # The logged in user is leaving the team
        team.members.remove(request.user)
        message(request, 'You have left the team.')
        if team.members.count() == 0:
            team.delete()
            message(request, 'The team has been deleted because you were the last member.')
        elif request.user == team.captain:
            team.captain = team.members.all()[0]
            team.save()
            message(request, '%s %s is the new team captain.' % (team.captain.first_name, team.captain.last_name))
        return HttpResponseRedirect('/')
        
    if request.user not in team.members.all() and not request.user.is_superuser:
        message(request, 'Error: you are not in this team.')
        return HttpResponseRedirect('/teams/%d/' % team.id)
    # All actions beyond this point require team membership
        
    if action == 'Add Member':
        u = User.objects.get(id=int(request.REQUEST['user_id']))
        team.members.add(u)
        team.save()
        message(request, '%s %s has been added to the team.' % (u.first_name, u.last_name))
        return HttpResponseRedirect('/teams/%d/' % team.id)
        
    if request.user != team.captain and not request.user.is_superuser:
        message(request, 'Error: you are not the team captain.')
        return HttpResponseRedirect('/teams/%d/' % team.id)
    # All actions beyond this point require team captain
    
    if action == 'lock_team':
        team.entry_locked = not team.entry_locked
        team.save()
        if team.entry_locked:
            message(request, 'The team is now locked.')
        else:
            message(request, 'The team is now unlocked.')
    if action == 'remove_member':
        u = User.objects.get(id=int(request.REQUEST['user_id']))
        team.members.remove(u)
        team.save()
        message(request, '%s %s has been removed from the team.' % (u.first_name, u.last_name))
    if action == 'promote_member':
        u = User.objects.get(id=int(request.REQUEST['user_id']))
        team.captain = u
        team.save()
        message(request, '%s %s has been promoted to team captain.' % (u.first_name, u.last_name))
    if action == 'delete_team':
        team.delete()
        return HttpResponseRedirect('/')
        message(request, 'The team has been deleted.')

    return HttpResponseRedirect('/teams/%d/' % team.id)

@login_required
def event_list(request):
    if request.method == 'POST':
        i = 0
        for event in Event.objects.all():
            if event.entry_locked and not 'lock_%d' % event.id in request.POST:
                event.entry_locked = False
                event.save()
                i += 1
            elif not event.entry_locked and 'lock_%d' % event.id in request.POST:
                event.entry_locked = True
                event.save()
                i += 1
        message(request, '%d events updated.' % i)
    return render_template('event_list.mako',request,events=Event.objects.all())
    
@login_required
def member_list(request):
    return render_template('member_list.mako',request,members=User.objects.all())
    
@login_required
def team_list(request):
    return render_template('team_list.mako',request,teams=Team.objects.all())